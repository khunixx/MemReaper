#!/bin/bash 

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m' # No Color

# Function to check if user is root
function CHECK () {
	echo
	echo -e "${RED}[*] Function (1) CHECK${RESET}"
	# Check if the user is root
	if [ "$(whoami)" != "root" ]; then
		echo -e "[-] Must be ${RED}root${RESET} to run, exiting now..."
		exit 1
	else
		echo -e "[+] You are ${RED}root${RESET}, continuing..."
	fi
	
	# Check if the file exists
	while true; do
		read -p "[*] Enter the full path to the file you wish to analyze: " FILE
		if [ -f "$FILE" ]; then
			echo -e "[+] File ${RED}exists${RESET}, continuing..."
			break
		else
			echo -e "[-] File does ${RED}not${RESET} exist, please enter a valid file name." 
		fi
	done

	# Checking for system updates  
	read -p "[?] Have you updated your machine today? (y/n) " ANSWER
	if [ "$ANSWER" == "y" ]; then 
		echo -e "[+] The machine is ${RED}updated${RESET}"
	else 
		sudo apt-get update > /dev/null 2>&1
	fi

	# Function to check if a package is installed
	function CHECK_PACKAGE () {
		dpkg -l | grep -qw "$1"
		return $?
	}

	# Checking and installing necessary tools
	tools=("binwalk" "foremost" "bulk-extractor" "strings")
	for i in "${tools[@]}"; do 
		if CHECK_PACKAGE "$i"; then
			echo -e "[+] ${RED}$i${RESET} is installed"
		else 
			echo "[*] Installing $i..."
			sudo apt-get install -y "$i"
		fi
	done

	# Function to check if volatility is installed and install if not
	function VOL_INSTALL () {
		if command -v vol &> /dev/null; then
			echo -e "[+] ${RED}Volatility${RESET} is installed"
			echo -e "[!] Please change the volatility executable's name to ${RED}vol${RESET} and copy it to the ${RED}current${RESET} directory for the script to work"
			read -p "[*] Press Enter to continue once it's done: " CONTINUE
		else
		echo "Installing Volatility..."
		sudo apt update
		sudo apt install -y python2 python2-dev
	git clone https://github.com/volatilityfoundation/volatility.git
	cd volatility
	python2 setup.py install
	cd ..
		echo -e "[!] Please change the volatility executable's name to ${RED}vol${RESET} and copy it to the ${RED}current${RESET} directory for the script to work"
		read -p "[*] Press Enter to continue once it's done: " CONTINUE
	fi
}

VOL_INSTALL
}


# Function to create a directory for results
function DIR () {
	echo
	echo -e "${PURPLE}[*] Function (2) DIR${RESET}"
	while true; do
		read -p "[*] Please enter the name of the directory you wish to create. All results will be saved in this directory: " OUT_DIR
		read -p "[?] You have chosen the name $OUT_DIR. Is this input correct? (y/n): " ANS
		if [[ $ANS == "y" || $ANS == "Y" ]]; then
			if [[ -d "$OUT_DIR" ]]; then
				echo -e "[-] Directory $OUT_DIR ${PURPLE}already exists.${RESET} Please choose another name."
			else
				echo -e "[*] Creating the directory ${PURPLE}$OUT_DIR${RESET}"
				mkdir "$OUT_DIR"
				cd "$OUT_DIR" 
				break
			fi
		elif [[ $ANS == "n" || $ANS == "N" ]]; then
			echo "[-] Input is incorrect. Please try again."
		else
			echo "[-] Invalid answer. Please type 'y' or 'n'."
		fi
	done
	cp ../vol .
	CURRENT_PATH=$(pwd)

}



