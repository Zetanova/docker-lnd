## docker build multiarch 
```
export LN_VERSION=0.12.0-beta
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 --build-arg LN_VERSION -t zetanova/lnd:0.12.0-beta -t zetanova/lnd:latest --push .
```

## docker setup

docker create volume lnd
docker run -it --rm -v lnd:/tmp/lnd busybox vi /tmp/lnd/lnd.conf

smaple config
```
debuglevel=info
listen=0.0.0.0:9735
externalip=your.ip.add.ress
alias=A name for your node
color=#000000
maxpendingchannels=5
bitcoin.mainnet=1
bitcoin.active=1
bitcoin.node=bitcoind
bitcoind.rpchost=bitcoind.ip.add.ress
bitcoind.rpcuser=bitcoind_rpc_user_string
bitcoind.rpcpass=bitcoind_rpc_password_string
bitcoind.zmqpubrawblock=tcp://bitcoind.ip.add.ress:18501
bitcoind.zmqpubrawtx=tcp://bitcoind.ip.add.ress:18502
bitcoind.estimatemode=ECONOMICAL
tor.active=1
tor.socks=tor.ip.add.ress:9050
tor.control=tor.ip.add.ress:9051
tor.password=tor_password
tor.v3=1
watchtower.active=1
watchtower.listen=0.0.0.0:9911
watchtower.externalip=your.ip.add.ress
wtclient.active=1
```

### firewall centos
```
#open proxy port to private zone
firewall-cmd --permanent --zone=public --add-port=9735/tcp 
firewall-cmd --permanent --zone=public --add-port=9911/tcp 
firewall-cmd --reload
```

## docker setup
```
docker run -d --name lnd --restart=unless-stopped -v lnd:/home/lnd/.lnd -p 9735:9735 -p 9911:9911 zetanova/lnd:0.12.0-beta
   
```

## lnd commands

init wallet
```
docker exec -it lnd lncli create
```

## docker backup

manual backup
```
docker cp lnd:/home/lnd/.lnd/data/chain/bitcoin/mainnet/channel.backup - | ssh user@remoteserver" tar xvf -"
```