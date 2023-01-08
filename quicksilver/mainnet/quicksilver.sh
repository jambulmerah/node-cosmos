#!/bin/bash
dep=(jq curl bash)
if [[ $(type ${dep[@]} 2>&1 >/dev/null) ]]; then
  sudo apt update && sudo apt install ${dep[@]} -y
fi
clear
echo -e "\e[96m"
##########################################################
#     Begin configuration by https://jambulmerah.dev     #
##########################################################
# Main
project_name="Quicksilver"
repo="https://github.com/ingenuity-build/quicksilver"
repo_dir="quicksilver"
bin_name="quicksilverd"
chain_dir="$HOME/.quicksilverd"
conf_dir="$chain_dir/config"
conf_toml="$conf_dir/config.toml"
app_toml="$conf_dir/app.toml"
cosmovisor_url="github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.3.0"

# Testnet
chain[1]="Testnet"
denom[1]="uqck"
chain_id[1]="innuendo-4"
repo_tag[1]="v1.1.0-innuendo"
rpc[1]="https://quicksilver-testnet-rpc.jambulmerah.dev:443"
rpc_peer[1]="67224ac7f52eac4db6bb0a8de0bf8fbc5e7e0069@199.204.45.23:10656"
genesis[1]="https://raw.githubusercontent.com/ingenuity-build/testnets/main/innuendo/genesis.json"
addrbook[1]=""
seeds[1]=""
peers[1]="$(curl -s --connect-timeout 0.25 ${rpc[1]}/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -s -d,)"
snapshot[1]="$(curl -s --connect-timeout 0.25 https://polkachu.com/testnets/quicksilver/snapshots | grep -o ">quicksilver.*\.tar.lz4" | tr -d ">" | head -1)"
snapshot_url[1]="https://snapshots.polkachu.com/testnet-snapshots/quicksilver/${snapshot[1]}"
snapshot_provider[1]="polkachu.com"
key_backend[1]=test

# Mainnet
chain[2]="Mainnet"
denom[2]="uqck"
chain_id[2]="quicksilver-2"
repo_tag[2]="v1.2.0"
rpc[2]="https://quicksilver-rpc.jambulmerah.dev:443"
rpc_peer[2]="18b9d4b4cd492715c41042e23907ab3ce292bc4b@38.108.68.113:26656"
genesis[2]="https://github.com/ingenuity-build/mainnet/raw/main/genesis.json"
addrbook[2]=
seeds[2]=
peers[2]="$(curl -s --connect-timeout 0.25 ${rpc[2]}/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -s -d,)"
snapshot[2]="$(curl -s --connect-timeout 0.25 https://snapshots.polkachu.com/snapshots | xmlstarlet fo | grep -o ">quicksilver.*\.tar.lz4" | tr -d ">")"
snapshot_url[2]="https://snapshots.polkachu.com/snapshots/${snapshot[2]}"
snapshot_provider[2]="polkachu.com"
key_backend[2]=os

# Script
version="v0.1.0-beta"
logo_url="https://raw.githubusercontent.com/jambulmerah/node-cosmos/master/script/logo.sh"
input_prompt="[${USER}⚛️ $(hostname)]─[$(echo $(pwd) | sed 's|'$HOME'|~|')]─"
tcp_regex='^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$'
x_mark="\e[31;1m\xE2\x9C\x97\e[0;96m"
check_mark="\e[32;1m\xE2\x9C\x94\e[0;96m"
ip_address=$(curl -s ifconfig.me)
bline="==================================================================="
##########################################################
#      END configuration by https://jambulmerah.dev      #
##########################################################

