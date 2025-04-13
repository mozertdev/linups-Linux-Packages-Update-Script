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
# This file: uninstall.sh                                 #
#                                                         #
# Script to "uninstall" linups.sh                         #
# Removes execute permission from script_name.sh and      #
# removes all aliases matching the alias name from:       #
# $HOME/.bash_aliases                                     #
# $HOME/.oh-my-zsh/custom/aliases.zsh                     #
#                                                         #
# 1 - Open the terminal                                   #
# 2 - Go to directory of 'uninstall.sh'                   #
# 3 - Give 'uninstall.sh' execution permission:           #
# "chmod +x uninstall.sh"                                 #
# 4 - Execute 'uninstall.sh':                             #
# "./uninstall.sh"                                        #
#                                                         #
# See README for more information about installation and  #
# use.                                                    #
#                                                         #
# What does this script do?                               #
#                                                         #
# **IT'S A NO-INTERACT OR LOW-INTERACT SCRIPT**           #
# It "uninstalls" the linups.sh script. First it removes  #
# the execution permission for linups.sh, then it         #
# searches for the alias files '$HOME/.bash_aliases' and  #
# '$HOME/.oh-my-zsh/custom/aliases.zsh', if it finds      #
# them, it removes all aliases called 'linups'.           #
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
    "locale"
    "grep"
    "dirname"
    "readlink"
    "chmod"
    "sed"
    "sudo"
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

### CONSTANTS
## General options
# Script language DEFAULT: $(locale | grep LANG | cut -d= -f2)
SYSTEM_LANG="$(locale | grep LANG | cut -d= -f2)" # "en_US", "pt_BR", es_ES

# Path to the target script file (absolute path)
INSTALLER_DIR="$(dirname "$(readlink -f "$0")")" # INSTALLER script file directory
SCRIPT_FILE="linups.sh"             # Target script file name
SCRIPT_PATH="$INSTALLER_DIR/$SCRIPT_FILE"   # Absolute path to target script file

# Alias name
ALIAS_NAME="linups"

# Alias files to remove the alias from
ALIAS_FILES=(
    "$HOME/.bash_aliases"
    "$HOME/.oh-my-zsh/custom/aliases.zsh"
)

# List of files to decrease execution privileges
FILES_TO_REMOVE_PERMISSION=(
    "$SCRIPT_PATH"
)

### VARIABLES FOR LOCALIZATION
# Default messages in English
# System Messages
MSG_SUDO_REQUIRED="You need sudo permissions to run this script."
MSG_SCRIPT_FILE_SEARCH="Trying to find file: "
MSG_SCRIPT_FILE_ERROR="Error: The file does not exist."

# Alias related messages
MSG_ALIAS="Alias: "
MSG_ALIAS_RESOLVING="Resolving aliases in: "
MSG_ALIAS_REMOVING="Removing all aliases matching: "
MSG_ALIAS_NOT_FOUND="No aliases matching: "
MSG_ALIAS_REMOVED="Success: All matching aliases were removed"
MSG_ALIAS_FILE_ERROR="Error: Failed to modify alias file"
MSG_ALIAS_FILE_WARNING="Warning: Alias file not found."

# Permission related messages
MSG_PERMISSION_REMOVING="Removing execute permission from file: "
MSG_PERMISSION_REMOVED="Success: Execute permission was removed"
MSG_PERMISSION_NOT_EXISTS="The file does not have execute permission or does not exist"
MSG_PERMISSION_ERROR="Error: Execute permission was not removed"
MSG_PERMISSION_WARNING="Warning: File not found."

# Main function related messages
MSG_UNINSTALLER_START="UNINSTALLER / ALIASES REMOVER FROM: "
MSG_PERMISSIONS_SECTION="[PERMISSIONS]"
MSG_ALIASES_SECTION="[ALIASES]"
MSG_END_EXECUTION="==== End of Execution ===="

