# MemReaper
**Memory Analysis & Forensics Tool for Linux**

MemReaper is a powerful Bash script designed for analyzing memory dump files and extracting forensic data using tools like `Volatility`, `binwalk`, `foremost`, `bulk-extractor`, and `strings`.

## Features
✅ User-friendly interface  
✅ Automated dependency check and installation  
✅ Memory dump analysis using Volatility  
✅ Bulk data extraction for URLs, emails, and domains  
✅ Organized output directories for clean results  
✅ Generates detailed statistics for forensic insights  

## Requirements
- Linux (Tested on Kali Linux)
- `python2`, `binwalk`, `foremost`, `bulk-extractor`, `strings`, `Volatility`
- `git`, `zip`

## Installation
Clone the repository and make the script executable:
```bash
git clone https://github.com/yourusername/MemReaper.git
cd MemReaper
chmod +x memreaper.sh
```

## Usage
Run the script with:
```bash
sudo ./memreaper.sh
```

## Output
- Extracted data is stored in a structured directory.
- Results include process lists, network connections, registry dumps, and forensic metadata.

## License
This project is licensed under the MIT License.