buildBinary(){
clear
echo -e "The process is running...\nPlease wait this process until it's finished!!!"
# Updating packages
echo -e -n "[1/4] Updating and upgrading packages...\t"
sudo apt update >/dev/null 2>&1
echo -e "$check_mark"

# Installing dependencies
echo -n -e "[2/4] Installing dependencies...\t\t"
DEBIAN_FRONTEND=noninteractive sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool xmlstarlet -y -qq >/dev/null 2>&1
ver="1.19.4"
cd ~
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" -O go$ver.linux-amd64.tar.gz >/dev/null 2>&1
sudo rm -rf $(which go)
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
echo "export GOROOT=/usr/local/go" >> ~/.bash_profile
source ~/.bash_profile
sudo curl -s "https://get.ignite.com/cli!" | sudo bash >/dev/null 2>&1
echo -e "$check_mark"

# Cloning binary
echo -n -e "[3/4] Cloning binary repo...\t\t\t"
rm -rf $repo_dir
git clone $repo >/dev/null 2>&1
echo -e "$check_mark"

# Build binary
echo -n -e "[4/4] Building binary for the "${chain_id[$x]}"...\t"
cd ~/$repo_dir
git fetch --all >/dev/null 2>&1
git checkout ${repo_tag[$x]} >/dev/null 2>&1
make install >/dev/null 2>&1 || ignite chain build >/dev/null 2>&1
echo -e "\e[0;96m$check_mark"
echo -e "The binary $bin_name has been successfully built....\n"
sleep 1.5
clear
}


installCosmovisor(){
clear
echo -e -n "\e[96;1mInstalling and configuring cosmovisor...\e[0;96m "
go install $cosmovisor_url
}


initNode(){
while true; do
    echo -e "Next, we need to give your "$project_name" ${chain_id[$x]} node a nickname..."
    echo "What nodename do you prefer...?"
    read -p "$(printf "\n${input_prompt}(Nodename)─>> ")" nodename
    if [[ $nodename =~ "\"" || $nodename =~ "'" || -z $nodename ]]; then
        clear
        echo "Quotes not allowed and input can't be blank"
    else
        clear
        break
    fi
done
echo -n -e "Initializing node for the "$project_name" ${chain_id[$x]}...\t\t"
$bin_name init "${nodename}" --chain-id ${chain_id[$x]} --home "${chain_dir}" >/dev/null 2>&1
$bin_name config chain-id ${chain_id[$x]} --home $chain_dir
$bin_name config keyring-backend ${key_backend[$x]} --home $chain_dir
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0${denom[$x]}\"/" $app_toml
sleep 0.25 && echo -e "$check_mark"

echo -n -e "Downloading genesis for the "$project_name" ${chain_id[$x]}...\t\t"
curl -sL "${genesis[$x]}" -o "${chain_dir}"/config/genesis.json
sleep 0.25 && echo -e "$check_mark"

if [[ -n ${addrbook[$x]} ]]; then
    echo -n -e "Downloading addrbook for the "$project_name" ${chain_id[$x]}...\t\t"
    curl -sL "${addrbook[$x]}" -o "${chain_dir}"/config/addrbook.json
    sleep 0.25 && echo -e "$check_mark"
fi

echo -n -e "Setting peers and seeds for the "$project_name" ${chain_id[$x]}...\t"
sed -i -e "s/^seeds *=.*/seeds = \"${seeds[$x]}\"/; s/^persistent_peers *=.*/persistent_peers = \"${peers[$x]}\"/" ${conf_toml}
sleep 0.25 && echo -e "$check_mark"

$bin_name tendermint unsafe-reset-all --home $chain_dir --keep-addr-book >/dev/null 2>&1
echo -n -e "Reset old genesis state for the "$project_name" ${chain_id[$x]}...\t"
sleep 0.25 && echo -e "$check_mark\n"
sleep 2
clear
}