function BULK () {
echo
echo -e "${BLUE}[*] Function (3) BULK${RESET}"
echo -e "[*] Extracting information using ${BLUE}bulk extractor${RESET}"
mkdir bulk
bulk_extractor $FILE -o $CURRENT_PATH/bulk/bulk_output > /dev/null 2>&1

echo -e "[*] All bulk_extractor information will be stored inside the ${BLUE}bulk_output${RESET} folder inside the bulk directory."
echo -e "[*] Sorting the bulk_extractor most relevant information into the ${BLUE}bulk${RESET} directory."
echo -e "[*] Sorting the ${BLUE}urls${RESET}"
cat $CURRENT_PATH/bulk/bulk_output/url.txt | awk '{print $2}' | sort | uniq -c | sort -n > $CURRENT_PATH/bulk/url.txt
echo -e "[*] Sorting the ${BLUE}searches${RESET}"
cat $CURRENT_PATH/bulk/bulk_output/url_searches.txt | grep search > $CURRENT_PATH/bulk/searches.txt
echo -e "[*] Sorting the ${BLUE}domains${RESET}"
cat $CURRENT_PATH/bulk/bulk_output/domain_histogram.txt | awk 'NR > 5 {print $0}' > $CURRENT_PATH/bulk/domains.txt
echo -e "[*] Sorting the ${BLUE}ccn${RESET}"
cat $CURRENT_PATH/bulk/bulk_output/ccn.txt | awk 'NR > 5 {print $2}' > $CURRENT_PATH/bulk/ccn.txt
echo -e "[*] Sorting the ${BLUE}emails${RESET}"
cat $CURRENT_PATH/bulk/bulk_output/email_histogram.txt | awk 'NR > 5 {print $2}' > $CURRENT_PATH/bulk/email.txt 
# checking if the pcap file exists and if it does saving it in the bulk directory
if [ -f $CURRENT_PATH/bulk/bulk_output/packets.pcap ]
then 
echo -e "[+] ${BLUE}Found Network File${RESET}" 
echo -e "[*] Copying the Network File to the ${BLUE}bulk${RESET} directory"
echo -e "[*] Pcap file size: ${BLUE}$(ls -lh $CURRENT_PATH/bulk/bulk_output | grep packets.pcap | awk '{print $5}')${RESET}"
cp $CURRENT_PATH/bulk/bulk_output/packets.pcap $CURRENT_PATH/bulk
fi
}

function STRINGS () {
# Saving the strings output
echo
echo -e "${CYAN}[*] Function (4) STRINGS${RESET}"
echo -e "[*] Saving the strings results in the ${CYAN}strings${RESET} directory"
mkdir strings
strings $FILE > $CURRENT_PATH/strings/strings_output

# Filtering the strings output and saving each result in its on file on the directory
echo -e "[*] Saving the ${CYAN}IP${RESET} results"
strings $FILE | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq -c | sort -n > $CURRENT_PATH/strings/strings_IP

echo -e "[*] Saving the ${CYAN}email${RESET} results"
strings $FILE | grep -Eo '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort | uniq -c | sort -n > $CURRENT_PATH/strings/strings_emails

# A loop that filters for passwords, usernames etc.
SEARCH="username password http exe"

for i in $SEARCH
do
echo -e "[*] Saving the ${CYAN}$i${RESET} results"
strings $FILE | grep -i $i | sort | uniq -c | sort -n > $CURRENT_PATH/strings/strings_$i
done
}

function FOREMOST () {
	echo 
	echo -e "${GREEN}[*] Function (5) FOREMOST${RESET}"
	echo -e "[*] Saving the foremost results in the ${GREEN}foremost${RESET} directory"
	foremost $FILE -o $CURRENT_PATH/foremost > /dev/null 2>&1
}


function BINWALK () {
	echo 
	echo -e "${YELLOW}[*] Function (6) BINWALK${RESET}"
echo -e "[*] Saving the binwalk results in the ${YELLOW}binwalk${RESET} directory"
mkdir binwalk
binwalk $FILE > $CURRENT_PATH/binwalk/binwalk.txt
}


