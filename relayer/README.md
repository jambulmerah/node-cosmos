#### Install hermes
```
curl -L#  https://github.com/informalsystems/hermes/releases/download/v1.2.0/hermes-v1.2.0-x86_64-unknown-linux-gnu.tar.gz | tar -xzf- -C /usr/local/bin
mkdir -p $HOME/.hermes
```

### Check hermes 
```
hermes version
```
JIKA ERROR `glibc` Not found
```
sed -i '1i deb http://nova.clouds.archive.ubuntu.com/ubuntu/ jammy main' /etc/apt/sources.list

apt update && apt install libc6 -y

sed -i 's|deb http://nova.clouds.archive.ubuntu.com/ubuntu/ jammy.*||g' /etc/apt/sources.list

hermes version
```

#### TX MEMO prefix
```
RELAYED_BY='Relayed by discordusername#0000'
```

### Sample config hermes
```
cat <<EOF > ~/.hermes/config.toml
[global]
log_level = 'debug'
[mode.clients]
enabled= true
refresh = true
misbehaviour= true

[mode.connections]
enabled= true

[mode.channels]
enabled= true

[mode.packets]
enabled = true
clear_interval = 200
clear_on_start = true
tx_confirmation = true
auto_register_counterparty_payee = true

[rest]
enabled = true
host = '127.0.0.0'
port = 3000

[telemetry]
enabled = true
host = '127.0.0.0'
port = 3001
[[chains]]
id = 'cosmoshub-4'
type = 'CosmosSdk'
rpc_addr = 'https://cosmoshub.rpc.interchain.ivaldilabs.xyz'
websocket_addr = 'wss://cosmoshub.rpc.interchain.ivaldilabs.xyz/websocket'
grpc_addr = 'http://cosmos-grpc.polkachu.com:14990'
rpc_timeout = '20s'
account_prefix = 'cosmos'
key_name = 'relayer'
key_store_type = 'Test'
store_prefix = 'ibc'
default_gas = 100000
max_gas = 40000000
gas_multiplier = 2.0
max_msg_num = 30
max_tx_size = 180000
clock_drift = '15s'
max_block_time = '10s'
memo_prefix = 'Relayed by feriantogumulia#1421'
sequential_batch_tx= true
trusting_period = '7days'

[chains.trust_threshold]
numerator = '1'
denominator = '3'

[chains.gas_price]
price = 0.0025
denom = 'uatom'

[chains.packet_filter]
policy = 'allow'
list = [
    [
    'transfer',
    'channel-446',
],
]

[chains.address_type]
derivation = 'cosmos'

[[chains]]
id = 'gravity-bridge-3'
type = 'CosmosSdk'
rpc_addr = 'https://rpc.gravity.bh.rocks'
websocket_addr = 'wss://rpc.gravity.bh.rocks/websocket'
grpc_addr = 'http://gravity-grpc.polkachu.com:14290'
rpc_timeout = '20s'
account_prefix = 'gravity'
key_name = 'relayer'
key_store_type = 'Test'
store_prefix = 'ibc'
default_gas = 100000
max_gas = 120000000
gas_multiplier = 2.0
max_msg_num = 30
max_tx_size = 180000
clock_drift = '15s'
max_block_time = '10s'
memo_prefix = 'Relayed by feriantogumulia#1421'
sequential_batch_tx= true
trusting_period = '7days'

[chains.trust_threshold]
numerator = '1'
denominator = '3'

[chains.gas_price]
price = 0.0025
denom = 'ugraviton'

[chains.packet_filter]
policy = 'allow'
list = [
    [
    'transfer',
    'channel-102',
],
]

[chains.address_type]
derivation = 'cosmos'

[[chains]]
id = 'osmosis-1'
type = 'CosmosSdk'
rpc_addr = 'https://osmosis.rpc.interchain.ivaldilabs.xyz'
websocket_addr = 'wss://osmosis.rpc.interchain.ivaldilabs.xyz/websocket'
grpc_addr = 'http://osmosis-grpc.polkachu.com:12590'
rpc_timeout = '20s'
account_prefix = 'osmo'
key_name = 'relayer'
key_store_type = 'Test'
store_prefix = 'ibc'
default_gas = 100000
max_gas = 120000000
gas_multiplier = 2.0
max_msg_num = 30
max_tx_size = 180000
clock_drift = '15s'
max_block_time = '10s'
memo_prefix = 'Relayed by feriantogumulia#1421'
sequential_batch_tx= true
trusting_period = '7days'

[chains.trust_threshold]
numerator = '1'
denominator = '3'

[chains.gas_price]
price = 0.0025
denom = 'uosmo'

[chains.packet_filter]
policy = 'allow'
list = [
    [
    'transfer',
    'channel-492',
],
]

[chains.address_type]
derivation = 'cosmos'

[[chains]]
id = 'planq_7070-2'
type = 'CosmosSdk'
rpc_addr = 'https://rpc.planq.network'
websocket_addr = 'wss://rpc.planq.network/websocket'
grpc_addr = 'https://grpc.planq.network/'
rpc_timeout = '20s'
account_prefix = 'plq'
key_name = 'relayer'
key_store_type = 'Test'
store_prefix = 'ibc'
default_gas = 100000
max_gas = 40000000
gas_multiplier = 2.0
max_msg_num = 30
max_tx_size = 180000
clock_drift = '15s'
max_block_time = '10s'
memo_prefix = 'Relayed by feriantogumulia#1421'
sequential_batch_tx= true
address_type =  { derivation = 'ethermint', proto_type = { pk_type = '/ethermint.crypto.v1.ethsecp256k1.PubKey' } }
trusting_period = '7days'

[chains.trust_threshold]
numerator = '1'
denominator = '3'

[chains.gas_price]
price = 20000000000
denom = 'aplanq'

[chains.packet_filter]
policy = 'allow'
list = [
    [
    'transfer',
    'channel-2',
],
    [
    'transfer',
    'channel-0',
],
    [
    'transfer',
    'channel-1',
],
    [
    'transfer',
    'channel-8',
],
]


[[chains]]
id = 'stride-1'
type = 'CosmosSdk'
rpc_addr = 'https://stride.rpc.interchain.ivaldilabs.xyz'
websocket_addr = 'wss://stride.rpc.interchain.ivaldilabs.xyz/websocket'
grpc_addr = 'http://stride-grpc.polkachu.com:12290'
rpc_timeout = '20s'
account_prefix = 'stride'
key_name = 'relayer'
key_store_type = 'Test'
store_prefix = 'ibc'
default_gas = 100000
max_gas = 400000000000
gas_multiplier = 1.9
max_msg_num = 30
max_tx_size = 180000
clock_drift = '15s'
max_block_time = '10s'
memo_prefix = 'Relayed by feriantogumulia#1421'
sequential_batch_tx= true

[chains.trust_threshold]
numerator = '1'
denominator = '3'

[chains.gas_price]
price = 0.0025
denom = 'ustrd'

[chains.packet_filter]
policy = 'allow'
list = [
    [
    'transfer',
    'channel-54',
],
]

[chains.address_type]
derivation = 'cosmos'
EOF

```