setPruning(){
while true; do
    clear
    custom_strategy=(
    [1]=pruning_interval
    [2]=pruning_keep_every
    [3]=pruning_keep_recent)
    for default in ${custom_strategy[@]}; do
        export $default=0
    done
    echo "Choose the pruning strategy you want.."
    echo "$(cat $app_toml | grep "default:" | sed 's|#|[1]|;s|default|(Default)|')"
    echo "$(cat $app_toml | grep "nothing:" | sed 's|#|[2]|;s|nothing|(Nothing)|')"
    echo "$(cat $app_toml | grep "everything:" | sed 's|#|[3]|;s|everything|(Everything)|')"
    echo "$(cat $app_toml | grep "custom:" | sed 's|#|[4]|;s|custom|(Custom)|')"
    read -p "$(echo -e "\n"${input_prompt}"(pruning)─>> ")" prun
    case $prun in
        1) pruning=default;;
        2) pruning=nothing;;
        3) pruning=everything;;
        4) pruning=custom; clear;
           while true; do
               only_num=true
               for i in ${!custom_strategy[@]}; do
                   read -p "$(echo -e ""${input_prompt}"(${custom_strategy[$i]})─>> ")" ${custom_strategy[$i]}
                   if [[ -n ${!custom_strategy[$i]} && ${!custom_strategy[$i]} =~ ^[0-9]*$ ]]; then
                       continue
                   else
                       clear
                       only_num=false
                       echo "Please input only numbers..."
                       break
                   fi
               done
               if [[ $only_num == "true" && $pruning_interval -ge 10 ]]; then
                   break
               else
                   echo "Pruning interval must not be less than 10..."
               fi
           done;;
    esac
    if [[ -n $pruning ]]; then
        sed -i 's|pruning *=.*|pruning = "'${pruning}'"|' $app_toml
        sed -i 's|pruning-interval *=.*|pruning-interval = '${pruning_interval}'|' $app_toml
        sed -i 's|pruning-keep-recent *=.*|pruning-keep-recent = '${pruning_keep_recent}'|' $app_toml
        sed -i 's|pruning-keep-every *=.*|pruning-keep-every = '${pruning_keep_every}'|' $app_toml
        sed -i 's|snapshot-interval *=.*|snapshot-interval = 500|' $app_toml
        if [[ ${pruning} == "everything" ]]; then
            sed -i 's|snapshot-interval *=.*|snapshot-interval = 0|' $app_toml
        fi
        echo Configuring the pruning strategy to $pruning && sleep 2
        break
    fi
done
}

currentPort(){

declare -g -A laddr
laddr=(
[P2P-port]=$(grep -w "laddr =" $conf_toml | tail -1 | sed 's|.*= ||; s|"||g')
[RPC-port]=$(grep -w "laddr =" $conf_toml | head -1 | sed 's|.*= ||; s|"||g')
[ABCI-port]=$(grep "proxy_app" $conf_toml | sed 's|.*= ||; s|"||g')
[Prometheus]=$(grep "prometheus_listen_addr" $conf_toml | sed 's|.*= ||; s|"||g')
[PPROF-port]=$(grep "pprof_laddr" $conf_toml | sed 's|.*= ||; s|"||g')
[API-port]=$(sed -n '/Address defines the API server to listen on/{n;p;}' $app_toml | sed 's|.*= ||; s|"||g')
[gRPC-port]=$(sed -n '/Address defines the gRPC server address to bind to/{n;p;}' $app_toml | sed 's|.*= ||; s|"||g')
[gRPC-web]=$(sed -n '/Address defines the gRPC-web server address to bind to/{n;p;}' $app_toml | sed 's|.*= ||; s|"||g')
)

# Port type
declare -g -A port_type
for i in ${!laddr[@]}; do
    port_type[$i]=$i
done

# current lport
declare -g -A lport
for i in ${!laddr[@]}; do
    lport[$i]=$(echo ${laddr[$i]} | sed 's|.*:||')
done
}

customPort(){
echo Input your custom port...
for i in ${port_type[@]}; do
    read -p "$(printf "${input_prompt}($i)─>> ")" lport[$i]
done
[ $missing_port == "false" ] && initPort
}

