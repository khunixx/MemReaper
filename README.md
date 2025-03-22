# MemReaper
**Memory Analysis & Forensics Tool for Linux**

MemReaper is a Bash-based memory analysis tool designed for forensic investigations. It automates memory dump extraction, process enumeration, registry analysis, and data recovery using well-known forensic tools such as `Volatility`, `foremost`, `binwalk`, and `bulk-extractor`.

---

## Table of Contents
- [About](#about)
- [Supported Linux Distributions](#supported-linux-distributions)
- [Required Packages](#required-packages)
- [Installation Guide](#installation-guide)
- [Usage](#usage)
- [Features](#features)
- [Project Structure](#project-structure)
- [License](#license)

---

## About
MemReaper automates various forensic tasks, including extracting process lists, network connections, registry data, and file signatures from a memory dump. It generates structured outputs to aid forensic investigators.

### **Key Capabilities:**
- Automated memory forensics with **Volatility**
- Bulk extraction of **URLs, emails, and domains**
- Organized results for easier forensic review
- Supports common forensic tools such as **foremost, binwalk, and bulk-extractor**
- Generates **statistics and structured output directories**

---

## Supported Linux Distributions
MemReaper has been tested on:

- **Kali Linux** (Rolling Release)
- **Ubuntu** (20.04 LTS or later)
- **Debian** (11 or later)

Other Debian-based distributions should work but may require manual package installation.

---

## Required Packages
The following external tools are required:

- `Volatility` - For memory forensics
- `foremost` - File carving
- `binwalk` - Binary analysis
- `bulk-extractor` - Data extraction (emails, URLs, CCNs)
- `strings` - Extract human-readable text from files

If the script detects missing tools, it will attempt to install them automatically.

---

## Installation Guide

### **Clone the Repository**
```bash
git clone https://github.com/yourusername/MemReaper.git
```

### **Navigate to the Project Directory**
```bash
cd MemReaper
```

### **Make the Script Executable**
```bash
chmod +x memreaper.sh
```

### **Install Required Packages (if needed)**
```bash
sudo apt-get update
sudo apt-get install python2 binwalk foremost bulk-extractor strings git zip
```

---

## Usage

### **Run the Script**
```bash
sudo ./memreaper.sh
```

### **What Happens?**

1. **Root Check & Package Installation**
   - Ensures script is run as root.
   - Installs missing packages.

2. **Input Phase**
   - Prompts for a directory name to store results.
   - Asks for the target memory dump file.

3. **Memory Analysis**
   - Extracts **running processes**, **network connections**, and **registry data**.
   - Uses **Volatility** for deep memory forensics.

4. **Data Extraction**
   - Bulk-extracts **emails, domains, URLs, CCNs** using **bulk-extractor**.
   - Recovers **files and artifacts** using **foremost**.

5. **Results & Archiving**
   - Saves structured outputs in organized directories.
   - Offers to **zip the results** for easy sharing.

---

## Features

✅ **Automated Memory Forensics** - Runs multiple forensic operations with one command  
✅ **Supports Multiple Tools** - Integrates `Volatility`, `foremost`, `binwalk`, and `bulk-extractor`  
✅ **Structured Output** - Organizes results into well-defined folders  
✅ **Statistics & Reporting** - Generates forensic statistics for better insights  
✅ **Zip Archive Option** - Allows easy sharing of forensic findings  

---

## Project Structure

```
MemReaper/
│
├── memreaper.sh              # Main script
├── README.md                 # Documentation
├── LICENSE                   # License file
└── output/                   # Directory for extracted results
```

---

## License

This project is licensed under the **MIT License**.

