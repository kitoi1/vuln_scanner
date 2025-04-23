# vuln_scanner

#!/bin/bash

# === Enhanced VulnHunter Pro ===
# Author: Kasau
# Version: 3.0
# Features:
# - Dynamic rotating banners
# - Colorized output
# - Comprehensive scanning
# - Real-time feedback
# - Enhanced security (no log or result saving)

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# === Cool Interfaces ===
BANNERS=(
"${CYAN}╔═╗┌─┐┬ ┬┌┐┌┌─┐  ╔═╗┌─┐┌┬┐┌─┐${NC}   ${MAGENTA}by Kasau${NC}"
"${RED}▄︻デ══━一   ${YELLOW}VulnHunter Pro${RED}   — ${GREEN}Created by Kasau${NC}"
"${BLUE}┌─┐┬ ┬┌┬┐┬ ┬┬┌─${NC}   ${YELLOW}• Nuclei + CVE Scanner •${NC} — ${MAGENTA}Kasau${NC}"
)

function show_banner {
    clear
    RAND=$((RANDOM % ${#BANNERS[@]}))
    echo -e "\n${BANNERS[$RAND]}"
    echo -e "${BLUE}=============================================${NC}"
    echo -e "${YELLOW}Version: 3.0${NC} | ${GREEN}Last Updated: $(date +'%Y-%m-%d')${NC}\n"
}

# === Tool Check ===
function check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}[!] Error: $1 not found. Please install it first.${NC}"
        return 1
    fi
    return 0
}

# === Input Validation ===
function validate_input() {
    INPUT=$1
    if [[ $INPUT == *";"* || $INPUT == *"&"* || $INPUT == *"|"* ]]; then
        echo -e "${RED}[!] Invalid characters detected in input. Aborting for security.${NC}"
        exit 1
    fi
}

# === Nuclei Scanner ===
function run_nuclei {
    echo -e "${CYAN}=== NUCLEI VULNERABILITY SCAN ===${NC}"
    read -p "[+] Enter path to targets (IPs/Subdomains): " TARGETS
    validate_input "$TARGETS"
    
    if [[ ! -f "$TARGETS" ]]; then
        echo -e "${RED}[!] File not found.${NC}"
        exit 1
    fi

    TARGET_COUNT=$(wc -l < "$TARGETS")
    echo -e "${GREEN}[+] Loaded $TARGET_COUNT targets${NC}"

    echo -e "\n${YELLOW}[+] Scan Options:${NC}"
    echo -e "  ${GREEN}[1] Quick Scan (medium+ severity)"
    echo -e "  [2] Full Scan (all templates)"
    echo -e "  [3] Custom Scan${NC}"
    read -p "Choose option [1/2/3]: " SCAN_OPTION
    validate_input "$SCAN_OPTION"
    
    case $SCAN_OPTION in
        1)
            check_tool "nuclei" && {
                echo -e "${CYAN}[>] Running quick nuclei scan...${NC}"
                nuclei -l "$TARGETS" -severity medium,high,critical -stats -si 100
            }
            ;;
        2)
            check_tool "nuclei" && {
                echo -e "${CYAN}[>] Running full nuclei scan...${NC}"
                nuclei -l "$TARGETS" -t ~/nuclei-templates/ -stats -si 100
            }
            ;;
        3)
            read -p "Enter custom nuclei flags (e.g., -t cves/ -severity high): " CUSTOM_FLAGS
            validate_input "$CUSTOM_FLAGS"
            check_tool "nuclei" && {
                echo -e "${CYAN}[>] Running custom nuclei scan...${NC}"
                nuclei -l "$TARGETS" $CUSTOM_FLAGS -stats -si 100
            }
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            ;;
    esac
}

# === CVE Scanner ===
function run_cve_scan {
    echo -e "${CYAN}=== CVE INFORMATION GATHERER ===${NC}"
    read -p "[+] Enter software/service version (e.g., apache 2.4.49): " QUERY
    validate_input "$QUERY"
    
    if [[ -z "$QUERY" ]]; then
        echo -e "${RED}[!] No query provided${NC}"
        return
    fi

    echo -e "\n${YELLOW}[+] Gathering CVE information for: $QUERY${NC}"

    # Searchsploit
    if check_tool "searchsploit"; then
        echo -e "${CYAN}[>] Checking searchsploit...${NC}"
        searchsploit "$QUERY"
    fi

    # Vulners
    if check_tool "vulners"; then
        echo -e "${CYAN}[>] Checking vulners...${NC}"
        vulners -s "$QUERY"
    fi

    # NVD API (fallback)
    if ! command -v vulners &> /dev/null; then
        echo -e "${YELLOW}[>] Checking NVD database via API...${NC}"
        curl -s "https://services.nvd.nist.gov/rest/json/cves/1.0?keyword=$QUERY" | jq .
    fi
}

# === Main Menu ===
show_banner
echo -e "${GREEN}[1] Run Nuclei Vulnerability Scan"
echo -e "[2] Run CVE Information Scanner"
echo -e "[0] Exit${NC}"
read -p "Choose an option [0-2]: " CHOICE
validate_input "$CHOICE"

case $CHOICE in
    1)
        run_nuclei
        ;;
    2)
        run_cve_scan
        ;;
    0)
        echo -e "${GREEN}[+] Exiting VulnHunter...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}[!] Invalid option${NC}"
        ;;
esac

echo -e "${GREEN}[+] Scan session completed.${NC}"