initPort(){
clear
declare -A new_port
echo Checking ports...
for i in ${!port_type[@]}; do
    echo -n "$i"
    if [[ $(echo -n ${lport[@]} | grep -ow "${lport[$i]}" | wc -l) -eq 1 && ${lport[$i]} =~ $tcp_regex && ! $(lsof -i tcp:${lport[$i]}) ]]; then
        echo -e "\t $check_mark \e[7;1m${lport[$i]}\e[0;96m"
        new_port[$i]=${lport[$i]}
        sleep 0.1
    else
        missing_port=true
        echo -e "\t $x_mark \e[7;1m${lport[$i]}\e[0;96m"
        sleep 0.1
    fi
done

if [[ $missing_port == true ]]; then
    missing_port=false
    echo "Some ports are not available..."
    echo -e "\nRe-enter a valid tcp port (1-65535) again and different from the others..."
    customPort
else
    echo Configuring $listen_port ports... && sleep 2
    sed -i -e 's|proxy_app = \"'${laddr[ABCI-port]}'\"|proxy_app = \"tcp://127.0.0.1:'${new_port[ABCI-port]}'\"|' $conf_toml
    sed -i -e 's|pprof_laddr = \"'${laddr[PPROF-port]}'\"|pprof_laddr = \"localhost:'${new_port[PPROF-port]}'\"|' $conf_toml
    sed -i -e 's|laddr = \"'${laddr[RPC-port]}'\"|laddr = \"tcp://0.0.0.0:'${new_port[RPC-port]}'\"|' $conf_toml
    sed -i -e 's|laddr = \"'${laddr[P2P-port]}'\"|laddr = \"tcp://0.0.0.0:'${new_port[P2P-port]}'\"|' $conf_toml
    sed -i -e 's|prometheus_listen_addr = \"'${laddr[Prometheus]}'\"|prometheus_listen_addr = \":'${new_port[Prometheus]}'\"|' $conf_toml
    sed -i -e 's|address = \"'${laddr[API-port]}'\"|address = \"tcp://0.0.0.0:'${new_port[API-port]}'\"|' $app_toml
    sed -i -e 's|address = \"'${laddr[gRPC-port]}'\"|address = \"0.0.0.0:'${new_port[gRPC-port]}'\"|' $app_toml
    sed -i -e 's|address = \"'${laddr[gRPC-web]}'\"|address = \"0.0.0.0:'${new_port[gRPC-web]}'\"|' $app_toml
    $bin_name config node tcp://localhost:${new_port[RPC-port]}
fi
}


setPort(){
while true; do
clear
    currentPort
    echo "Select the listen ports option for ${project_name} ${chain_id[$x]}..."
    echo "[1] Default ports.."
    echo "[2] Custom ports.."
    read -p "$(printf "${input_prompt}(Listen-port)─>> ")" port
    case $port in
        1) export listen_port=default; initPort; break;;
        2) export listen_port=custom; clear; customPort; initPort; break;;
    esac
done
}


snapshotSync(){
clear
if [[ -n ${snapshot[$x]} && $(curl -sI --connect-timeout 0.25 ${snapshot_url[$x]} 2>/dev/null) ]]; then
    sudo systemctl stop ${bin_name}.service
    $bin_name tendermint unsafe-reset-all --keep-addr-book --home $chain_dir >/dev/null 2>&1
    echo "Downloading and decompressing snapshot..." && tput civis
    curl -L# ${snapshot_url[$x]} | tar -I lz4 -xf - -C $chain_dir
    tput cnorm
    echo Snapshot downloaded and decompressed to $chain_dir
    sudo systemctl restart ${bin_name}.service
    finish=true
    printFinish
else
    echo Hemm failed to comnect with snapshot URL...
fi
}


