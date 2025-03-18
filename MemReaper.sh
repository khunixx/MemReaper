#!/bin/bash 

function CHECK () {
	# Check the current user; exit if not ‘root’
	if [ "$(whoami)" != "root" ]
	then
		echo "Must be root to run, exiting now..."
		exit
	else
		echo "You are root, continuing..."
	fi
	
	# Check if the file exists
	
	while true; do
	read -p "[*] Enter the full path to the file you wish to analyze: " FILE
	if [ -f "$FILE" ]
	then
	echo "File exists, continuing..."
	break
	else
	echo "File does not exist, please enter a valid file name" 
	fi
	done
	}
CHECK


# Checking for update  
read -p "Have you updated your machine today? (y/n) " ANSWER
if [ "$ANSWER" == "y" ];
then 
        echo -e "The machine is updated"
else 
sudo apt-get update  > /dev/null 2>&1
fi

# Function to check if a package is installed
CHECK-PACKAGE () {
        dpkg -l | grep -qw "$1"
        return $?
}

sleep 1


# checking if bulk-extractor, strings, binwalk and foremost are installed  and if not installs them.

tools="binwalk foremost bulk-extractor strings"
for i in $tools; do 
if CHECK-PACKAGE $i; then
        echo "$i is installed"
else 
        echo "Installing $i..."
sudo apt-get install $i
fi
sleep 1
done

# Function to check if volatility is installed and if not, installs it.

function VOL () {

if [[ -f /home/kali/Desktop/vol ]]; then
    echo "Volatility is installed"
else
    echo "Intalling Volatility"
    sudo apt install python2 python2-pip git -y
        
        git clone https://github.com/volatilityfoundation/volatility.git
        cd volatility
        
        sudo python2 setup.py install
fi
}

VOL



# Creating a bulk_extractor directory and deleting it if it already exists.
rm -rf /home/kali/Desktop/project
rm -rf /home/kali/Desktop/project/bulk
mkdir /home/kali/Desktop/project
mkdir /home/kali/Desktop/project/bulk

# Extracting and sorting different bulk_extractor results such as emails, domains etc.
echo "[*] Extracting information using bulk extractor"
bulk_extractor $FILE -o /home/kali/Desktop/project/bulk/bulk_output > /dev/null 2>&1
echo "[*] All bulk_extractor informatio will be stored inside the output folder located inside the project directory"
echo "[*] Sorting the bulk_extractor most relevant information into the bulk_res folder inside the project directory"
cd /home/kali/Desktop/project/bulk/bulk_output 
echo "[*] Sorting the urls"
cat url.txt | awk '{print $2}' | sort | uniq -c | sort -n > /home/kali/Desktop/project/bulk/url.txt
echo "[*] Sorting the searches"
cat url_searches.txt | grep search > /home/kali/Desktop/project/bulk/searches.txt
echo "[*] Sorting the domains"
cat domain_histogram.txt | awk 'NR > 5 {print $0}' > /home/kali/Desktop/project/bulk/domains.txt
echo "[*] Sorting the ccn"
cat ccn.txt | awk 'NR > 5 {print $2}' > /home/kali/Desktop/project/bulk/ccn.txt
echo "[*] Sorting the emails"
cat email_histogram.txt | awk 'NR > 5 {print $2}' > /home/kali/Desktop/project/bulk/email.txt 

# checking if the pcap file exists and if it does saving it in the bulk directory
if [ -f /home/kali/Desktop/project/bulk/bulk_output/packets.pcap ]
then 
echo "[*] Found Network File" 
echo "[*] Copying the Network File to the bulk directory"
echo "[*] Pcap file size: $(ls -lh /home/kali/Desktop/project/bulk/bulk_output | grep packets.pcap | awk '{print $5}')"
cp /home/kali/Desktop/project/bulk/bulk_output/packets.pcap /home/kali/Desktop/project/bulk
fi

rm -rf /home/kali/Desktop/project/strings
mkdir /home/kali/Desktop/project/strings

# Saving the strings output
echo "[*] Saving the strings results in the strings directory"
strings $FILE > /home/kali/Desktop/project/strings/strings_out

# Filtering the strings output and saving each result in its on file on the directory
echo "[*] Saving the IP results"
strings $FILE | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq -c | sort -n > /home/kali/Desktop/project/strings/strings_IP

