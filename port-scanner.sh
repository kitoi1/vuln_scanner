#!/bin/bash

# Advanced Hacker-style Port Scanner 🔍
# Author: KaSau ⚔
# Version: 2.0

clear
echo -e "\e[32m"
echo "   ▄████████  ▄██████▄     ▄████████    ▄████████  ▄█  ███▄▄▄▄   "
echo "  ███    ███ ███    ███   ███    ███   ███    ███ ███  ███▀▀▀██▄ "
echo "  ███    █▀  ███    ███   ███    ███   ███    ███ ███▌ ███   ███ "
echo "  ███        ███    ███  ▄███▄▄▄▄██▀   ███    ███ ███▌ ███   ███ "
echo "▀███████████ ███    ███ ▀▀███▀▀▀▀▀   ▀███████████ ███▌ ███   ███ "
echo "         ███ ███    ███ ▀███████████   ███    ███ ███  ███   ███ "
echo "   ▄█    ███ ███    ███   ███    ███   ███    ███ ███  ███   ███ "
echo " ▄████████▀   ▀██████▀    ███    ███   ███    █▀  █▀    ▀█   █▀ "
echo "                          ███    ███                            "
echo -e "\e[0m"
echo "========================================================"
echo "           Advanced Port Scanner v2.0 ⚡"
echo "========================================================"

# Check if nmap is installed
if ! command -v nmap &> /dev/null
then
    echo -e "\e[31m[!] Nmap is not installed. Please install it first.\e[0m"
    exit 1
fi

# Function to validate IP or domain
validate_target() {
    local target=$1
    # Simple regex for IP and domain validation
    if [[ $target =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || 
       [[ $target =~ ^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Get target
while true; do
    read -p "🎯 Enter target IP or domain: " target
    if validate_target "$target"; then
        break
    else
        echo -e "\e[31m[!] Invalid IP or domain. Please try again.\e[0m"
    fi
done

# Scan options
echo -e "\n\e[36m[+] Select scan type:\e[0m"
echo "1. Quick Scan (Top 100 ports)"
echo "2. Comprehensive Scan (Top 1000 ports with service detection)"
echo "3. Stealth Scan (SYN scan, slower)"
echo "4. Full Port Scan (All 65535 ports)"
echo "5. UDP Scan (Top 100 UDP ports)"
echo "6. Custom Scan"

read -p "🔘 Choose option (1-6): " scan_option

case $scan_option in
    1)
        echo -e "\n\e[32m[+] Starting Quick Scan...\e[0m"
        nmap -T4 -F $target
        ;;
    2)
        echo -e "\n\e[32m[+] Starting Comprehensive Scan...\e[0m"
        nmap -sS -sV -T4 $target
        ;;
    3)
        echo -e "\n\e[32m[+] Starting Stealth Scan...\e[0m"
        nmap -sS -T2 $target
        ;;
    4)
        echo -e "\n\e[32m[+] Starting Full Port Scan...\e[0m"
        nmap -p- -T4 $target
        ;;
    5)
        echo -e "\n\e[32m[+] Starting UDP Scan...\e[0m"
        nmap -sU -T4 --top-ports 100 $target
        ;;
    6)
        read -p "Enter custom Nmap arguments: " custom_args
        echo -e "\n\e[32m[+] Starting Custom Scan with: nmap $custom_args $target\e[0m"
        nmap $custom_args $target
        ;;
    *)
        echo -e "\e[31m[!] Invalid option. Exiting.\e[0m"
        exit 1
        ;;
esac

# Save results option
read -p "💾 Save results to file? (y/n): " save_choice
if [[ $save_choice == "y" || $save_choice == "Y" ]]; then
    timestamp=$(date +"%Y%m%d_%H%M%S")
    filename="scan_results_${target}_${timestamp}.txt"
    nmap -oN $filename $target &>/dev/null
    echo -e "\e[32m[+] Results saved to $filename\e[0m"
fi

echo -e "\n\e[32m[✓] Scan complete. Remember: With great power comes great responsibility.\e[0m"
echo -e "\e[35m[*] Stay stealthy and ethical, hacker! 😎\e[0m"
                                                                
