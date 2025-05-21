#!/bin/bash 
echo "creating colours..."
cat << EOF >./bash_colors.sh
#!/bin/bash
# bash_colors.sh
#
# This file defines common ANSI color codes for use in Bash scripts.
# To use these colors in another script, source this file:
#   source path/to/bash_colors.sh
#
# Then you can use the variables like so:
#   echo -e "${RED}This is red text${RESET}"
#   echo -e "${GREEN}Success!${RESET}"
#   echo -e "${BOLD}${BLUE}This is bold blue text${RESET}"

# Reset all attributes
export RESET='\e[0m'
export NC='\e[0m' # No Color - alias for RESET

# --- Text Attributes ---
export BOLD='\e[1m'
export DIM='\e[2m' # Faint or decreased intensity
export ITALIC='\e[3m' # Not widely supported
export UNDERLINE='\e[4m'
export BLINK='\e[5m' # Often annoying, use sparingly
export REVERSE='\e[7m' # Swaps foreground and background
export HIDDEN='\e[8m' # Concealed text (not widely supported for actual hiding)

# --- Regular Foreground Colors (30-37) ---
export FG_BLACK='\e[0;30m'
export FG_RED='\e[0;31m'
export FG_GREEN='\e[0;32m'
export FG_YELLOW='\e[0;33m'
export FG_BLUE='\e[0;34m'
export FG_MAGENTA='\e[0;35m'
export FG_CYAN='\e[0;36m'
export FG_WHITE='\e[0;37m'

# --- Bright Foreground Colors (90-97) ---
# Some terminals interpret BOLD + Regular Color as Bright.
# These are explicit bright color codes.
export FG_BRIGHT_BLACK='\e[0;90m'  # Often looks like Dark Gray
export FG_BRIGHT_RED='\e[0;91m'
export FG_BRIGHT_GREEN='\e[0;92m'
export FG_BRIGHT_YELLOW='\e[0;93m'
export FG_BRIGHT_BLUE='\e[0;94m'
export FG_BRIGHT_MAGENTA='\e[0;95m'
export FG_BRIGHT_CYAN='\e[0;96m'
export FG_BRIGHT_WHITE='\e[0;97m'

# --- Regular Background Colors (40-47) ---
export BG_BLACK='\e[40m'
export BG_RED='\e[41m'
export BG_GREEN='\e[42m'
export BG_YELLOW='\e[43m'
export BG_BLUE='\e[44m'
export BG_MAGENTA='\e[45m'
export BG_CYAN='\e[46m'
export BG_WHITE='\e[47m'

# --- Bright Background Colors (100-107) ---
export BG_BRIGHT_BLACK='\e[100m' # Often looks like Dark Gray
export BG_BRIGHT_RED='\e[101m'
export BG_BRIGHT_GREEN='\e[102m'
export BG_BRIGHT_YELLOW='\e[103m'
export BG_BRIGHT_BLUE='\e[104m'
export BG_BRIGHT_MAGENTA='\e[105m'
export BG_BRIGHT_CYAN='\e[106m'
export BG_BRIGHT_WHITE='\e[107m'

# --- Convenience aliases for common foreground colors ---
export BLACK="${FG_BLACK}"
export RED="${FG_RED}"
export GREEN="${FG_GREEN}"
export YELLOW="${FG_YELLOW}"
export BLUE="${FG_BLUE}"
export MAGENTA="${FG_MAGENTA}"
export PURPLE="${FG_MAGENTA}" # Common alias
export CYAN="${FG_CYAN}"
export WHITE="${FG_WHITE}"

export GRAY="${FG_BRIGHT_BLACK}" # Gray is often bright black
export LIGHT_RED="${FG_BRIGHT_RED}"
export LIGHT_GREEN="${FG_BRIGHT_GREEN}"
export LIGHT_YELLOW="${FG_BRIGHT_YELLOW}"
export LIGHT_BLUE="${FG_BRIGHT_BLUE}"
export LIGHT_MAGENTA="${FG_BRIGHT_MAGENTA}"
export LIGHT_PURPLE="${FG_BRIGHT_MAGENTA}" # Common alias
export LIGHT_CYAN="${FG_BRIGHT_CYAN}"
export BRIGHT_WHITE="${FG_BRIGHT_WHITE}"