#### Check hermes health
```
hermes health-check
```

#### Import wallet
- Siapkan mnemonic

```
MNEMONIC="isi_mnemonic_kalian"
```

```
echo "$MNEMONIC" > $HOME/.hermes.mnemonic
chain=('gravity-bridge-3' 'planq_7070-2' 'osmosis-1' 'cosmoshub-4' 'stride-1')
for c in ${chain[@]}; do
hermes keys add --key-name relayer --chain $c --mnemonic-file $HOME/.hermes.mnemonic
done
```

#### Check wallet imoorted dan balancenya
```
for c in ${chain[@]}; do
hermes keys list --chain $c
hermes keys balance --chain $c
done
```

#### Buat systemd

```
cat <<EOF > /etc/systemd/system/hermesd.service
[Unit]
Description="Hermes daemon"
After=network-online.target

[Service]
User=root
ExecStart=$(which hermes) start
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

```


#### Start systemd
```
systemctl daemon-reload
systemctl enable hermesd
systemctl restart hermesd
```

#### Check log

```
journalctl -ocat -fu hermesd
```

#### Test relay ibc transfer
```
hermes tx ft-transfer \
--src-chain osmosis-1 \
--dst-chain planq_7070-2 \
--src-port transfer \
--src-channel channel-492 \
--key-name relayer \
--receiver <planq_address> \
--amount 1 \
--denom <uosmo_atau_IBC_token> \
--timeout-seconds 60 \
--timeout-height-offset 180 
```



