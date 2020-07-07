FROM alpine:3.12 as build
ARG TARGETPLATFORM
#0.10.3-beta
ARG LN_VERSION

RUN apk update && apk add curl gnupg

WORKDIR /app

RUN curl https://keybase.io/roasbeef/pgp_keys.asc | gpg --import 

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ] || [ "${TARGETPLATFORM}" = "" ]; then export LN_TARGET=linux-amd64; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then export LN_TARGET=linux-arm64; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then export LN_TARGET=linux-armv7; fi \
  && curl -SLO https://github.com/lightningnetwork/lnd/releases/download/v${LN_VERSION}/lnd-${LN_TARGET}-v${LN_VERSION}.tar.gz \
  && curl -SLO https://github.com/lightningnetwork/lnd/releases/download/v${LN_VERSION}/manifest-v${LN_VERSION}.txt \
  && curl -SLO https://github.com/lightningnetwork/lnd/releases/download/v${LN_VERSION}/manifest-v${LN_VERSION}.txt.sig \
  && gpg --verify manifest-v${LN_VERSION}.txt.sig \
  && grep " lnd-${LN_TARGET}-v${LN_VERSION}.tar.gz\$" manifest-v${LN_VERSION}.txt | sha256sum -c

RUN tar -xzf *.tar.gz -C . \
  && mv ./lnd-*-v${LN_VERSION} ./lnd


FROM alpine:3.12

ENV PATH=/opt/lnd:$PATH

COPY --from=build /app/lnd /opt/lnd

RUN addgroup lnd && adduser --ingroup lnd --disabled-password lnd \
  && mkdir -p "/home/lnd/.lnd" \
  && chmod 700 -R /home/lnd \
  && chown -R lnd /home/lnd

USER lnd

WORKDIR "/home/lnd"

VOLUME ["/home/lnd/.lnd"]

EXPOSE 9735 9911 

CMD ["lnd"]