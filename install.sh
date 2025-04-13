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
# This file: install.sh                                   #
#                                                         #
# Script to "install" linups                              #
# Adds execute permission to linups.sh and sets an        #
# alias in:                                               #
# $HOME/.bash_aliases                                     #
# $HOME/.oh-my-zsh/custom/aliases.zsh                     #
#                                                         #
# 1 - Open the terminal                                   #
# 2 - Go to directory of 'install.sh'                     #
# 3 - Give 'install.sh' execution permission:             #
# "chmod +x install.sh"                                   #
# 4 - Execute 'install.sh':                               #
# "./install.sh"                                          #
#                                                         #
# See README for more information about installation and  #
# use.                                                    #
#                                                         #
# What does this script do?                               #
#                                                         #
# **IT'S A NO-INTERACT OR LOW-INTERACT SCRIPT**           #
# It "installs" the 'linups.sh' script. First it gives    #
# execution permission to 'linups.sh', then it searches   #
# for the alias files '$HOME/.bash_aliases' and           #
#'$HOME/.oh-my-zsh/custom/aliases.zsh', if it finds them, #
# it adds an alias called 'linups' to make it easier to   #
# access the script from any part of the operating system.#
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
    "touch"
    "tee"
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
SCRIPT_FILE="linups.sh"                # Target script file name
SCRIPT_PATH="$INSTALLER_DIR/$SCRIPT_FILE"  # Absolute path to target script file

# Alias name
ALIAS_NAME="linups"

# Alias files to add the alias to
#    "$HOME/Documentos/scripts/exemplo/.arquivo_alias_oculto.txt"
#    "$HOME/Documentos/scripts/exemplo/.pasta_oculta/custom/arquivo_alias.txt"
ALIAS_FILES=(
    "$HOME/.bash_aliases"
    "$HOME/.oh-my-zsh/custom/aliases.zsh"
)

# List of files to increase execution privileges
FILES_TO_GIVE_PERMISSION=(
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
MSG_ALIAS_ADDING="Adding alias to the file..."
MSG_ALIAS_CREATING="Creating alias file: "
MSG_ALIAS_ADDED="Success: Alias was added"
MSG_ALIAS_EXISTS="Alias already exists"
MSG_ALIAS_FILE_ERROR="Error: Failed to create alias file"
MSG_ALIAS_FILE_CREATED="Success: Alias file created"

# Permission related messages
MSG_PERMISSION_ADDING="Adding execute permission to file: "
MSG_PERMISSION_ADDED="Success: Execute permission was added"
MSG_PERMISSION_EXISTS="The file already has execute permission"
MSG_PERMISSION_ERROR="Error: Execute permission was not added"

# Directory related messages
MSG_DIR_NOT_EXISTS="Directory for alias file does not exist."

# Main function related messages
MSG_INSTALLER_START="INSTALLER / ALIASES RESOLVER TO: "
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
        MSG_ALIAS_ADDING="Adicionando alias ao arquivo... "
        MSG_ALIAS_CREATING="Criando arquivo de alias: "
        MSG_ALIAS_ADDED="Sucesso: Alias foi adicionado"
        MSG_ALIAS_EXISTS="Alias já existe"
        MSG_ALIAS_FILE_ERROR="Erro: Falha ao criar arquivo de alias"
        MSG_ALIAS_FILE_CREATED="Sucesso: Arquivo de alias criado"
        MSG_PERMISSION_ADDING="Adicionando permissão de execução ao arquivo: "
        MSG_PERMISSION_ADDED="Sucesso: Permissão de execução foi adicionada"
        MSG_PERMISSION_EXISTS="O arquivo já tem permissão de execução"
        MSG_PERMISSION_ERROR="Erro: Permissão de execução não foi adicionada"
        MSG_DIR_NOT_EXISTS="O diretório para o arquivo de alias não existe."
        
        # Main function messages in Portuguese
        MSG_INSTALLER_START="INSTALADOR / RESOLUTOR DE ALIASES PARA: "
        MSG_PERMISSIONS_SECTION="[PERMISSÕES]"
        MSG_ALIASES_SECTION="[ALIASES]"
        MSG_END_EXECUTION="==== Fim da Execução ===="
    elif [[ "$SYSTEM_LANG" =~ es_ES ]]; then
        # Change messages to Spanish if system is set to Spanish
        MSG_SUDO_REQUIRED="Necesitas permisos sudo para ejecutar este script."
        MSG_SCRIPT_FILE_SEARCH="Intentando encontrar el archivo: "
        MSG_SCRIPT_FILE_ERROR="Error: El archivo no existe."
        MSG_ALIAS="Alias: "
        MSG_ALIAS_RESOLVING="Resolviendo aliases en: "
        MSG_ALIAS_ADDING="Añadiendo alias al archivo... "
        MSG_ALIAS_CREATING="Creando archivo de alias: "
        MSG_ALIAS_ADDED="Éxito: Alias fue añadido"
        MSG_ALIAS_EXISTS="Alias ya existe"
        MSG_ALIAS_FILE_ERROR="Error: No se pudo crear el archivo de alias"
        MSG_ALIAS_FILE_CREATED="Éxito: Archivo de alias creado"
        MSG_PERMISSION_ADDING="Añadiendo permiso de ejecución al archivo: "
        MSG_PERMISSION_ADDED="Éxito: Permiso de ejecución añadido"
        MSG_PERMISSION_EXISTS="El archivo ya tiene permiso de ejecución"
        MSG_PERMISSION_ERROR="Error: El permiso de ejecución no se añadió"
        MSG_DIR_NOT_EXISTS="El directorio para el archivo de alias no existe."
        
        # Main function messages in Spanish
        MSG_INSTALLER_START="INSTALADOR / RESOLUTOR DE ALIASES PARA: "
        MSG_PERMISSIONS_SECTION="[PERMISOS]"
        MSG_ALIASES_SECTION="[ALIASES]"
        MSG_END_EXECUTION="==== Fin de la Ejecución ===="
    fi
}

