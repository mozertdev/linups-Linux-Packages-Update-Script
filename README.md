# Linups - System Package Update Script

**<mark>Version 0.1 (beta)</mark>**

Keep your Linux always optimized. Use Linups for effortless updates across numerous package managers, now with optional logging.

Linups is a versatile command-line utility designed to streamline the management of installed packages across various Linux distributions. It provides a unified interface to update, clean, and fix packages managed by popular package managers, ensuring your system stays up-to-date and optimized.

## Key Features

* **Cross-Platform Package Management:** Supports a wide range of package managers, including:
  
  * APT (Debian, Ubuntu, etc.)
  * DNF (Fedora, CentOS, etc.)
  * YUM (Older CentOS, RHEL)
  * PACMAN (Arch Linux, Manjaro)
  * ZYPPER (openSUSE)
  * FLATPAK
  * SNAP
  * BREW (Homebrew for and Linux)

* **Comprehensive System Maintenance:** Simplifies the process of updating, fixing, and cleaning installed packages with a single command.

* **Robust Logging System (Optional):**
  
  * Detailed logging of operations can be enabled via the `linups.sh` script.
  * Customizable log file name (`LOG_FILE`) and directory (`LOG_DIR`).
  * Provides valuable insights into the actions performed by the utility.

* **Internationalization (i18n):** Built-in support for multiple languages:
  
  * English
  * Portuguese (Brazil)
  * Español

* **Automatic Localization (l10n):**
  
  * Intelligently detects the system's language settings.
  * Offers the flexibility to manually set the language using the `SYSTEM_LANG` variable.
  * Supported locales:
    * `en_US` (English - Default)
    * `pt_BR` (Portuguese - Brazil)
    * `es_ES` (Español)

## Getting Started

You will need `git` to download the project and `bash` **version 2.0** or higher to run the `linups.sh` correctly.

### Automated Installation (Recommended)

1. **Open your terminal**

2. **Navigate to the desired installation directory:** Use the `cd` command to go to the directory where you want to install 'linups'. For example:
   
   ```bash
   cd Downloads
   ```
   
   PS: We strongly recommend that you create a dedicated directory to hold your scripts. For example:
   
   ```bash
   mkdir -p "~/Documents/scripts"
   ```

3. **For a quick and easy installation, you can execute the following command in your terminal. This command will handle cloning the repository, navigating to the project directory, granting execution permissions, and running the installation script:**
   
   ```bash
   git clone "https://github.com/mozertdev/linups-Linux-Packages-Update-Script" && cd "linups-Linux-Packages-Update-Script" && chmod +x install.sh && ./install.sh
   ```

4. **Restart your terminal:** Close your current terminal session and open a new one. This ensures that any environment changes made by the installation script are properly loaded.

5. **Use the script:** You can now use the `linups` command if the installation script added it to your `aliases files`, or by running it directly from the project directory:
   
   ```bash
   linups
   ```
   
   Or, from the project directory:
   
   ```bash
   ./linups.sh
   ```

### Scripted Installation

1. **Open your terminal**

2. **Navigate to the desired installation directory:** Use the `cd` command to go to the directory where you want to install 'linups'. For example:
   
   ```bash
   cd Downloads
   ```
   
   PS: We strongly recommend that you create a dedicated directory to hold your scripts. For example:
   
   ```bash
   mkdir -p "~/Documents/scripts"
   ```

3. **Clone the project repository:** Use `git` to clone the Linups repository from GitHub:
   
   ```bash
   git clone "https://github.com/mozertdev/linups-Linux-Packages-Update-Script"
   ```

4. **Enter the project folder:** Navigate into the newly cloned directory:
   
   ```bash
   cd "linups-Linux-Packages-Update-Script"
   ```

5. **Grant execution permission to the script:** Make the `install.sh` script executable:
   
   ```bash
   chmod +x install.sh
   ```

6. **Run the script:** Execute the `install.sh` script:
   
   ```bash
   ./install.sh
   ```

7. **Restart your terminal:** Close your current terminal session and open a new one. This ensures that any environment changes made by the installation script are properly loaded.

8. **Use the script:** You can now use the `linups` command if the installation script added it to your `aliases files`, or by running it directly from the project directory:
   
   ```bash
   linups
   ```
   
   Or, from the project directory:
   
   ```bash
   ./linups
   ```

## Configuration

The behavior of Linups can be customized by modifying variables within the `linups.sh` script.

* **`LOG_MODE`:** Set to `"1"` to enable logging. Defaults to `"0"` to disable.
* **`LOG_DIR`:** Define the absolute path to the directory where the log file will be saved. Defaults to the script's directory.
* **`LOG_FILE`:** Specify the name of the log file. Defaults to `linups_log.log`. Remember to enclose the new value in double quotes (e.g., `"custom_log.log"`).
* **`SYSTEM_LANG`:** Manually set the desired language. Supported values: `"en_US"`, `"pt_BR"`, `"es_ES"`. Defaults to automatic system language detection.

**Example Configuration:**

```bash
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

# Force English language
SYSTEM_LANG="en_US"

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

# Enable logging
LOG_MODE="1"

#------------------------------------------------------------------------------
# Log Directory
#------------------------------------------------------------------------------
# Description: Specifies the directory where the script's log files will be
#              stored. It is strongly recommended to use absolute paths to
#              avoid ambiguity and ensure consistent log file locations.
# Default Value: "$(dirname "$(readlink -f "$0")")" (The directory where the
#                  script itself is located)
# Important: Always use absolute paths for this variable.

# Set a custom log directory
LOG_DIR="/var/log/linups"

#------------------------------------------------------------------------------
# Log File Name
#------------------------------------------------------------------------------
# Description: Defines the name of the log file that will be created (if
#              logging is enabled). It is recommended to use either the
#              ".log" or ".txt" file extension for log files.
# Default Value: "$(basename "$0" .sh)_log.log" (The script's name without
#                  the ".sh" extension, appended with "_log.log")
# Recommendation: Use either the ".log" or ".txt" extension for log files.

# Set a custom log file name
LOG_FILE="system_updates.log"

# ======================= END OF OPTIONS TO BE MODIFIED ========================
```

## Version Information

This is version **0.1 (beta)**, released on **2025-04-12**.

As a beta release, it may contain errors or bugs. Your feedback is highly appreciated. Please report any issues or suggestions through the project's issue tracker.

## Contributing

We welcome contributions! If you encounter any issues or have suggestions for improvements, please feel free to:

- Report bugs through the issue tracker.
- Suggest new features or enhancements.

## License

GPL-3.0 License [https://www.gnu.org/licenses/gpl-3.0.html.en](https://www.gnu.org/licenses/gpl-3.0.html.en)