stateSync(){
clear
echo "Fething state sync"
if [[ -n ${rpc[$x]} && $(curl -s --connect-timeout 0.25 ${rpc[$x]} 2>/dev/null) ]]; then
    LATEST_HEIGHT=$(curl -s --connect-timeout 0.25 ${rpc[$x]}/block | jq -r .result.block.header.height); \
    BLOCK_HEIGHT=$((LATEST_HEIGHT - 500)); \
    TRUST_HASH=$(curl -s --connect-timeout 0.25 "${rpc[$x]}/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
    echo -e "Fetched statesync :\nLatest height : $LATEST_HEIGHT \nBlock height  : $BLOCK_HEIGHT \nTrust Hash    : $TRUST_HASH \nRPC          : ${rpc[$x]}" && sleep 1.5
    sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
    s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"${rpc[$x]},${rpc[$x]}\"| ; \
    s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
    s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $conf_dir/config.toml
    sudo systemctl stop ${bin_name}.service
    $bin_name tendermint unsafe-reset-all --keep-addr-book --home $chain_dir >/dev/null 2>&1
    sudo systemctl restart ${bin_name}.service
    finish=true
    printFinish
else
    echo Hemm failed to connect state sync RPC...
fi
}


setSyncMethod(){
clear
while true; do
clear
echo "Choose your preferred block synchronization method"
echo "[1] Sync "$project_name" "${chain_id[$x]}" with snapshot provided by "${snapshot_provider[$x]}""
echo "[2] Sync "$project_name" "${chain_id[$x]}" with statesync"
echo "[3] Sync "$project_name" "${chain_id[$x]}" blocks from scratch without snapshot and statesync"
read -p "$(printf "${input_prompt}(SyncMethod)─>> ")" sync
case $sync in
    1) [ -n ${snapshot[$x]} ] && snapshotSync; break;;
    2) [ -n ${rpc[$x]} ] && stateSync; break;;
    3) sudo systemctl restart $bin_name; printFinish; break;;
esac

done
}


cosmovisorService(){
mkdir -p $chain_dir/cosmovisor/genesis/bin/
mkdir -p $chain_dir/cosmovisor/upgrades/
cp $(which $bin_name) $chain_dir/cosmovisor/genesis/bin/

sudo tee /usr/lib/systemd/system/$bin_name.service > /dev/null <<EOF
[Unit]
Description="$project_name Service by JambulMerah | Cosmos⚛️Lovers❤️"
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start --home $chain_dir
Restart=always
RestartSec=3
LimitNOFILE=4096

Environment="DAEMON_HOME="$chain_dir""
Environment="DAEMON_NAME="$bin_name""
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $bin_name
}


defaultService(){
sudo tee /usr/lib/systemd/system/$bin_name.service > /dev/null <<EOF
[Unit]
Description="$project_name Service by JambulMerah | Cosmos⚛️Lovers❤️"
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $bin_name) --home $chain_dir start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $bin_name
}


initSystemdService(){
while true; do
    clear
    echo "Choose your service to run node "$project_name" "${chain_id[$i]}""
    echo "[1] Run with cosmovisor..."
    echo "[2] Run wihout cosmovisor..."
    read -p "$(printf "${input_prompt}(Systemd-service)─>> ")" service
    case $service in
        1) installCosmovisor; cosmovisorService; break;;
        2) systemdService; break;;
    esac
done
}


printFinish(){
if [[ -n $finish ]]; then
sleep 3
    if [[ `sudo systemctl status $bin_name | grep active` =~ "running" ]]; then
        echo -e "\nYour $bin_name node \e[1;32minstalled and running\e[0;96m..!"
        echo -e "Check node syncing info : \e[1;32m${bin_name} status 2>&1 | jq '.SyncInfo' \e[0;96m"
        echo -e "Check node log          : \e[1;32msudo journalctl -ocat -fu $bin_name \e[0;96m"
        exit
    else
        echo -e "\nYour $bin_name node \e[1;31mwas not installed correctly\e[0;96m"
        echo -e "Check your error with: \e[1;32m sudo systemctl status $bin_name \e[0;96m And or \e[1;32msudo journalctl -ocat -u $bin_name -n 500 | grep -e \"Error\" -e \"ERR\"\e[0m"
        exit 1
    fi
fi
}

