#!/usr/bin/env bash

###########################################################
# This file is part of the project:                       #
# linups-Linux-Packages-Update-Script                     #
#                                                         #
# License: GPL-3.0+                                       #
# License URL: https://www.gnu.org/licenses/gpl-3.0.html  #
#                                                         #
# This program is free software: you can redistribute it  #
# and/or modify it under the terms of the GNU General     #
# Public License as published by the Free Software        #
# Foundation, either version 3 of the License, or (at     #
# your option) any later version.                         #
#                                                         #
# This program is distributed in the hope that it will be #
# useful, but WITHOUT ANY WARRANTY; without even the      #
# implied warranty of MERCHANTABILITY or FITNESS FOR A    #
# PARTICULAR PURPOSE. See the GNU General Public License  #
# for more details.                                       #
#                                                         #
# You should have received a copy of the GNU General      #
# Public License along with this program. If not, see     #
# <http://www.gnu.org/licenses/>.                         #
#---------------------------------------------------------#
# Project: linups - Version 0.1 (beta)                    #
# This file: linups.sh                                    #
#                                                         #
# Script for Update, Cleanup, and Fix Software Packages   #
#                                                         #
# 1 - Open the terminal                                   #
# 2 - Go to directory of 'linups.sh'                      #
# 3 - Give 'linups.sh' execution permission:              #
# "chmod +x linups.sh"                                    #
# 4 - Execute 'linups.sh':                                #
# "./linups.sh"                                           #
# 5 - Optional: You can add an alias manually in your     #
# aliases files if you want. (recommended)*               #
# PS: If you used install.sh you can just use "linups"    #
# from anywhere of your system in your terminal.          #
#                                                         #
# See README for more information about installation and  #
# use.                                                    #
#                                                         #
# What does this script do?                               #
#                                                         #
# **IT'S A NO-INTERACT OR LOW-INTERACT SCRIPT**           #
# It checks if the package manager exists on your system, #
# and if it does, it executes the corresponding           #
# update/clean/fix commands. It is also capable of        #
# writing the output of the commands to a log file. (Edit #
# the value of the 'LOG_MODE' variable to "1" to enable   #
# logging). You can edit the 'LOG_DIR' variables to       #
# choose where to save your log file, and you can edit    #
# the 'LOG_FILE' variable to choose the name of the log   #
# file.                                                   #
#---------------------------------------------------------#
# Developer: Mozert M. Ramalho                            #
# Contact: https://github.com/mozertdev                   #
#                                                         #
# Last Update: 2025-04-12                                 #
#                                                         #
###########################################################


### SYSTEM CHECK
#### [NOTICE] ####
# The dependencies bash, cut and uname need to be checked before the others
# dependencies, and need to be one by one because bash v2.0 or below can't use
# iteratebles and they are used to check bash version and the operational system
# before the others dependencies check.

# Check if 'bash' command exists
command -v bash >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: The command 'bash' is not installed or not available in the PATH."
    echo "Install this to proceed!"
    exit 1
fi

# Check if 'cut' command exists
command -v cut >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: The command 'cut' is not installed or not available in the PATH."
    echo "Install this to proceed!"
    exit 1
fi

# Check if 'uname' command exists
command -v uname >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: The command 'uname' is not installed or not available in the PATH."
    echo "Install this to proceed!"
    exit 1
fi

# Check if the version of bash is greater than 2.0
MAJOR_BASH_VERSION="$(echo "$BASH_VERSION" | cut -d'.' -f1)"

if [[ "$MAJOR_BASH_VERSION" -lt 2 ]]; then
    echo "Your current Bash version is: $BASH_VERSION"
    echo "Error: This script requires Bash version 2.0 or higher."
    exit 1
fi

# Check if the system is Linux
if [ "$(uname -s)" != "Linux" ]; then
    echo "Error: This script only runs on Linux systems."
    exit 1
fi

### DEPENDENCIES
# List of dependencies the script needs
DEPENDENCIES=(
    "tee"
    "mkdir"
    "locale"
    "grep"
    "dirname"
    "basename"
    "eval"
    "date"
    "sudo"
    "ping"
)

# Loop to check all dependencies
for dep in "${DEPENDENCIES[@]}"; do
    command -v "$dep" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: The command '$dep' is not installed or not available in the PATH."
        echo "Install this to proceed!"
        exit 1
    fi
done

# ---------------------------------------------------------------------------- #

