#!/usr/bin/env bash

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

RESULTS_FILE="crackstation_cracked.txt"

show_banner() {
    clear 2>/dev/null || true
    echo -e "${RED}"
    echo "╔══════════════════════════════════════╗"
    echo "║       CRACKSTATION v1.0              ║"
    echo "║   Multi-Algorithm Hash Cracker       ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${RESET}"
}

show_disclaimer() {
    echo -e "${RED}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${RED}║  DISCLAIMER: Use at your own risk.                ║${RESET}"
    echo -e "${RED}║  Developer(s) assume NO liability.                ║${RESET}"
    echo -e "${RED}║  For authorized security testing ONLY.            ║${RESET}"
    echo -e "${RED}╚════════════════════════════════════════════════════╝${RESET}"
}

show_help() {
    echo -e "${CYAN}USAGE:${RESET}"
    echo "  ./crackstation.sh [option] <hash> <wordlist>"
    echo ""
    echo -e "${CYAN}OPTIONS:${RESET}"
    echo "  -md5      Crack MD5 hash"
    echo "  -sha1     Crack SHA1 hash"
    echo "  -sha256   Crack SHA256 hash"
    echo "  -auto     Auto-detect hash type by length and crack"
    echo "  -h, --help  Show this help message"
    echo ""
    echo -e "${CYAN}EXAMPLES:${RESET}"
    echo "  ./crackstation.sh -md5 5d41402abc4b2a76b9719d911017c592 wordlist.txt"
    echo "  ./crackstation.sh -auto 5d41402abc4b2a76b9719d911017c592 wordlist.txt"
    echo ""
    show_disclaimer
}

detect_hash_type() {
    local hash="$1"
    local len=${#hash}

    case "$len" in
        32) echo "md5" ;;
        40) echo "sha1" ;;
        64) echo "sha256" ;;
        *)
            echo -e "${RED}[!] Unknown hash length: $len (expected 32, 40, or 64)${RESET}" >&2
            echo "unknown"
            ;;
    esac
}

hash_word() {
    local algo="$1"
    local word="$2"
    case "$algo" in
        md5)    echo -n "$word" | md5sum 2>/dev/null | cut -d' ' -f1 ;;
        sha1)   echo -n "$word" | sha1sum 2>/dev/null | cut -d' ' -f1 ;;
        sha256) echo -n "$word" | sha256sum 2>/dev/null | cut -d' ' -f1 ;;
    esac
}

try_hashcat() {
    local algo="$1"
    local hash="$2"
    local wordlist="$3"

    if ! command -v hashcat &>/dev/null; then
        return 1
    fi

    echo -e "${CYAN}[*] hashcat detected. Attempting hashcat...${RESET}"

    local mode
    case "$algo" in
        md5)    mode=0 ;;
        sha1)   mode=100 ;;
        sha256) mode=1400 ;;
        *)      return 1 ;;
    esac

    local hash_file
    hash_file=$(mktemp)
    echo "$hash" > "$hash_file"

    if hashcat -m "$mode" -a 0 "$hash_file" "$wordlist" --potfile-disable --show 2>/dev/null | grep -q ":"; then
        local cracked
        cracked=$(hashcat -m "$mode" -a 0 "$hash_file" "$wordlist" --potfile-disable --show 2>/dev/null | cut -d: -f2)
        echo -e "${GREEN}[+] Cracked by hashcat: $cracked${RESET}"
        echo "$hash:$cracked" >> "$RESULTS_FILE"
        rm -f "$hash_file"
        return 0
    fi

    if hashcat -m "$mode" -a 0 "$hash_file" "$wordlist" --potfile-disable -O 2>/dev/null | grep -q "Cracked"; then
        local cracked
        cracked=$(hashcat -m "$mode" -a 0 "$hash_file" "$wordlist" --potfile-disable --show 2>/dev/null | cut -d: -f2)
        if [ -n "$cracked" ]; then
            echo -e "${GREEN}[+] Cracked by hashcat: $cracked${RESET}"
            echo "$hash:$cracked" >> "$RESULTS_FILE"
            rm -f "$hash_file"
            return 0
        fi
    fi

    rm -f "$hash_file"
    return 1
}

try_john() {
    local algo="$1"
    local hash="$2"
    local wordlist="$3"

    if ! command -v john &>/dev/null; then
        return 1
    fi

    echo -e "${CYAN}[*] John the Ripper detected. Attempting john...${RESET}"

    local hash_file
    hash_file=$(mktemp)

    case "$algo" in
        md5)
            echo "admin:\$dynamic_0\$hash" | sed 's/\$hash\$/'$hash'/' > "$hash_file"
            ;;
        sha1)
            echo "admin:{SHA}$hash" > "$hash_file"
            ;;
        sha256)
            echo "admin:\$5\$rounds=5000\$salt\$hash" | sed 's/\$hash\$/'$hash'/' > "$hash_file"
            ;;
    esac

    john --wordlist="$wordlist" "$hash_file" 2>/dev/null | grep -i "loaded"

    local result
    result=$(john --show "$hash_file" 2>/dev/null | grep -v "^:" | grep ":" | head -1 | cut -d: -f2)

    if [ -n "$result" ]; then
        echo -e "${GREEN}[+] Cracked by john: $result${RESET}"
        echo "$hash:$result" >> "$RESULTS_FILE"
        rm -f "$hash_file"
        return 0
    fi

    rm -f "$hash_file"
    return 1
}