# --- Function to demonstrate all defined colors and attributes ---
# This part only runs if the script is executed directly, not sourced.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "\n${UNDERLINE}${BOLD}Text Attributes Demo:${RESET}"
    echo -e "${BOLD}This is BOLD text${RESET}"
    echo -e "${DIM}This is DIM text${RESET}"
    echo -e "${ITALIC}This is ITALIC text (if supported)${RESET}"
    echo -e "${UNDERLINE}This is UNDERLINED text${RESET}"
    echo -e "${BLINK}This is BLINKING text (if supported/enabled)${RESET}"
    echo -e "${REVERSE}This is REVERSED text${RESET}"
    echo -e "${HIDDEN}This is HIDDEN text (if supported)${RESET} (You might not see 'This is HIDDEN text')"

    echo -e "\n${UNDERLINE}${BOLD}Regular Foreground Colors Demo:${RESET}"
    echo -e "${FG_BLACK}FG_BLACK${RESET} ${FG_RED}FG_RED${RESET} ${FG_GREEN}FG_GREEN${RESET} ${FG_YELLOW}FG_YELLOW${RESET} ${FG_BLUE}FG_BLUE${RESET} ${FG_MAGENTA}FG_MAGENTA${RESET} ${FG_CYAN}FG_CYAN${RESET} ${FG_WHITE}FG_WHITE${RESET}"

    echo -e "\n${UNDERLINE}${BOLD}Bright Foreground Colors Demo:${RESET}"
    echo -e "${FG_BRIGHT_BLACK}FG_BRIGHT_BLACK${RESET} ${FG_BRIGHT_RED}FG_BRIGHT_RED${RESET} ${FG_BRIGHT_GREEN}FG_BRIGHT_GREEN${RESET} ${FG_BRIGHT_YELLOW}FG_BRIGHT_YELLOW${RESET} ${FG_BRIGHT_BLUE}FG_BRIGHT_BLUE${RESET} ${FG_BRIGHT_MAGENTA}FG_BRIGHT_MAGENTA${RESET} ${FG_BRIGHT_CYAN}FG_BRIGHT_CYAN${RESET} ${FG_BRIGHT_WHITE}FG_BRIGHT_WHITE${RESET}"

    echo -e "\n${UNDERLINE}${BOLD}Regular Background Colors Demo:${RESET} (Text color is terminal default)"
    echo -e "${BG_BLACK} BG_BLACK ${RESET} ${BG_RED} BG_RED ${RESET} ${BG_GREEN} BG_GREEN ${RESET} ${BG_YELLOW} BG_YELLOW ${RESET} ${BG_BLUE} BG_BLUE ${RESET} ${BG_MAGENTA} BG_MAGENTA ${RESET} ${BG_CYAN} BG_CYAN ${RESET} ${BG_WHITE}${FG_BLACK} BG_WHITE ${RESET}" # Added FG_BLACK for BG_WHITE readability

    echo -e "\n${UNDERLINE}${BOLD}Bright Background Colors Demo:${RESET} (Text color is terminal default)"
    echo -e "${BG_BRIGHT_BLACK} BG_BRIGHT_BLACK ${RESET} ${BG_BRIGHT_RED} BG_BRIGHT_RED ${RESET} ${BG_BRIGHT_GREEN} BG_BRIGHT_GREEN ${RESET} ${BG_BRIGHT_YELLOW} BG_BRIGHT_YELLOW ${RESET} ${BG_BRIGHT_BLUE} BG_BRIGHT_BLUE ${RESET} ${BG_BRIGHT_MAGENTA} BG_BRIGHT_MAGENTA ${RESET} ${BG_BRIGHT_CYAN} BG_BRIGHT_CYAN ${RESET} ${BG_BRIGHT_WHITE}${FG_BLACK} BG_BRIGHT_WHITE ${RESET}" # Added FG_BLACK for BG_BRIGHT_WHITE readability

    echo -e "\n${UNDERLINE}${BOLD}Combined Demo:${RESET}"
    echo -e "${BOLD}${RED}This is BOLD RED text${RESET}"
    echo -e "${UNDERLINE}${FG_GREEN}This is UNDERLINED GREEN text${RESET}"
    echo -e "${BLINK}${YELLOW}This is BLINKING YELLOW text${RESET}"
    echo -e "${FG_CYAN}${BG_RED}This is CYAN text on a RED background${RESET}"
    echo -e "${BOLD}${FG_BRIGHT_WHITE}${BG_BLUE}This is BOLD BRIGHT WHITE text on a BLUE background${RESET}"

    echo -e "\n${UNDERLINE}${BOLD}Convenience Aliases Demo:${RESET}"
    echo -e "${RED}RED${RESET} ${GREEN}GREEN${RESET} ${YELLOW}YELLOW${RESET} ${BLUE}BLUE${RESET} ${MAGENTA}MAGENTA${RESET} ${PURPLE}(PURPLE)${RESET} ${CYAN}CYAN${RESET} ${WHITE}WHITE${RESET}"
    echo -e "${GRAY}GRAY${RESET} ${LIGHT_RED}LIGHT_RED${RESET} ${LIGHT_GREEN}LIGHT_GREEN${RESET} ${LIGHT_YELLOW}LIGHT_YELLOW${RESET} ${LIGHT_BLUE}LIGHT_BLUE${RESET} ${LIGHT_MAGENTA}LIGHT_MAGENTA${RESET} ${LIGHT_PURPLE}(LIGHT_PURPLE)${RESET} ${LIGHT_CYAN}LIGHT_CYAN${RESET} ${BRIGHT_WHITE}BRIGHT_WHITE${RESET}"

    echo -e "\n${BOLD}How to use in your script:${RESET}"
    echo -e "1. Save this file (e.g., as 'bash_colors.sh')."
    echo -e "2. In your other Bash script, add at the beginning:"
    echo -e "   ${CYAN}source /path/to/bash_colors.sh${RESET}"
    echo -e "3. Then use the color variables with echo -e:"
    echo -e "   ${CYAN}echo -e \"\${GREEN}Operation successful!\${RESET}\"${RESET}"
    echo -e "   ${CYAN}echo -e \"\${BOLD}\${YELLOW}Warning:\${RESET} \${YELLOW}Something needs attention.\${RESET}\"${RESET}"
fi
EOF
echo "to add the colors in $(ls ~/bash_colors.sh) in your file add \"source ~/bash_colors.sh\"" 