getNodeInfo(){
for v in ${!chain_id[@]}; do
    if [[ $($bin_name status 2>/dev/null | jq -r '.NodeInfo.network' 2>/dev/null) == ${chain_id[$v]} ]]; then
        net_id=$($bin_name status 2>/dev/null | jq -r '.NodeInfo.network' 2>/dev/null)
        syncing=$($bin_name status | jq -r '.SyncInfo.catching_up')
        node_name=$($bin_name status | jq -r '.NodeInfo.moniker')
        val_key=$($bin_name tendermint show-validator)
        miss_block=$($bin_name q slashing signing-info ${val_key} -oj 2>/dev/null | jq -r '.missed_blocks_counter' 2>/dev/null)
        echo -e "\e[1;7mYou have a running ${project_name} ${chain[$v]} (${chain_id[$v]}) node\e[0;96m "
        echo "Node syncing      : $syncing"
        if [[ -n ${miss_block} ]]; then
            val_info=$($bin_name q staking validators -oj --limit 5000 | jq '.validators[] | select(.consensus_pubkey=='${val_key}')')
            val_moniker=$(echo $val_info | jq -r '.description.moniker')
            val_status=$(echo $val_info | jq -r '.status')
            val_jailed=$(echo $val_info | jq -r '.jailed')
            echo -e "Node as validator : True $check_mark"
            if [[ $val_status =~ "BONDED" ]]; then
                echo -e "Validator status  : Active $check_mark"
            else
                echo -e "Validator status  : Inactive $x_mark"
            fi
            echo -e "Validator moniker : $val_moniker"
            echo -e "Missed blocks     : $miss_block"
            echo -e "Jailed            : $val_jailed"
        else
            echo -e "Node as validator : False $x_mark"
            echo -e "Nodename          : $node_name"
        fi
        echo $bline
    fi
done
}