#------------------------------------------------------------------------------
# WARNING: DO NOT MODIFY ANYTHING ABOVE THIS LINE
#------------------------------------------------------------------------------

# ==================== OPTIONS TO BE MODIFIED IF YOU'D LIKE ====================

### GENERAL OPTIONS
#------------------------------------------------------------------------------
# Script Language
#------------------------------------------------------------------------------
# Description: Defines the system's language setting, typically obtained
#              from the environment. This variable might be used for
#              localization purposes within the script.
# Default Value: "$(locale | grep LANG | cut -d= -f2)" (Dynamically determined
#                  based on the system's locale settings)
# Example Values: "en_US", "pt_BR", "es_ES"
SYSTEM_LANG="$(locale | grep LANG | cut -d= -f2)"

#------------------------------------------------------------------------------
# Logging Mode
#------------------------------------------------------------------------------
# Description: Controls whether logging is enabled or disabled for the script's
#              execution. This flag determines if events and information
#              will be written to a log file.
# Default Value: "0" (Logging is disabled by default)
# Possible Values:
#   "0": Logging is disabled. No log file will be created or updated.
#   "1": Logging is enabled. Events and information will be written to the
#        specified log file.
LOG_MODE="0"

#------------------------------------------------------------------------------
# Log Directory
#------------------------------------------------------------------------------
# Description: Specifies the directory where the script's log files will be
#              stored. It is strongly recommended to use absolute paths to
#              avoid ambiguity and ensure consistent log file locations.
# Default Value: "$(dirname "$(readlink -f "$0")")" (The directory where the
#                  script itself is located)
# Important: Always use absolute paths for this variable.
LOG_DIR="$(dirname "$(readlink -f "$0")")"

#------------------------------------------------------------------------------
# Log File Name
#------------------------------------------------------------------------------
# Description: Defines the name of the log file that will be created (if
#              logging is enabled). It is recommended to use either the
#              ".log" or ".txt" file extension for log files.
# Default Value: "$(basename "$0" .sh)_log.log" (The script's name without
#                  the ".sh" extension, appended with "_log.log")
# Recommendation: Use either the ".log" or ".txt" extension for log files.
LOG_FILE="$(basename "$0" .sh)_log.log"

# ======================= END OF OPTIONS TO BE MODIFIED ========================

#------------------------------------------------------------------------------
# WARNING: DO NOT MODIFY ANYTHING BELOW THIS LINE
#------------------------------------------------------------------------------

### CONSTANTS
## Constants for Commands
# apt commands
APT_UPDATE_CMD=(
    "sudo apt update -y"
    "sudo apt upgrade -y"
)
APT_CLEAN_CMD=(
    "sudo apt autoremove -y"
    "sudo apt autoclean"
    "sudo apt clean"
)
APT_FIX_CMD=(
    "sudo apt install -f -y"
)

# dnf commands
DNF_UPDATE_CMD=(
    "sudo dnf check-update -y"
    "sudo dnf upgrade -y"
)
DNF_CLEAN_CMD=(
    "sudo dnf autoremove -y"
    "sudo dnf clean all"
)
DNF_FIX_CMD=(
    "sudo dnf check --fix"
)

# yum commands
YUM_UPDATE_CMD=(
    "sudo yum check-update -y"
    "sudo yum update -y"
)
YUM_CLEAN_CMD=(
    "sudo yum autoremove -y"
    "sudo yum clean all"
)
YUM_FIX_CMD=(
    "sudo yum-complete-transaction --cleanup-only"
)

# pacman commands
PACMAN_UPDATE_CMD=(
    "sudo pacman -Syu --noconfirm"
)
PACMAN_CLEAN_CMD=(
    "sudo pacman -Rns \$(pacman -Qdtq) --noconfirm"
)
PACMAN_FIX_CMD=(
    "sudo pacman -Syyu"
)

# zypper commands
ZYPPER_UPDATE_CMD=(
    "sudo zypper refresh"
    "sudo zypper update -y"
)
ZYPPER_CLEAN_CMD=(
    "sudo zypper clean"
)
ZYPPER_FIX_CMD=(
    "sudo zypper verify"
)

# flatpak commands
FLATPAK_UPDATE_CMD=(
    "flatpak update -y"
)
FLATPAK_CLEAN_CMD=(
    "flatpak uninstall --unused -y"
)
FLATPAK_FIX_CMD=(
    "flatpak repair"
)

