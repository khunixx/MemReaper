# MemReaper  

MemReaper is a powerful **memory forensics** tool designed to extract, analyze, and investigate digital artifacts from memory dumps. By leveraging **Volatility, binwalk, foremost, bulk_extractor, and strings**, it automates forensic data collection and organizes key findings into structured directories.  

This tool is designed for **cybersecurity professionals, forensic analysts, and incident responders** who need to extract **registry data, network connections, running processes, and hidden artifacts** from memory images.  

---

## Table of Contents  

1. [Overview](#overview)  
2. [Features](#features)  
3. [Prerequisites](#prerequisites)  
4. [Tested On](#tested-on)  
5. [Usage](#usage)  
6. [Script Workflow](#script-workflow)  
7. [Disclaimer](#disclaimer)  

---

## Overview  

MemReaper automates the forensic process by:  

- Checking **root privileges** and ensuring the system is up to date.  
- Extracting **useful forensic artifacts** from a memory dump.  
- Organizing artifacts into structured **directories** for easy analysis.  
- Using **Volatility** to analyze running processes, registry data, and network connections.  
- Extracting files from memory using **foremost** and **binwalk**.  

### Use Cases:  

- **Incident Response** – Investigate memory dumps from compromised machines.  
- **Digital Forensics** – Extract and analyze artifacts from live memory captures.  
- **Threat Hunting** – Identify malware persistence mechanisms and hidden processes.  

---

## Prerequisites  

This script checks for and installs the following tools if they are not already present:  

- **Volatility** – Memory analysis framework.  
- **foremost** – File carving tool.  
- **binwalk** – Extracts embedded files.  
- **bulk_extractor** – Extracts digital artifacts.  
- **strings** – Extracts readable text from binary files.  

> **Note**: The script uses `apt-get` for package installation and is primarily tested on **Debian/Ubuntu-based** systems.  

---

## Tested On  

- **Kali Linux** (Debian-based)  
- **Ubuntu 20.04+**  

---

## Usage  

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/khunixx/MemReaper.git
   cd MemReaper
   ```

2. **Make the Script Executable**  
   ```bash
   chmod +x MemReaper.sh
   ```

3. **Run the Script**  
   ```bash
   sudo ./MemReaper.sh
   ```

4. **Follow the Prompts**  
   - Provide the **path to the memory dump** when asked.  
   - MemReaper will **detect the memory profile** and extract relevant forensic data.  
   - The results will be stored inside the **`/project/`** directory.  

---

## Script Workflow  

1. **CHECK** – Ensures root access and verifies memory dump file.  
2. **INSTALLATION CHECK** – Ensures all forensic tools are installed.  
3. **MEMORY DUMP ANALYSIS** – Uses **Volatility** to extract process, network, and registry data.  
4. **FILE & STRING EXTRACTION** – Uses **foremost, binwalk, and bulk_extractor** to extract hidden files, emails, and passwords.  
5. **LOGGING & REPORTING** – Generates an audit log and saves extracted data into structured folders.  

---

 