menuOption(){
while true; do
    clear
    echo -e " \e[1;7m${version}\e[0;96m"
    . <(curl -s $logo_url)
    getNodeInfo
    if [[ $(curl -s --connect-timeout 0.25 ${rpc[$c]}) ]]; then
        last_block=$(curl -s ${rpc[$c]}/status | jq -r '.result.sync_info.latest_block_height')
        echo -e "\e[1;7m${project_name} ${chain_id[$c]} State sync info \e[0;96m "
        echo "Height   : $last_block"
        echo "RPC      : ${rpc[$c]}"
        echo "Peer     : ${rpc_peer[$c]}"
        echo $bline
    fi
    if [[ -n ${snapshot[$c]} ]]; then
        snap_size=$(curl -sI ${snapshot_url[$c]} | grep "content-length" | sed 's|\r||g;s|.*: ||g' | numfmt --to iec)
        snap_height=$(echo ${snapshot[$c]} | sed 's|\..*||g;s|.*_||g;s|.*-||g')
        echo -e "\e[1;7m${project_name} ${chain_id[$c]} Snapshot Info \e[0;96m"
        echo "Provider : ${snapshot_provider[$c]}"
        echo "URL      : ${snapshot_url[$c]}"
        echo "Height   : $snap_height"
        echo "Size     : $snap_size"
        echo $bline
     fi
     echo -e "[1] Install Node \t [5] Custom Pruning \t [0] Exit"
     echo -e "[2] Snapshot Sync \t [6] Check Log"
     echo -e "[3] State Sync \t\t [7] Uninstall node"
     echo -e "[4] Custom Port \t [8] Back"
     read -p "$(printf "${input_prompt}(${chain_id[$c]})─>> ")" p
     case $p in
         8) break;;
         0) exit;;
     esac
     if [[ ${p#0} -eq 1 ]]; then
         if [[ -z ${net_id} ]]; then
             buildBinary
             initNode
             setPruning
             setPort
             initSystemdService
             setSyncMethod
             printFinish
         else
             clear
             echo "Aborting!!.. You have a running ${project_name} ${net_id} node "
             sleep 3
         fi
     fi
     for opt in {2..7}; do
         if [[ ${p#0} -eq $opt ]]; then
             if [[ -d $chain_dir ]]; then
                 clear
                 printFinish
                 case $p in
                     2) snapshotSync; break;;
                     3) stateSync; break;;
                     4) export listen_port=custom; clear; currentPort; customPort; initPort; break;;
                     5) setPruning; break;;
                     6) sudo journalctl -fu $bin_name -ocat; break;;
                     7) read -p "Are you sure to uninstall $bin_name node ..? [Y/n] " yn
                        case $yn in
                            [Yy]) clear; sudo systemctl stop $bin_name
                                  sudo systemctl disable $bin_name
                                  rm -rf $chain_dir; sudo rm -rf $(which $bin_name)
                                  sudo find /*/systemd -name ${bin_name}.service -exec rm -rf '{}' \;
                                  echo "Uh no, $bin_name node have successfully uninstalled..."
                                  exit;;
                        esac
                 esac
             else
                 clear
                 echo "Could't find The $chain_dir chain directory..."
                 sleep 3
                 break
             fi
         fi
     done
done
}

systemInfo(){
    echo -e "\e[1;7mSystem information \e[0;96m"
    echo "OS             : $(uname -sp)"
    echo "Distro         : $(cat /etc/lsb-release | grep DESCRIPTION | sed 's|.*=||;s|"||g')"
    echo "CPU            : $(lscpu | grep "Model name:" | awk '{printf $3}') ($(nproc --all)) $(lscpu |awk -F : '($1=="CPU MHz") {printf "%3.2fGHz\n", $2/1000}')"
    echo "RAM            : $(free -h | grep "Mem: " | awk '{printf $2}')"
    echo "Storage        : $(df -h | grep -w "/" | awk '{printf $2}')"
}
while true; do
clear
    echo -e " \e[1;7m${version}\e[0;96m"
    . <(curl -s $logo_url)
    getNodeInfo
    echo $bline
    for i in ${!chain[@]}; do
        echo -e "\e[1;7m${project_name} ${chain[$i]} info \e[0;96m "
        echo "Network type     : ${chain[$i]}"
        echo "Chain ID         : ${chain_id[$i]}"
        echo "Binary version   : $(curl -s --connect-timeout 0.25 ${rpc[$i]}/abci_info | jq -r .result.response.version)"
        echo "Block height     : $(curl -s --connect-timeout 0.25 ${rpc[$i]}/status | jq -r .result.sync_info.latest_block_height)"
        echo "Status           : $(echo ${chain_id[$i]} | grep ${chain_id[$i]} >/dev/null 2>&1 && echo -e ""$check_mark" Live" || echo -e "$x_mark" Not live)"
        echo $bline
    done
    echo "Select $project_name node services... "
    for i in ${!chain[@]}; do
        echo -n "[$i] Services $project_name ${chain[$i]} node "
        echo ${chain_id[$i]} | grep ${chain_id[$i]} >/dev/null 2>&1 && echo -e "(${chain_id[$i]}) \t"${check_mark}" Live" || echo -e "\t"${x_mark}" Not live"
    done
    echo "[0] Exit"
    read -p "$(printf "${input_prompt}(${project_name})─>> ")" x
    case $x in
        0) exit;;
    esac
    for c in ${!chain[@]}; do
        if [[ ${x#0} -eq $c && -n ${chain_id[$c]} ]]; then
            if [[ -n ${net_id} ]]; then
                if [[ ${net_id} == ${chain_id[$c]} ]]; then
                    menuOption
                elif [[ ${net_id} != ${chain_id[$c]} ]]; then
                    clear
                    echo "Hemm you have running node ${net_id}.. But you choose a different service.."
                    sleep 3
                fi
            else
                menuOption
            fi
        fi
    done
done
