#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Global Functions for Scripts #

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

# Log file
LOG="Install-Logs/install.log"

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"


# Show progress function
show_progress() {
    local pid=$1
    local package_name=$2
    local spin_chars=("●○○○○○○○○○" "○●○○○○○○○○" "○○●○○○○○○○" "○○○●○○○○○○" "○○○○●○○○○" \
                      "○○○○○●○○○○" "○○○○○○●○○○" "○○○○○○○●○○" "○○○○○○○○●○" "○○○○○○○○○●") 
    local i=0

    tput civis 
    printf "\r${INFO} Installing ${YELLOW}%s${RESET} ..." "$package_name"

    while ps -p $pid &> /dev/null; do
        printf "\r${INFO} Installing ${YELLOW}%s${RESET} %s" "$package_name" "${spin_chars[i]}"
        i=$(( (i + 1) % 10 ))  
        sleep 0.3  
    done

    printf "\r${INFO} Installing ${YELLOW}%s${RESET} ... Done!%-20s \n" "$package_name" ""
    tput cnorm  
}

# Function to install packages
install_package() {
  if rpm -q "$1" &>/dev/null ; then
    echo -e "${INFO} ${MAGENTA}$1${RESET} is already installed. Skipping..."
  else
    # Run rpm-ostree and redirect all output to a log file
    (
      stdbuf -oL sudo rpm-ostree install -y "$1" 2>&1
    ) >> "$LOG" 2>&1 &
    PID=$!
    show_progress $PID "$1" 
  fi
}

# Function for removing packages
uninstall_package() {
  local pkg="$1"

  # Checking if package is installed
  if rpm -q "$pkg" &>/dev/null; then
    echo -e "${NOTE} removing $pkg ..."
    sudo rpm-ostree remove -y "$pkg" 2>&1 | tee -a "$LOG" | grep -v "error: target not found"

  else
    echo -e "${INFO} Package $pkg not installed, skipping."
  fi
  return 0
}

# Function to verify packages
verify_package() {
  #Checking if package is installed
  if rpm -q "$1" &>/dev/null; then
    echo -e "${OK} Package ${YELLOW}$1${RESET} is installed."
  else
    echo -e "\n${ERROR} ${YELLOW}$1${RESET} failed to verify. Please check the $LOG. You may need to install manually."
  fi
}
