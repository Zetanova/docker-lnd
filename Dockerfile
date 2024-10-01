FROM ubuntu:24.04 AS build
ARG TARGETPLATFORM
ARG LN_VERSION
ARG LN_SIGNER="roasbeef"

RUN apt-get update && apt-get install -y curl gnupg 

WORKDIR /app

RUN curl https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/${LN_SIGNER}.asc | gpg --import

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ] || [ "${TARGETPLATFORM}" = "" ]; then export LN_TARGET=linux-amd64; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then export LN_TARGET=linux-arm64; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then export LN_TARGET=linux-armv7; fi \
  && curl -SLO https://github.com/lightningnetwork/lnd/releases/download/v${LN_VERSION}/lnd-${LN_TARGET}-v${LN_VERSION}.tar.gz \
  && curl -SLO https://github.com/lightningnetwork/lnd/releases/download/v${LN_VERSION}/manifest-v${LN_VERSION}.txt \
  && curl -SLO https://github.com/lightningnetwork/lnd/releases/download/v${LN_VERSION}/manifest-${LN_SIGNER}-v${LN_VERSION}.sig \
  && gpg --verify manifest-${LN_SIGNER}-v${LN_VERSION}.sig manifest-v${LN_VERSION}.txt \
  && grep " lnd-${LN_TARGET}-v${LN_VERSION}.tar.gz\$" manifest-v${LN_VERSION}.txt | sha256sum -c

RUN tar -xzf *.tar.gz -C . \
  && mv ./lnd-*-v${LN_VERSION} ./lnd


FROM ubuntu:24.04

ENV PATH=/opt/lnd:$PATH

COPY --from=build /app/lnd /opt/lnd

RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu
RUN useradd --user-group lnd \
  && mkdir -p "/home/lnd/.lnd" \
  && chmod 700 -R /home/lnd \
  && chown -R lnd /home/lnd

USER lnd

WORKDIR "/home/lnd"

VOLUME ["/home/lnd/.lnd"]

EXPOSE 9735 9911 

CMD ["lnd"]