bash_crack() {
    local algo="$1"
    local hash="$2"
    local wordlist="$3"

    echo -e "${CYAN}[*] Cracking with pure bash ($algo)...${RESET}"

    if [ ! -f "$wordlist" ]; then
        echo -e "${RED}[!] Wordlist not found: $wordlist${RESET}"
        return 1
    fi

    local total
    total=$(wc -l < "$wordlist")
    echo -e "${YELLOW}[*] Wordlist contains $total words${RESET}"

    local count=0
    while IFS= read -r word || [ -n "$word" ]; do
        word=$(echo -n "$word" | tr -d '\r\n')
        [ -z "$word" ] && continue

        local word_hash
        word_hash=$(hash_word "$algo" "$word")
        count=$((count + 1))

        if [ "$((count % 10000))" -eq 0 ]; then
            echo -e "${CYAN}[*] Progress: $count/$total words checked${RESET}"
        fi

        if [ "$word_hash" = "$hash" ]; then
            echo -e "${GREEN}[+] CRACKED: $hash => $word${RESET}"
            echo "$hash:$word" >> "$RESULTS_FILE"
            echo -e "${GREEN}[+] Result saved to $RESULTS_FILE${RESET}"
            return 0
        fi
    done < "$wordlist"

    echo -e "${RED}[!] Hash not found in wordlist${RESET}"
    return 1
}

crack() {
    local algo="$1"
    local hash="$2"
    local wordlist="$3"

    echo -e "${CYAN}[*] Algorithm: ${YELLOW}$algo${RESET}"
    echo -e "${CYAN}[*] Hash: ${YELLOW}$hash${RESET}"
    echo -e "${CYAN}[*] Wordlist: ${YELLOW}$wordlist${RESET}"
    echo ""

    > "$RESULTS_FILE"

    try_hashcat "$algo" "$hash" "$wordlist" && return 0
    try_john "$algo" "$hash" "$wordlist" && return 0

    echo -e "${YELLOW}[!] External tools not available or failed. Falling back to pure bash...${RESET}"
    bash_crack "$algo" "$hash" "$wordlist"
}

interactive_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}1) Crack MD5${RESET}"
        echo -e "${CYAN}2) Crack SHA1${RESET}"
        echo -e "${CYAN}3) Crack SHA256${RESET}"
        echo -e "${CYAN}4) Auto-detect & crack${RESET}"
        echo -e "${CYAN}5) Help${RESET}"
        echo -e "${CYAN}6) Exit${RESET}"
        echo ""
        read -p "$(echo -e ${YELLOW}"[>] Choose an option [1-6]: "${RESET})" choice

        case "$choice" in
            1|2|3)
                read -p "$(echo -e ${YELLOW}"[>] Enter hash: "${RESET})" hash
                read -p "$(echo -e ${YELLOW}"[>] Enter wordlist path: "${RESET})" wordlist
                case "$choice" in
                    1) algo="md5" ;;
                    2) algo="sha1" ;;
                    3) algo="sha256" ;;
                esac
                crack "$algo" "$hash" "$wordlist"
                ;;
            4)
                read -p "$(echo -e ${YELLOW}"[>] Enter hash: "${RESET})" hash
                read -p "$(echo -e ${YELLOW}"[>] Enter wordlist path: "${RESET})" wordlist
                algo=$(detect_hash_type "$hash")
                [ "$algo" = "unknown" ] && continue
                crack "$algo" "$hash" "$wordlist"
                ;;
            5)
                show_help
                ;;
            6)
                echo -e "${GREEN}[+] Exiting. Stay secure.${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Invalid option${RESET}"
                sleep 1
                ;;
        esac

        echo ""
        echo -e "${CYAN}[*] Press Enter to continue...${RESET}"
        read -r
    done
}

main() {
    show_disclaimer
    echo ""

    if [ $# -eq 0 ]; then
        interactive_menu
    elif [ $# -lt 3 ] && [ "$1" != "-h" ] && [ "$1" != "--help" ]; then
        echo -e "${RED}[!] Usage: $0 <option> <hash> <wordlist>${RESET}"
        show_help
        exit 1
    else
        case "$1" in
            -md5)
                crack "md5" "$2" "$3"
                ;;
            -sha1)
                crack "sha1" "$2" "$3"
                ;;
            -sha256)
                crack "sha256" "$2" "$3"
                ;;
            -auto)
                algo=$(detect_hash_type "$2")
                [ "$algo" = "unknown" ] && exit 1
                crack "$algo" "$2" "$3"
                ;;
            -h|--help)
                show_help
                ;;
            *)
                echo -e "${RED}[!] Unknown option: $1${RESET}"
                show_help
                exit 1
                ;;
        esac
    fi
}

main "$@"