### FUNCTIONS
# Set language
set_language() {
    if [[ "$SYSTEM_LANG" =~ pt_BR ]]; then
        # Change messages to Portuguese if system is set to Brazilian Portuguese
        MSG_SUDO_REQUIRED="Você precisa de permissões sudo para executar este script."
        MSG_SCRIPT_FILE_SEARCH="Tentando encontrar o arquivo: "
        MSG_SCRIPT_FILE_ERROR="Erro: O arquivo não existe."
        MSG_ALIAS="Alias: "
        MSG_ALIAS_RESOLVING="Resolvendo aliases em: "
        MSG_ALIAS_REMOVING="Removendo todos os aliases correspondentes à: "
        MSG_ALIAS_NOT_FOUND="Nenhum aliase correspondente: "
        MSG_ALIAS_REMOVED="Sucesso: Todos os aliases correspondentes foram removidos"
        MSG_ALIAS_FILE_ERROR="Erro: Falha ao modificar arquivo de alias"
        MSG_ALIAS_FILE_WARNING="Aviso: arquivo de alias não encontrado."
        MSG_PERMISSION_REMOVING="Removendo permissão de execução do arquivo: "
        MSG_PERMISSION_REMOVED="Sucesso: Permissão de execução foi removida"
        MSG_PERMISSION_NOT_EXISTS="O arquivo não tem permissão de execução ou não existe"
        MSG_PERMISSION_ERROR="Erro: Permissão de execução não foi removida"
        MSG_PERMISSION_WARNING="Aviso: Arquivo não encontrado."

        # Main function messages in Portuguese
        MSG_UNINSTALLER_START="DESINSTALADOR / REMOVEDOR DE ALIASES DE: "
        MSG_PERMISSIONS_SECTION="[PERMISSÕES]"
        MSG_ALIASES_SECTION="[ALIASES]"
        MSG_END_EXECUTION="==== Fim da Execução ===="
    elif [[ "$SYSTEM_LANG" =~ es_ES ]]; then
        # Change messages to Spanish if system is set to Spanish
        MSG_SUDO_REQUIRED="Necesitas permisos sudo para ejecutar este script."
        MSG_SCRIPT_FILE_SEARCH="Intentando encontrar el archivo: "
        MSG_SCRIPT_FILE_ERROR="Error: El archivo no existe."
        MSG_ALIAS="Alias: "
        MSG_ALIAS_RESOLVING="Resolviendo alias en: "
        MSG_ALIAS_REMOVING="Eliminando todos los alias coincidentes: "
        MSG_ALIAS_NOT_FOUND="No hay alias coincidentes: "
        MSG_ALIAS_REMOVED="Éxito: Se eliminaron todos los alias coincidentes"
        MSG_ALIAS_FILE_ERROR="Error: No se pudo modificar el archivo de alias"
        MSG_ALIAS_FILE_WARNING="Advertencia: archivo de alias no encontrado".
        MSG_PERMISSION_REMOVING="Eliminando permiso de ejecución del archivo: "
        MSG_PERMISSION_REMOVED="Éxito: Permiso de ejecución eliminado"
        MSG_PERMISSION_NOT_EXISTS="El archivo no tiene permiso de ejecución o no existe"
        MSG_PERMISSION_ERROR="Error: El permiso de ejecución no se eliminó"
        MSG_PERMISSION_WARNING="Advertencia: Archivo no encontrado."

        # Main function messages in Spanish
        MSG_UNINSTALLER_START="DESINSTALADOR / ELIMINADOR DE ALIASES DE: "
        MSG_PERMISSIONS_SECTION="[PERMISOS]"
        MSG_ALIASES_SECTION="[ALIAS]"
        MSG_END_EXECUTION="==== Fin de la Ejecución ===="
    fi
}

# This function takes a file path as an argument and checks if the file exists.
# If the file does not exist, the script will print an error message and
# terminate with an exit code of 1.
# Arguments::
# 1: The path to the file to be checked.
# Returns:
# None
check_file_existence() {
    local file_path="$1"

    # Check if the provided file path exists and is a regular file.
    if [ ! -f "$file_path" ]; then
        # Print an error message to stderr indicating the file was not found.
        echo "$MSG_SCRIPT_FILE_SEARCH$file_path"
        echo "$MSG_SCRIPT_FILE_ERROR"
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

# ---------------------------------------------------------------------------- #

# Function to remove all aliases matching a pattern from specified alias files
# Arguments:
# 1. alias_files (array): List of paths to alias files
# 2. alias_name (string): The base name of the alias to be removed (e.g., "script_alias")
remove_matching_aliases() {
    local alias_files=("${!1}")     # List of alias files paths
    local alias_name="$2"           # Alias name to match
    local alias_pattern="^alias $alias_name=" # Pattern to find lines starting with "alias $alias_name="

    # Iterate over each alias file path in the list
    for alias_file in "${alias_files[@]}"; do
        echo "$MSG_ALIAS_RESOLVING$alias_file"
        echo "$MSG_ALIAS$alias_name" # Indicate that we are looking for matches
        # Check if the alias file exists
        if [ -f "$alias_file" ]; then
            # Check if any aliases matching the pattern exist in the file
            if grep -q "$alias_pattern" "$alias_file"; then
                # If matching aliases exist, remove them using sed
                echo "$MSG_ALIAS_REMOVING$alias_name"
                sudo sed -i "/$alias_pattern/d" "$alias_file"
                if [ $? -eq 0 ]; then
                    echo "$MSG_ALIAS_REMOVED"
                else
                    echo "$MSG_ALIAS_FILE_ERROR"
                fi
            else
                # If no matching aliases are found, inform the user
                echo "$MSG_ALIAS_NOT_FOUND$alias_name"
            fi
        else
            echo "$MSG_ALIAS_FILE_WARNING"
        fi
    done
}

# Function to remove execution permissions from files
# Arguments:
# 1. files (array): List of file paths to check and remove execution permission
decrease_execution_permissions() {
    local files=("${!1}")  # List of files to check

    for file in "${files[@]}"; do
        # Check if the file exists
        if [ -f "$file" ]; then
            # Check if the file has execution permission
            echo "$MSG_PERMISSION_REMOVING$file"
            if [ -x "$file" ]; then
                sudo chmod -x "$file"
                if [ ! -x "$file" ]; then
                    echo "$MSG_PERMISSION_REMOVED"
                else
                    echo "$MSG_PERMISSION_ERROR"
                fi
            else
                echo "$MSG_PERMISSION_NOT_EXISTS"
            fi
        else
            echo "$MSG_PERMISSION_WARNING"
        fi
    done
}

### MAIN FUNCTION
main() {
    # Set language based on system locale
    set_language

    # Check if the target script exists
    #check_file_existence "$SCRIPT_PATH"   # Uncomment to enable file validation

    # Request sudo permissions
    check_sudo


    echo -e "\n$MSG_UNINSTALLER_START$SCRIPT_FILE"

    echo -e "\n$MSG_PERMISSIONS_SECTION\n"

    # Call the function to remove execution permissions from files
    decrease_execution_permissions FILES_TO_REMOVE_PERMISSION[@]

    echo -e "\n$MSG_ALIASES_SECTION\n"
    # Call the function to remove all matching aliases from the files
    remove_matching_aliases ALIAS_FILES[@] "$ALIAS_NAME"

    echo -e "\n$MSG_END_EXECUTION"
}

# ---------------------------------------------------------------------------- #

### CALL THE MAIN FUNCTION
main
