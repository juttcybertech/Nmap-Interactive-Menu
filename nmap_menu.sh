#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m' 
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Bold Colors
B_RED='\033[1;31m'
B_GREEN='\033[1;32m'
B_YELLOW='\033[1;33m'
B_BLUE='\033[1;34m'
B_CYAN='\033[1;36m'

# Function to display banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
                        ╔═══════════════════════════════════════════════╗
                        ║             Nmap Interactive Menu             ║
                        ║      An Easy-to-Use Nmap Scanning Tool        ║
                        ║    For Network Exploration & Security Audits  ║
                        ║                                               ║
                        ╚═══════════════════════════════════════════════╝
                        Developed by Jutt Cyber Tech 
EOF
    echo -e "${NC}"
}

# Function to check if nmap is installed
check_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo -e "${RED}Error: Nmap is not installed!${NC}"
        echo "Please install nmap first:"
        echo "  Ubuntu/Debian: sudo apt-get install nmap"
        echo "  CentOS/RHEL: sudo yum install nmap"
        echo "  MacOS: brew install nmap"
        exit 1
    fi
}

# Function to get target
get_target() {
    echo -e "${B_YELLOW}Enter target (IP address, hostname, or IP range):${NC}"
    read -p "$(echo -e "${B_CYAN}Target:${NC} ")" target
    if [ -z "$target" ]; then
        echo -e "${RED}No target specified!${NC}"
        return 1
    fi
    echo ""
}

# Function to pause and wait for user
pause() {
    echo ""
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read
}

# Function to ask the user if they want to save the scan output
ask_to_save() {
    local scan_output="$1"
    local default_target="$2"
    local output_dir="nmap_results"

    # Don't ask to save if there was no output (e.g., invalid target)
    if [ -z "$scan_output" ]; then
        return
    fi

    echo ""
    read -p "$(echo -e "${B_YELLOW}Do you want to save the output to a file? (y/n):${NC} ")" save_choice

    if [[ "$save_choice" == "y" || "$save_choice" == "Y" ]]; then
        # Create the output directory if it doesn't exist
        if [ ! -d "$output_dir" ]; then
            echo -e "${GREEN}Creating output directory: $output_dir${NC}"
            mkdir "$output_dir"
        fi

        local safe_target_name=$(echo "$default_target" | tr -c '[:alnum:]._-' '_')
        local filename="scan_${safe_target_name}_$(date +%Y%m%d_%H%M%S).txt"
        local output_path="$output_dir/$filename"

        # Save the output and append the developer credit line
        echo -e "${BLUE}Saving output to $output_path...${NC}"
        echo "$scan_output" > "$output_path"
        echo -e "\nDeveloped by Jutt Studio — Created by JS" >> "$output_path"
        echo -e "${GREEN}Scan output saved to: $output_path${NC}"
    fi
}

# Main menu
show_menu() {
    show_banner
    echo -e "${GREEN}Select a scanning option:${NC}"
    echo -e "\n${B_YELLOW}Basic Scans:${NC}"
    echo -e "  ${B_BLUE}1)${NC} ⚡ Quick Scan (Top 100 ports)"
    echo -e "  ${B_BLUE}2)${NC} 🎯 Standard Scan (Top 1000 ports)"
    echo -e "  ${B_BLUE}3)${NC} 🌐 Full Port Scan (All 65535 ports)"
    echo -e "  ${B_BLUE}4)${NC} 🏓 Ping Scan (Host discovery only)"
    echo -e "\n${B_YELLOW}Advanced Scans:${NC}"
    echo -e "  ${B_BLUE}5)${NC} ℹ️  Service Version Detection"
    echo -e "  ${B_BLUE}6)${NC} 💻 OS Detection"
    echo -e "  ${B_BLUE}7)${NC} 🚀 Aggressive Scan (OS, Version, Scripts, Traceroute)"
    echo -e "  ${B_BLUE}8)${NC} 👻 Stealth Scan (SYN scan)"
    echo -e "\n${B_YELLOW}Specific Scans:${NC}"
    echo -e "  ${B_BLUE}9)${NC} 💧 UDP Scan"
    echo -e "  ${B_BLUE}10)${NC} 📌 Specific Port Scan"
    echo -e "  ${B_BLUE}11)${NC} 🐞 Vulnerability Scan (with scripts)"
    echo -e "  ${B_BLUE}12)${NC} 🏃 Fast Scan (Limited ports, fast timing)"
    echo -e "\n${B_YELLOW}Special Options:${NC}"
    echo -e "  ${B_BLUE}13)${NC} 💾 Scan with Output to File"
    echo -e "  ${B_BLUE}14)${NC} 🌐 Scan Entire Subnet"
    echo -e "  ${B_BLUE}15)${NC} 🤝 TCP Connect Scan"
    echo -e "  ${B_BLUE}16)${NC} 🛡️  Firewall/IDS Evasion Scan"
    echo -e "  ${B_BLUE}17)${NC} 📍 ARP Discovery Scan (LAN only)"
    echo -e "  ${B_BLUE}18)${NC} 📋 List Scan (List targets)"
    echo -e "\n${B_YELLOW}Advanced Techniques:${NC}"
    echo -e "  ${B_BLUE}19)${NC} 🚫 No Ping Scan (-Pn, assumes host is up)"
    echo -e "  ${B_BLUE}20)${NC} 🧟 Idle Scan (-sI, uses a zombie host)"
    echo -e "  ${B_BLUE}21)${NC} 📜 Custom NSE Script Scan"
    echo -e "  ${B_BLUE}22)${NC} 💥 All-in-One Comprehensive Scan"
    echo -e "  ${B_RED}23)${NC} 🔓 Brute-Force Attack (NSE)"
    echo ""
    echo -e "  ${B_RED}24) 🚪 Exit${NC}"
    echo ""
    echo -e "${CYAN}========================================================${NC}"
}