# This function takes a file path as an argument and checks if the file exists.
# If the file does not exist, the script will print an error message and
# terminate with an exit code of 1,
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

# Function to add alias to specified alias files if the alias doesn't exist
# Arguments:
# 1. alias_files (array): List of paths to alias files
# 2. script_path (string): Path to the script to be aliased
# 3. alias_name (string): The name of the alias to be created
add_alias() {
    local alias_files=("${!1}")      # List of alias files paths
    local script_path="$2"            # Path to the script
    local alias_name="$3"             # Alias name to create
    local alias_command="alias $alias_name=\"$script_path\""  # Alias command to be added
    
    # Iterate over each alias file path in the list
    for alias_file in "${alias_files[@]}"; do
        echo "$MSG_ALIAS_RESOLVING$alias_file"
        echo "$MSG_ALIAS$alias_name"
        # Check if the directory of the alias file exists
        if [ -d "$(dirname "$alias_file")" ]; then
            # Check if the alias file exists
            if [ ! -f "$alias_file" ]; then
                # Create the alias file if it does not exist
                echo "$MSG_ALIAS_CREATING$alias_file"
                touch "$alias_file"
                if [ -f "$alias_file" ]; then
                    echo "$MSG_ALIAS_FILE_CREATED"
                else
                    echo "$MSG_ALIAS_FILE_ERROR"
                    continue
                fi
            fi
            
            # Check if the alias already exists in the file
            if ! grep -q "alias $alias_name=" "$alias_file"; then
                # If alias does not exist, add it
                echo "$MSG_ALIAS_ADDING"
                echo "$alias_command" | sudo tee -a $alias_file > /dev/null
                if [ $? -eq 0 ]; then
                    echo "$MSG_ALIAS_ADDED"
                else
                    echo "$MSG_ALIAS_FILE_ERROR"
                fi
            else
                # If alias exists, skip adding it
                echo "$MSG_ALIAS_EXISTS"
            fi
        else
            # If the directory for the alias file does not exist
            echo "$MSG_DIR_NOT_EXISTS"
        fi
    done
}

# Function to ensure files have execution permissions
# Arguments:
# 1. files (array): List of file paths to check and set execution permission
increase_execution_permissions() {
    local files=("${!1}")  # List of files to check
    
    for file in "${files[@]}"; do
        # Check if the file has execution permission
        echo "$MSG_PERMISSION_ADDING$file"
        if [ ! -x "$file" ]; then
            sudo chmod +x "$file"
            if [ -x "$file" ]; then
                echo "$MSG_PERMISSION_ADDED"
            else
                echo "$MSG_PERMISSION_ERROR"
            fi
        else
            echo "$MSG_PERMISSION_EXISTS"
        fi
    done
}

### MAIN FUNCTION
main() {
    # Set language based on system locale
    set_language
    
    # Check if the target script exists
    check_file_existence "$SCRIPT_PATH"
    
    # Request sudo permissions
    check_sudo
    
    
    echo -e "\n$MSG_INSTALLER_START$SCRIPT_FILE"
    
    echo -e "\n$MSG_PERMISSIONS_SECTION\n"
    
    # Call the function to increase execution permissions for files
    increase_execution_permissions FILES_TO_GIVE_PERMISSION[@]
    
    echo -e "\n$MSG_ALIASES_SECTION\n"
    # Call the function to add the alias to the files
    add_alias ALIAS_FILES[@] "$SCRIPT_PATH" "$ALIAS_NAME"
    
    echo -e "\n$MSG_END_EXECUTION"
}

# ---------------------------------------------------------------------------- #

### CALL THE MAIN FUNCTION
main