echo "[*] Saving the email results"
strings $FILE | grep -Eo '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort | uniq -c | sort -n > /home/kali/Desktop/project/strings/strings_emails

# A loop that filters for passwords, usernames etc.
SEARCH="username password http exe"

for i in $SEARCH
do
echo "[*] Saving the $i results"
strings $FILE | grep -i $i | sort | uniq -c | sort -n > /home/kali/Desktop/project/strings/strings_$i
done

# Saving the foremost output in its own directory
rm -rf /home/kali/Desktop/project/foremost
echo "[*] Saving the foremost results in the foremost directory"
foremost $FILE -o /home/kali/Desktop/project/foremost > /dev/null 2>&1

# Saving the binwalk output in its own directory.
rm -rf /home/kali/Desktop/project/binwalk
mkdir /home/kali/Desktop/project/binwalk
echo "[*] Saving the binwalk results in the binwalk directory"
cd /home/kali/Desktop/project/binwalk
binwalk $FILE > binwalk.txt


# Creating a folder for the volatility results and deletes it if it already exists.
cd /home/kali/Desktop
rm -rf /home/kali/Desktop/project/vol
mkdir /home/kali/Desktop/project/vol


# Checking if the file can be analyzed using volatility.
if [ -z "$(./vol -f $FILE imageinfo /dev/null 2>&1 | grep 'Suggested Profile' | grep 'No suggestion')" ] 
then
	echo "[*] This is a memory file, proceeding with the analysis" 
else 
	echo "This is not a memory file!"
fi

# Finding out the profile of the memory file.
PRO=$(./vol -f $FILE imageinfo /dev/null 2>&1 | grep Suggested | awk '{print $4}' | sed 's/,//g')
echo "[*] The found profile is: $PRO"


# Saving the running processes.
echo "[*] Saving the running processes"
./vol -f $FILE --profile=$PRO pslist > /dev/null 2>&1 > /home/kali/Desktop/project/vol/data_pslist

# Saving the network connections 
function NET() {
    
    echo "[*] Saving the network connections"

    ERROR=$(./vol -f "$FILE" --profile="$PRO" sockets 2>&1 > /dev/null | grep "This command does not support the profile")

  
    if [ -z "$ERROR" ]; then
        ./vol -f "$FILE" --profile="$PRO" sockets > /dev/null 2>&1 > /home/kali/Desktop/project/vol/data_net
    else
       
        ./vol -f "$FILE" --profile="$PRO" netscan > /dev/null 2>&1 > /home/kali/Desktop/project/vol/data_net
    fi
}


NET

# Creating a registry folder inside the vol folder and deleting if it already exists.
rm -rf /home/kali/Desktop/project/vol/registry
mkdir /home/kali/Desktop/project/vol/registry

# Saving the hive list
./vol -f $FILE --profile=$PRO hivelist > /dev/null 2>&1 > /home/kali/Desktop/project/vol/registry/hivelist

mkdir /home/kali/Desktop/project/vol/registry/registry_dump
echo "[*] Dumping registries in the registry dump directory"
./vol -f $FILE --profile=$PRO dumpregistry -D /home/kali/Desktop/project/vol/registry/registry_dump > /dev/null 2>&1

echo "[*] Gathering registry information"


echo "Registry information:" > /home/kali/Desktop/project/vol/registry/registry_info

# Saving different registry information such as users, IP adresses etc.
cat <<EOF >> /home/kali/Desktop/project/vol/registry/registry_info
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

cd /home/kali/Desktop

echo "[*] Saving statistics..."

# Saving the statistics in a file
STATS_FILE="/home/kali/Desktop/project/stats"
echo "Statistics:" > "$STATS_FILE"

# Record the time of analysis and memory file information
{
    echo "Time of analysis: $(date)"
    echo "Size of memory file: $(ls -l "$FILE" | awk '{print $5 / 1024 " KB"}')"
    echo "Date and time of the memory file: $(./vol -f "$FILE" imageinfo 2>&1 | grep "Image date and time" | awk '{print $6, $7, $8}')"
} >> "$STATS_FILE"

# Saving the statistics of foremost
OUTDIR="/home/kali/Desktop/project/foremost"

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
        } >> "$STATS_FILE"
    fi
done


zip -r project.zip /home/kali/Desktop/project > /dev/null 2>&1