# Scan functions
scan_quick() {
    get_target || return


    local output
    echo -e "${BLUE}Running Quick Scan on $target (FAST MODE)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -F -T4 --min-rate=1000 --max-retries=2 $target"
    echo ""

    output=$(sudo nmap -F -T4 --min-rate=1000 --max-retries=2 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_standard() {
    get_target || return


    local output
    echo -e "${BLUE}Running Standard Scan on $target (FAST MODE)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -T4 --min-rate=1000 --max-retries=2 $target"
    echo ""

    output=$(sudo nmap -T4 --min-rate=1000 --max-retries=2 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_full() {
    get_target || return


    local output
    echo -e "${BLUE}Running Full Port Scan on $target (ULTRA FAST - Parallel Workers)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -p- -T4 --min-rate=5000 --max-retries=1 --min-parallelism=100 $target"
    echo ""

    output=$(sudo nmap -p- -T4 --min-rate=5000 --max-retries=1 --min-parallelism=100 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_ping() {
    get_target || return


    local output
    echo -e "${BLUE}Running Ping Scan on $target (FAST MODE)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -sn -T4 --min-parallelism=100 $target"
    echo ""

    output=$(sudo nmap -sn -T4 --min-parallelism=100 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_version() {
    get_target || return


    local output
    echo -e "${BLUE}Running Service Version Detection on $target (FAST MODE)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -sV -T4 --version-intensity 5 --min-rate=1000 $target"
    echo ""

    output=$(sudo nmap -sV -T4 --version-intensity 5 --min-rate=1000 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_os() {
    get_target || return

    local output
    echo -e "${BLUE}Running OS Detection on $target (with Guessing)...${NC}"
    echo -e "${B_CYAN}Command:${NC} sudo nmap -O --osscan-guess -T4 --min-rate=1000 $target"
    echo ""
    # --osscan-guess tells Nmap to guess the OS if it can't find a perfect match
    output=$(sudo nmap -O --osscan-guess -T4 --min-rate=1000 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_aggressive() {
    get_target || return


    local output
    echo -e "${BLUE}Running Aggressive Scan on $target (FAST MODE)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -A -T4 --min-rate=1000 --max-retries=2 $target"
    echo ""

    output=$(sudo nmap -A -T4 --min-rate=1000 --max-retries=2 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_stealth() {
    get_target || return


    local output
    echo -e "${BLUE}Running Stealth SYN Scan on $target (FAST MODE)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -sS -T4 --min-rate=1000 --max-retries=2 --min-parallelism=100 $target"
    echo ""

    output=$(sudo nmap -sS -T4 --min-rate=1000 --max-retries=2 --min-parallelism=100 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_udp() {
    get_target || return


    local output
    echo -e "${BLUE}Running UDP Scan on $target (FAST MODE - Top ports only)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -sU -F -T4 --max-retries=1 $target"
    echo ""

    output=$(sudo nmap -sU -F -T4 --max-retries=1 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_specific_port() {
    get_target || return
    echo -e "${B_YELLOW}Enter port(s) to scan (e.g., 80 or 80,443 or 1-1000):${NC}"
    read -p "$(echo -e "${B_CYAN}Ports:${NC} ")" ports
    if [ -z "$ports" ]; then
        echo -e "${RED}No ports specified!${NC}"
        pause
        return
    fi


    local output
    echo -e "${BLUE}Running Port Scan on $target for ports $ports (FAST MODE)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -p $ports -T4 --min-rate=1000 --max-retries=2 $target"
    echo ""
    output=$(sudo nmap -p "$ports" -T4 --min-rate=1000 --max-retries=2 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_vuln() {
    get_target || return
    local output
    echo -e "${BLUE}Running Vulnerability Scan on $target (FAST MODE)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap --script vuln -T4 --min-rate=1000 $target"
    echo ""
    output=$(sudo nmap --script vuln -T4 --min-rate=1000 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_fast() {
    get_target || return
    local output
    echo -e "${BLUE}Running ULTRA Fast Scan on $target...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -F -T5 --min-rate=2000 --max-retries=1 --min-parallelism=100 $target"
    echo ""
    output=$(sudo nmap -F -T5 --min-rate=2000 --max-retries=1 --min-parallelism=100 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_output() {
    get_target || return
    echo -e "${B_YELLOW}Enter output filename (without extension):${NC}"
    read -p "$(echo -e "${B_CYAN}Filename:${NC} ")" filename
    if [ -z "$filename" ]; then
        filename="nmap_scan_$(date +%Y%m%d_%H%M%S)"
    fi
    echo -e "${BLUE}Running Scan on $target with output to $filename (FAST MODE)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -oA $filename -T4 --min-rate=1000 --max-retries=2 $target"
    echo ""
    sudo nmap -oA $filename -T4 --min-rate=1000 --max-retries=2 $target
    echo -e "${GREEN}Output saved to:${NC}"
    echo "  - $filename.nmap (normal output)"
    echo "  - $filename.xml (XML output)"
    echo "  - $filename.gnmap (grepable output)"
    pause
}

scan_subnet() {
    echo -e "${B_YELLOW}Enter subnet (e.g., 192.168.1.0/24):${NC}"
    read -p "$(echo -e "${B_CYAN}Subnet:${NC} ")" target
    if [ -z "$target" ]; then
        echo -e "${RED}No subnet specified!${NC}"
        pause
        return
    fi
    local output
    echo -e "${BLUE}Running Subnet Scan on $target (FAST MODE - Parallel Workers)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -T4 --min-rate=1000 --max-retries=2 --min-parallelism=100 $target"
    echo ""
    output=$(sudo nmap -T4 --min-rate=1000 --max-retries=2 --min-parallelism=100 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_tcp_connect() {
    get_target || return
    local output
    echo -e "${BLUE}Running TCP Connect Scan on $target (FAST MODE)...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -sT -T4 --min-rate=1000 --max-retries=2 --min-parallelism=100 $target"
    echo ""
    output=$(sudo nmap -sT -T4 --min-rate=1000 --max-retries=2 --min-parallelism=100 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

scan_evasion() {
    get_target || return
    local output
    echo -e "${BLUE}Running Firewall/IDS Evasion Scan on $target...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -f -T2 -D RND:10 $target"
    echo ""
    output=$(sudo nmap -f -T2 -D RND:10 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

# New scan function for ARP discovery
scan_arp_discovery() {
    echo -e "${B_YELLOW}Enter local subnet to scan (e.g., 192.168.1.0/24):${NC}"
    read -p "$(echo -e "${B_CYAN}Subnet:${NC} ")" target
    local output
    if [ -z "$target" ]; then
        echo -e "${RED}No subnet specified!${NC}"
        pause
        return
    fi

    echo -e "${BLUE}Running ARP Discovery Scan on $target...${NC}"
    echo -e "${B_CYAN}Command:${NC} sudo nmap -sn -PR -T4 $target"
    echo ""
    output=$(sudo nmap -sn -PR -T4 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

# New scan function for List Scan
scan_list() {
    get_target || return

    local output
    echo -e "${BLUE}Running List Scan for $target...${NC}"
    echo -e "${B_CYAN}Command:${NC} nmap -sL $target"
    echo ""
    # No sudo needed for -sL
    output=$(nmap -sL "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

# New scan function for No Ping Scan
scan_no_ping() {
    get_target || return

    echo -e "${BLUE}Running Scan with No Ping (-Pn) on $target...${NC}"
    local output
    echo -e "${B_CYAN}Command:${NC} sudo nmap -Pn -T4 --min-rate=1000 $target"
    echo ""
    output=$(sudo nmap -Pn -T4 --min-rate=1000 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

# New scan function for Idle Scan
scan_idle() {
    echo -e "${B_YELLOW}Enter the IP of the 'zombie' host (must be idle on the network):${NC}"
    echo -e "${YELLOW}Tip: Find zombies on your network with the 'ipidseq' script. Look for 'Incremental!'.${NC}"
    echo -e "${CYAN}  sudo nmap -T4 -v --script ipidseq <subnet>${NC}"
    echo ""
    read -p "$(echo -e "${B_CYAN}Zombie IP:${NC} ")" zombie
    if [ -z "$zombie" ]; then
        echo -e "${RED}No zombie host specified!${NC}"
        pause
        return
    fi

    get_target || return

    local output
    echo -e "${BLUE}Running Idle Scan on $target using zombie $zombie...${NC}"
    echo -e "${B_CYAN}Command:${NC} sudo nmap -sI $zombie -T4 $target"
    echo ""
    output=$(sudo nmap -sI "$zombie" -T4 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

# New scan function for Custom NSE Scripts
scan_custom_nse() {
    get_target || return
    # Display a list of useful scripts for the user
    echo -e "${GREEN}--- Common NSE Scripts ---${NC}"
    echo -e "${B_YELLOW}Discovery:${NC}"
    echo -e "  ${CYAN}http-title${NC}              - Gets web page title"
    echo -e "  ${CYAN}smb-os-discovery${NC}        - Gathers OS info from SMB (Windows)"
    echo -e "  ${CYAN}ssl-enum-ciphers${NC}        - Lists supported SSL/TLS ciphers"
    echo -e "  ${CYAN}dns-brute${NC}               - Finds subdomains for a domain"
    echo -e "  ${CYAN}ftp-anon${NC}                - Checks for anonymous FTP access"
    echo ""
    echo -e "${B_YELLOW}Vulnerability:${NC}"
    echo -e "  ${CYAN}vulners${NC}                 - Checks for vulns using Vulners DB"
    echo -e "  ${CYAN}smb-vuln-ms17-010${NC}       - Checks for EternalBlue"
    echo -e "  ${CYAN}http-shellshock${NC}         - Checks for Shellshock bug"
    echo -e "  ${CYAN}ssl-heartbleed${NC}          - Checks for Heartbleed bug"
    echo ""
    echo -e "${B_YELLOW}Tip: You can combine scripts with a comma, e.g., http-title,ftp-anon${NC}"
    echo ""
    echo -e "${B_YELLOW}Enter NSE script names to run:${NC}"
    read -p "$(echo -e "${B_CYAN}Scripts:${NC} ")" scripts
    if [ -z "$scripts" ]; then
        echo -e "${RED}No scripts specified!${NC}"
        pause
        return
    fi

    local output
    echo -e "${BLUE}Running Custom NSE Scripts ($scripts) on $target...${NC}"
    echo -e "${B_CYAN}Command:${NC} sudo nmap --script \"$scripts\" -sV -T4 $target"
    echo ""
    output=$(sudo nmap --script "$scripts" -sV -T4 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

# Upgraded scan function for a powerful, all-in-one scan
scan_all_in_one() {
    get_target || return

    # A curated list of useful and safe discovery scripts to add to the aggressive scan
    local custom_scripts="http-title,smb-os-discovery,ssl-enum-ciphers,ftp-anon,ssh2-enum-algos"

    # This combines Aggressive scan (-A), a full port scan (-p-), and extra scripts for maximum information
    echo -e "${BLUE}Running Full Comprehensive Scan (Extensive Scripting) on $target...${NC}"
    echo -e "${YELLOW}This is a very thorough scan and may take a long time.${NC}"
    echo -e "${B_CYAN}Command:${NC} sudo nmap -A -p- --script=\"default,discovery,safe,vuln,auth,broadcast,external,malware,$custom_scripts\" -T4 --min-rate=1000 \"$target\""
    
    # Capture output to a variable while also displaying it to the screen
    local output
    output=$(sudo nmap -A -p- --script="default,discovery,safe,vuln,auth,broadcast,external,malware,$custom_scripts" -T4 --min-rate=1000 "$target" | tee /dev/tty)
    
    # Use the new, standardized save function
    ask_to_save "$output" "$target"
    pause
}

# Helper function to choose a wordlist from the system
choose_wordlist() {
    local default_val="$1"
    local prompt_type="$2"
    CHOICE_RESULT=""

    echo -e "${B_YELLOW}Select $prompt_type List Source:${NC}"
    echo -e "  1) Enter path manually"
    echo -e "  2) Auto-detect in /usr/share/wordlists (System Default)"
    echo -e "  3) Auto-detect in local 'wordlist/' directory"
    read -p "$(echo -e "${B_GREEN}Select (1-3):${NC} ")" wl_choice

    local selected_file=""
    if [[ "$wl_choice" == "2" ]]; then
        if [ -d "/usr/share/wordlists" ]; then
            echo -e "${CYAN}Searching for files in /usr/share/wordlists...${NC}"
            # Find files, limit to 30 to avoid flooding the screen
            local found_files=()
            while IFS= read -r line; do
                found_files+=("$line")
            done < <(find /usr/share/wordlists -maxdepth 3 -type f -not -path '*/.*' 2>/dev/null | head -n 30)

            if [ ${#found_files[@]} -eq 0 ]; then
                echo -e "${RED}No files found in /usr/share/wordlists.${NC}"
            else
                local idx=1
                for f in "${found_files[@]}"; do
                    echo -e "  ${B_BLUE}$idx)${NC} $f"
                    ((idx++))
                done
                read -p "$(echo -e "${B_GREEN}Select file number (1-${#found_files[@]}):${NC} ")" sel_idx
                if [[ "$sel_idx" =~ ^[0-9]+$ ]] && [ "$sel_idx" -ge 1 ] && [ "$sel_idx" -le "${#found_files[@]}" ]; then
                    selected_file="${found_files[$((sel_idx-1))]}"
                else
                    echo -e "${RED}Invalid selection.${NC}"
                fi
            fi
        else
            echo -e "${RED}Directory /usr/share/wordlists not found.${NC}"
        fi
    elif [[ "$wl_choice" == "3" ]]; then
        if [ -d "wordlist" ]; then
            echo -e "${CYAN}Searching for files in local 'wordlist/' directory...${NC}"
            local found_files=()
            # Search for .txt, .tar, .gz, .lst files
            while IFS= read -r line; do
                found_files+=("$line")
            done < <(find wordlist -maxdepth 2 -type f \( -name "*.txt" -o -name "*.tar" -o -name "*.gz" -o -name "*.lst" \) 2>/dev/null | head -n 30)

            if [ ${#found_files[@]} -eq 0 ]; then
                echo -e "${RED}No suitable files found in 'wordlist/'.${NC}"
            else
                local idx=1
                for f in "${found_files[@]}"; do
                    echo -e "  ${B_BLUE}$idx)${NC} $f"
                    ((idx++))
                done
                read -p "$(echo -e "${B_GREEN}Select file number (1-${#found_files[@]}):${NC} ")" sel_idx
                if [[ "$sel_idx" =~ ^[0-9]+$ ]] && [ "$sel_idx" -ge 1 ] && [ "$sel_idx" -le "${#found_files[@]}" ]; then
                    selected_file="${found_files[$((sel_idx-1))]}"
                else
                    echo -e "${RED}Invalid selection.${NC}"
                fi
            fi
        else
            echo -e "${RED}Directory 'wordlist/' not found.${NC}"
        fi
    fi

    if [ -z "$selected_file" ]; then
        if [[ "$wl_choice" == "2" || "$wl_choice" == "3" ]]; then
             echo -e "${YELLOW}Falling back to manual entry.${NC}"
        fi
        read -p "$(echo -e "${B_CYAN}Enter path to $prompt_type file (default: $default_val):${NC} ")" manual_input
        selected_file="${manual_input:-$default_val}"
    fi
    CHOICE_RESULT="$selected_file"
}

# New function for Brute-Force attacks
scan_brute_force() {
    echo -e "${B_YELLOW}Select a service to brute-force:${NC}"
    echo -e "  ${B_CYAN}1)${NC} FTP"
    echo -e "  ${B_CYAN}2)${NC} SSH"
    echo -e "  ${B_CYAN}3)${NC} Telnet"
    echo -e "  ${B_CYAN}4)${NC} MySQL"
    echo -e "  ${B_CYAN}5)${NC} MS-SQL"
    echo -e "  ${B_CYAN}6)${NC} PostgreSQL"
    read -p "$(echo -e "${B_GREEN}Enter your choice:${NC} ")" service_choice

    local script_name
    local port
    case $service_choice in
        1) script_name="ftp-brute"; port="21" ;;
        2)
            script_name="ssh-brute"
            read -p "$(echo -e "${B_YELLOW}Enter SSH port (default 22):${NC} ")" custom_port
            port="${custom_port:-22}"
            read -p "$(echo -e "${B_YELLOW}Add advanced SSH enumeration (algos, keys, auth)? (y/n):${NC} ")" add_enum
            if [[ "$add_enum" == "y" || "$add_enum" == "Y" ]]; then
                script_name="ssh-brute,ssh2-enum-algos,ssh-hostkey,ssh-auth-methods"
            fi
            ;;
        3) script_name="telnet-brute"; port="23" ;;
        4) script_name="mysql-brute"; port="3306" ;;
        5) script_name="ms-sql-brute"; port="1433" ;;
        6) script_name="pgsql-brute"; port="5432" ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            pause
            return
            ;;
    esac

    get_target || return

    local service_name
    service_name=$(echo "$script_name" | cut -d- -f1)

    # Ask for custom user/pass lists
    local script_args=""
    echo -e "${B_YELLOW}Username Mode:${NC}"
    echo -e "  1) Target a specific username"
    echo -e "  2) Use a username list"
    read -p "$(echo -e "${B_GREEN}Select (1-2):${NC} ")" user_mode

    if [[ "$user_mode" == "1" ]]; then
        read -p "$(echo -e "${B_CYAN}Enter username:${NC} ")" single_user
        script_args="users=$single_user"
    else
        choose_wordlist "wordlist/word.txt" "Username"
        userdb_path="$CHOICE_RESULT"
        if [ -f "$userdb_path" ]; then
            script_args="userdb=$userdb_path"
        else
            echo -e "${RED}File not found: $userdb_path. Using default.${NC}"
        fi
    fi
    read -p "$(echo -e "${B_YELLOW}Use custom password list? (y/n, default: n):${NC} ")" use_passdb
    if [[ "$use_passdb" == "y" || "$use_passdb" == "Y" ]]; then
        choose_wordlist "wordlist/passwords.txt" "Password"
        passdb_path="$CHOICE_RESULT"

        if [ -f "$passdb_path" ]; then
            script_args="${script_args:+$script_args,}passdb=$passdb_path"
        else
            echo -e "${RED}File not found: $passdb_path. Using default.${NC}"
        fi
    fi

    local output
    echo -e "${B_RED}Running ${service_name^^} Brute-Force attack on $target...${NC}"
    echo -e "${B_CYAN}Command:${NC} sudo nmap -p $port --script $script_name ${script_args:+--script-args \"$script_args\"} -T4 \"$target\""
    echo ""
    output=$(sudo nmap -p "$port" --script "$script_name" ${script_args:+--script-args "$script_args"} -T4 "$target" | tee /dev/tty)
    ask_to_save "$output" "$target"
    pause
}

# Main program loop
main() {
    check_nmap
    
    while true; do
        show_menu
        read -p "$(echo -e "${B_GREEN}Enter your choice [1-24]:${NC} ")" choice
        echo ""
        
        case $choice in
            1) scan_quick ;;
            2) scan_standard ;;
            3) scan_full ;;
            4) scan_ping ;;
            5) scan_version ;;
            6) scan_os ;;
            7) scan_aggressive ;;
            8) scan_stealth ;;
            9) scan_udp ;;
            10) scan_specific_port ;;
            11) scan_vuln ;;
            12) scan_fast ;;
            13) scan_output ;;
            14) scan_subnet ;;
            15) scan_tcp_connect ;;
            16) scan_evasion ;;
            17) scan_arp_discovery ;;
            18) scan_list ;;
            19) scan_no_ping ;;
            20) scan_idle ;;
            21) scan_custom_nse ;;
            22) scan_all_in_one ;;
            23) scan_brute_force ;;
            24)
                echo -e "${GREEN}Thank you for using Nmap Interactive Menu!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option! Please select a valid number.${NC}"
                pause
                ;;
        esac
    done
}

# Run the main program
main