# snap commands
SNAP_UPDATE_CMD=(
    "sudo snap refresh"
)
SNAP_CLEAN_CMD=(
    "sudo snap remove --purge \$(snap list | grep -oP '^\S+' | tail -n +2)"
)
SNAP_FIX_CMD=(
    "sudo snap refresh --beta"
)

# brew commands
BREW_UPDATE_CMD=(
    "brew update"
    "brew upgrade"
)
BREW_CLEAN_CMD=(
    "brew cleanup"
)
BREW_FIX_CMD=(
    "brew doctor"
)

### VARIABLES FOR LOCALIZATION
# Default messages in English
MSG_START="==== Starting the update, cleanup, and fix process ===="
MSG_END="==== End of Execution ===="
MSG_EXEC_STARTED="Execution started at: "
MSG_EXEC_COMPLETED="Execution completed at: "
MSG_ERROR_NO_INTERNET="Error: No internet connection detected."
MSG_CHECK_NETWORK_CONFIG="Please check your network configuration and try again."
MSG_LOG_DIR_CREATED="Log directory created: "
MSG_LOG_DIR_ERROR="Error: Failed to create log directory"
MSG_SUDO_REQUIRED="You need sudo permissions to run this script."
MSG_UPDATING_PKG="UPDATING PACKAGES USING"
MSG_CLEANING_PKG="CLEANING UP PACKAGES USING"
MSG_FIXING_PKG="FIXING BROKEN PACKAGES USING"

### FUNCTIONS
# Set language
set_language() {
    if [[ "$SYSTEM_LANG" =~ pt_BR ]]; then
        # Change messages to Portuguese if system is set to Brazilian Portuguese
        MSG_START="==== Iniciando o processo de atualização, limpeza e correção ===="
        MSG_END="==== Fim da Execução ===="
        MSG_EXEC_STARTED="Execução iniciada em: "
        MSG_EXEC_COMPLETED="Execução concluída em: "
        MSG_ERROR_NO_INTERNET="Erro: Nenhuma conexão de internet detectada."
        MSG_CHECK_NETWORK_CONFIG="Por favor, verifique sua configuração de internet e tente novamente."
        MSG_LOG_DIR_CREATED="Diretório de log criado: "
        MSG_LOG_DIR_ERROR="Erro: Falha ao criar o diretório de logs"
        MSG_SUDO_REQUIRED="Você precisa de permissões sudo para executar este script."
        MSG_UPDATING_PKG="ATUALIZANDO PACOTES USANDO"
        MSG_CLEANING_PKG="LIMPANDO PACOTES USANDO"
        MSG_FIXING_PKG="CONSERTANDO PACOTES QUEBRADOS USANDO"
    elif [[ "$SYSTEM_LANG" =~ es_ES ]]; then
        # Change messages to Spanish if system is set to Spanish
        MSG_START="==== Iniciando el proceso de actualización, limpieza y reparación ===="
        MSG_END="==== Fin de la ejecución ===="
        MSG_EXEC_STARTED="Ejecución iniciada en: "
        MSG_EXEC_COMPLETED="Ejecución completada en: "
        MSG_ERROR_NO_INTERNET="Error: No se detectó conexión a internet."
        MSG_CHECK_NETWORK_CONFIG="Por favor, revise su configuración de internet e intente nuevamente."
        MSG_LOG_DIR_CREATED="Directorio de log creado: "
        MSG_LOG_DIR_ERROR="Error: No se pudo crear el directorio de logs"
        MSG_SUDO_REQUIRED="Necesitas permisos sudo para ejecutar este script."
        MSG_UPDATING_PKG="ACTUALIZANDO PAQUETES USANDO"
        MSG_CLEANING_PKG="LIMPIANDO PAQUETES USANDO"
        MSG_FIXING_PKG="REPARANDO PAQUETES ROTO USANDO"
    fi
}

# Tests the internet connection by attempting to ping a reliable external host.
check_internet_connection() {
    # Define the host to ping for testing the internet connection.
    # Google's public DNS server (8.8.8.8) is a reliable choice.
    local ping_host="8.8.8.8"
    local ping_count=1

    if ping -c "$ping_count" -w 2 "$ping_host" > /dev/null 2>&1; then
        return 0
    else
        echo "$MSG_ERROR_NO_INTERNET"
        echo "$MSG_CHECK_NETWORK_CONFIG"
        exit 1
    fi
}