function VOLATILITY () {
	echo 
	echo -e "${RED}[*] Function (7) VOLATILITY${RESET}"
	mkdir -p volatility/registry/registry_dump
	# Checking if the file can be analyzed using volatility.
if [ -z "$(./vol -f $FILE imageinfo /dev/null 2>&1 | grep 'Suggested Profile' | grep 'No suggestion')" ] 
then
	echo -e "[+] This is a ${RED}memory file${RESET}, proceeding with the analysis" 
else 
	echo -e "[-] This is ${RED}not${RESET} a memory file!"
fi

# Finding out the profile of the memory file.
PRO=$(./vol -f $FILE imageinfo /dev/null 2>&1 | grep Suggested | awk '{print $4}' | sed 's/,//g')
echo -e "[*] The found profile is: ${RED}$PRO${RESET}"


# Saving the running processes.
echo -e "[*] Saving the ${RED}running processes${RESET}"
./vol -f $FILE --profile=$PRO pslist > /dev/null 2>&1 > $CURRENT_PATH/volatility/data_pslist

# Saving the network connections 
function NET() {
    
   echo -e "[*] Saving the ${RED}network connections${RESET}"

 ERROR=$(./vol -f "$FILE" --profile="$PRO" sockets 2>&1 > /dev/null | grep "This command does not support the profile")

  
    if [ -z "$ERROR" ]; then
        ./vol -f "$FILE" --profile="$PRO" sockets > /dev/null 2>&1 > /$CURRENT_PATH/volatility/data_net
    else
       
        ./vol -f "$FILE" --profile="$PRO" netscan > /dev/null 2>&1 > /$CURRENT_PATH/volatility/data_net
    fi

}


NET

# Saving the hive list
./vol -f $FILE --profile=$PRO hivelist > /dev/null 2>&1 > $CURRENT_PATH/volatility/registry/hivelist
echo -e "[*] Dumping the ${RED}registries${RESET} in the ${RED}registry_dump${RESET} directory"
./vol -f $FILE --profile=$PRO dumpregistry -D $CURRENT_PATH/volatility/registry/registry_dump > /dev/null 2>&1

echo -e "[*] Gathering ${RED}registry${RESET} information"


echo "Registry information:" > $CURRENT_PATH/volatility/registry/registry_info

# Saving different registry information such as users, IP adresses etc.
cat <<EOF >> $CURRENT_PATH/volatility/registry/registry_info
1) Programs that are set to run when any user logs in:
$(./vol -f $FILE --profile=$PRO printkey -K "Software\Microsoft\Windows\CurrentVersion\Run" /dev/null 2>&1)

2) IP addresses assigned to network interfaces:
$(./vol -f $FILE --profile=$PRO printkey -K "SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /dev/null 2>&1)

3) User list:
$(./vol -f $FILE --profile=$PRO printkey -K "SAM\Domains\Account\Users\Names" /dev/null 2>&1)

4) Programs set to run at startup:
$(./vol -f $FILE --profile=$PRO printkey -K "Software\Microsoft\Windows\CurrentVersion\Run" /dev/null 2>&1)

5) System build, version and installation date details
$(./vol -f $FILE --profile=$PRO printkey -K "SOFTWARE\Microsoft\Windows NT\CurrentVersion" /dev/null 2>&1)

6) Configured time zone:
$(./vol -f $FILE --profile=$PRO printkey -K "SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /dev/null 2>&1)

7) Computer name
$(./vol -f $FILE --profile=$PRO printkey -K "SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /dev/null 2>&1) 
EOF
}

function STATS () {
	echo
	echo -e "${PURPLE}[*] Function (8) STATS${RESET}"
	echo "[*] Saving statistics..."

# Saving the statistics in a file
echo "Statistics:" > $CURRENT_PATH/stats

# Record the time of analysis and memory file information
{
    echo "Time of analysis: $(date)"
    echo "Size of memory file: $(ls -l "$FILE" | awk '{print $5 / 1024 " KB"}')"
    echo "Date and time of the memory file: $(./vol -f "$FILE" imageinfo 2>&1 | grep "Image date and time" | awk '{print $6, $7, $8}')"
} >> $CURRENT_PATH/stats

# Saving the statistics of foremost
OUTDIR="$CURRENT_PATH/foremost"

for dir in "$OUTDIR"/*/; do
    if [ -d "$dir" ]; then
        type=$(basename "$dir")
        COUNT=$(find "$dir" -type f | wc -l)
        SIZE=$(du -sb "$dir" | awk '{print $1}')
        
        # Calculating average file size
        if [ "$COUNT" -gt 0 ]; then
            AVSIZE=$((SIZE / COUNT))
        else
            AVSIZE=0
        fi


        {
            echo 
            echo "Directory: $type"
            echo "  Number of files: $COUNT"
            echo "  Total size: $(du -sh "$dir" | cut -f1)"
            echo "  Average file size: $AVSIZE bytes"
            echo ""
        } >> $CURRENT_PATH/stats
    fi
done
}

function ZIP () {
	echo
	echo -e "${BLUE}[*] Function (9) ZIP${RESET}"
	echo "[*] Zipping the file"
	cd ..
	zip -r $OUT_DIR.zip $OUT_DIR > /dev/null 2>&1
}

CHECK
DIR
BULK
STRINGS
FOREMOST
BINWALK	
VOLATILITY
STATS
ZIP
