#!/bin/bash

merah=$'\e[91m'
kuning=$'\e[93m'
hijau=$'\e[92m'
cyan=$'\e[96m'
bold=$'\e[1m'
reset=$'\e[m'
bg=$'\e[7m'
for dep in jq curl; do
  if [[ $(type $dep 2>&1 >/dev/null) ]]; then
  echo "${cyan}${bold}Menginstall $dep....${reset}"
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt install $dep -y
  fi
done

clear
echo -e "${cyan}${bold}Memuat list rantai di cosmos chain registry...${reset}"
rpc_directory_url="https://rpc.cosmos.directory"
chains_registry_url="https://chains.cosmos.directory"
chains_list=($(curl -s $chains_registry_url | jq -r '.chains[].name'))
bline="========================================================================"
for i in ${!chains_list[@]}; do
  chains[$i+1]=${chains_list[$i]}
done

timeOut(){
while true; do
    float=([1]='0.05' [2]='0.1' [3]='0.15' [4]='0.2' [5]='0.25' [6]='0.3' [7]='0.35' [8]='0.4' [9]='0.45' [10]='0.5')
    echo $bline
    for to in ${!float[@]}; do
        echo -e "[${to}]\t${float[$to]} Detik koneksi timeout"
    done
    echo $bline
    read -p "${hijau}${bold}Pilih timeout untuk menguji koneksi RPC.. ${reset}" p
    for x in ${!float[@]}; do
        case $p in
        $x) timeout=${float[$x]}; break;;
        esac
    done
    if [[ -n $timeout ]]; then
	clear
        break
    fi
done
}

while true; do
    clear
    PS3=$'\n'"${cyan}${bold}Pilih rantai yang akan di cari RPCnya..!${reset} "
    echo $bline
    echo -e "${cyan}${bold}List nama rantai yang terdaftar di cosmos chain registry total: ${#chains[@]}${reset}"
    echo $bline
    select name in ${chains[@]}; do
        network=$name
        break
    done
    for net in ${chains[@]}; do
        if [[ $net = $network ]]; then
	    clear
            public_rpc=($(curl -s $chains_registry_url/$net | jq -r '.chain.apis.rpc[].address'))
            for x in ${!public_rpc[@]}; do
		public[$x+1]=${public_rpc[$x]}
            done
	    while true; do
	        echo $bline
		echo -e "${cyan}${bold}List public RPC ${bg}${net}${reset}${cyan} total: ${#public[@]}${reset}"
		echo $bline
	        PS3=$'\n'"${cyan}${bold}Pilih public RPC ${bg}${net}${reset}${cyan} yang akan di cari list RPCnya..!${reset} "
        	select pub_rpc in ${public[@]}; do
	            pub_list=$pub_rpc
	            break
	        done
        	for pub in ${pub_list[@]}; do
	            if [[ $pub = $pub_list ]]; then
		        health=$(curl --connect-timeout 1.5 \
			         -s $pub/health 2>/dev/null | \
			         jq 2>/dev/null)
		        if [[ -n $health ]]; then
		            timeOut
	                    echo -e "\n${cyan}${bold}Mencari RPC ${bg}${net}${reset}${cyan}${bold} yang terhubung pada public RPC ${bg}${pub}${reset}..."
	                    list_rpc=($(curl -s $pub/net_info | \
	       		                jq -r '.result.peers[] | "\(.remote_ip):\(.node_info.other.rpc_address)"' | \
					awk -F ':' '{print $1":"$(NF)}'))
	                    for rpc in ${!list_rpc[@]}; do
			        rpc_status=$(curl -s ${list_rpc[$rpc]}/status \
	        		             --connect-timeout ${timeout} 2>/dev/null | \
	                     		     jq -r '.result | "\(.sync_info.catching_up)\t\t\(.node_info.other.tx_index)\t\t\(.node_info.moniker)"' 2>/dev/null)
		    	        if [[ -n $rpc_status ]]; then
	        		    rpc_active+=([$rpc]=${list_rpc[$rpc]})
		                    rpc_moniker+=([$rpc]=$rpc_status)
				    echo -e "[$rpc]\t${hijau}${bold}${list_rpc[$rpc]}${reset}\t✅️"
			        else
				    rpc_inactive+=([$rpc]=${list_rpc[$rpc]})
	        		    echo -e "[${rpc}]\t${merah}${bold}${list_rpc[$rpc]}${reset}\t❌️"
		                fi
		            done
		        else
			    echo -e "\n${merah}${bold}Hemm.. public RPC ${merah}${bg}${pub}${reset}${merah} tidak aktif coba pilih publik RPC yang lain..${reset}\n"
		        fi
		        if [[ -n ${rpc_active[@]} ]]; then
			    echo -e "\n${cyan}${bold}Di temukan RPC $network timeout connection $timeout total: ${#rpc_active[@]}${reset}"
			    sleep 1
	                    echo $bline
			    echo -e "${cyan}${bold}IP:PORT \t\tSyncing\t\tIndexer\t\tMoniker${reset}"
	                    echo $bline
		            for info in ${!rpc_active[@]}; do
		                echo -e "${rpc_active[$info]}\t${rpc_moniker[$info]}" | \
	        		sed "s|false|${hijau}${bold}false${reset}|; \
		                     s|true|${merah}${bold}true${reset}|; \
	        		     s|on|${hijau}${bold}on${reset}|; \
				     s|off|${merah}${bold}off${reset}|"
		            done
		            echo $bline
		            exit
		        elif [[ -n ${rpc_inactive[@]} ]]; then
		 	    echo -e "\n\e[33;1mHemm.. list RPC ${bg}${kuning}${net}${reset}${kuning}${bold} Yang terhubung pada public RPC ${bg}${pub}${reset}${kuning}${bold} Tidak ada yang aktif..."
			    echo -e "Coba tingkatkan durasi koneksi timeoutnya atau pilih public RPC yang lain${reset}....\n"
	                fi
	            fi
	        done
	    done
        fi
    done
done