# Check for sudo or root permissions
check_sudo() {
    sudo -v 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "$MSG_SUDO_REQUIRED"
        exit 1
    fi
}

# Log messages
log_message() {
    local message="$1"
    if [ "$LOG_MODE" = "1" ]; then
        # If LOG_MODE is enabled, log the message to the file and show on screen
        echo -e "$message" | tee -a "$LOG_DIR/$LOG_FILE"
    else
        # If LOG_MODE is disabled, just show the message on screen
        echo -e "$message"
    fi
}

# Ensure the log directory exists
ensure_log_dir_exists() {
    if [ ! -d "$LOG_DIR" ]; then
        # Attempt to create the directory and capture any error output
        mkdir -p "$LOG_DIR" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo -e "$MSG_LOG_DIR_ERROR $LOG_DIR."
            exit 1
        fi
        log_message "$MSG_LOG_DIR_CREATED $LOG_DIR"
    fi
}


# Unified function to update, clean, and fix packages
update_clean_fix() {
    local package_manager=$1
    local update_cmds=("${!2}")
    local clean_cmds=("${!3}")
    local fix_cmds=("${!4}")
    
    if command -v "$package_manager" &>/dev/null; then
        log_message "\n[$MSG_UPDATING_PKG *$package_manager*]"
        for cmd in "${update_cmds[@]}"; do
            log_message "\n\$ $cmd"
            if [ "$LOG_MODE" = "1" ]; then
                eval "$cmd" | tee -a "$LOG_DIR/$LOG_FILE"
            else
                eval "$cmd"
            fi
        done
        
        log_message "\n[$MSG_CLEANING_PKG *$package_manager*]"
        for cmd in "${clean_cmds[@]}"; do
            log_message "\n\$ $cmd"
            if [ "$LOG_MODE" = "1" ]; then
                eval "$cmd" | tee -a "$LOG_DIR/$LOG_FILE"
            else
                eval "$cmd"
            fi
        done
        
        log_message "\n[$MSG_FIXING_PKG *$package_manager*]"
        for cmd in "${fix_cmds[@]}"; do
            log_message "\n\$ $cmd"
            if [ "$LOG_MODE" = "1" ]; then
                eval "$cmd" | tee -a "$LOG_DIR/$LOG_FILE"
            else
                eval "$cmd"
            fi
        done
    fi
}

### MAIN FUNCTION
main() {
    # Set language based on system locale
    set_language
    
    # Request sudo permissions
    check_sudo
    
    # Test internet connection
    check_internet_connection
    
    # Ensure the log directory exists
    ensure_log_dir_exists
    
    
    log_message "\n$MSG_START"
    log_message "\n$MSG_EXEC_STARTED$(date)"
    
    # Update, cleanup, and fix for each package manager
    update_clean_fix "apt" "APT_UPDATE_CMD[@]" "APT_CLEAN_CMD[@]" "APT_FIX_CMD[@]"
    update_clean_fix "dnf" "DNF_UPDATE_CMD[@]" "DNF_CLEAN_CMD[@]" "DNF_FIX_CMD[@]"
    update_clean_fix "yum" "YUM_UPDATE_CMD[@]" "YUM_CLEAN_CMD[@]" "YUM_FIX_CMD[@]"
    update_clean_fix "pacman" "PACMAN_UPDATE_CMD[@]" "PACMAN_CLEAN_CMD[@]" "PACMAN_FIX_CMD[@]"
    update_clean_fix "zypper" "ZYPPER_UPDATE_CMD[@]" "ZYPPER_CLEAN_CMD[@]" "ZYPPER_FIX_CMD[@]"
    update_clean_fix "flatpak" "FLATPAK_UPDATE_CMD[@]" "FLATPAK_CLEAN_CMD[@]" "FLATPAK_FIX_CMD[@]"
    update_clean_fix "snap" "SNAP_UPDATE_CMD[@]" "SNAP_CLEAN_CMD[@]" "SNAP_FIX_CMD[@]"
    update_clean_fix "brew" "BREW_UPDATE_CMD[@]" "BREW_CLEAN_CMD[@]" "BREW_FIX_CMD[@]"
    
    log_message "\n$MSG_EXEC_COMPLETED$(date)"
    log_message "\n$MSG_END"
}

# ---------------------------------------------------------------------------- #

### CALL THE MAIN FUNCTION
main
