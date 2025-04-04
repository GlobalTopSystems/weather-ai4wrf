#!/bin/bash
# Conda environment test
if [ -n "$CONDA_DEFAULT_ENV" ];
then
echo "CONDA_DEFAULT_ENV is active: $CONDA_DEFAULT_ENV"
echo "Turning off $CONDA_DEFAULT_ENV"
conda deactivate
conda deactivate
else
echo "CONDA_DEFAULT_ENV is not active."
echo "Continuing script"
fi
start=$(date)
START=$(date +"%s")
############################### Version Numbers ##########################
# For Ease of updating
##########################################################################
#export METPLUS_Version=5.1.0
#export met_Version_number=11.1.1
#export met_VERSION_number=11.1
#export METPLUS_DATA=5.1
export Zlib_Version=1.3.1
export Mpich_Version=4.2.3
export Libpng_Version=1.6.39
export Jasper_Version=1.900.1
export HDF5_Version=1.14.4
export HDF5_Sub_Version=3
export Pnetcdf_Version=1.13.0
export Netcdf_C_Version=4.9.2
export Netcdf_Fortran_Version=4.6.1
#export WRF_VERSION=4.6.1
#export WPS_VERSION=4.6.0
############################### Citation Requirement  ####################
echo " "
echo " The Global Top Systems Company at GitHub site for Weather-AI software (Version 2.0.2.5) by B. Vasiliu (2025)"
echo " "
echo "It is important to note that any usage or publication that incorporates or references this software must include a proper citation to acknowledge the work of the author."
echo " "
echo -e "This is not only a matter of respect and academic integrity, but also a \e[31mrequirement\e[0m set by the author."
echo " "
echo " Please ensure to adhere to this guideline when using this software."
echo " "
echo -e "\e[31mCitation: Vasiliu, B., Global Top Systems Company [GTS]. Weather-AI: an HyperConvergent Infrastructure Appliance [HCIApp], modular and cross-platform  tool for configuring and installing OpenSource Meteorological Software [Computer software]."
echo " "
read -p "Press enter to continue"

############################### System Architecture Type #################
# Determine if the system is 32 or 64-bit based on the architecture
##########################################################################
export SYS_ARCH=$(uname -m)
if [ "$SYS_ARCH" = "x86_64" ] || [ "$SYS_ARCH" = "arm64" ];
then
export SYSTEMBIT="64"
else
export SYSTEMBIT="32"
fi
# Determine the chip type if on macOS (ARM or Intel)
if [ "$SYS_ARCH" = "arm64" ];
then 
export MAC_CHIP="ARM"
else
export MAC_CHIP="Intel"
fi
############################# System OS Version #############################
# Detect if the OS is macOS or Linux
#############################################################################
export SYS_OS=$(uname -s)
if [ "$SYS_OS" = "Darwin" ]; then export SYSTEMOS="MacOS"
# Get the macOS version using sw_vers
export MACOS_VERSION=$(sw_vers -productVersion)
echo "Operating system detected: MacOS, Version: $MACOS_VERSION"
elif [ "$SYS_OS" = "Linux" ];
then
export SYSTEMOS="Linux"
fi
########## RHL and Linux Distribution Detection #############
# More accurate Linux distribution detection using /etc/os-release
#################################################################
if [ "$SYSTEMOS" = "Linux" ];
then
if [ -f /etc/os-release ];
then
# Extract the distribution name and version from /etc/os-release
export DISTRO_NAME=$(grep -w "NAME" /etc/os-release | cut -d'=' -f2 | tr -d '"')
export DISTRO_VERSION=$(grep -w "VERSION_ID" /etc/os-release | cut -d'=' -f2 | tr -d '"')
# Print the distribution name and version
echo "Operating system detected: $DISTRO_NAME, Version: $DISTRO_VERSION"
# Check if dnf or yum is installed (dnf is used on newer systems, yum on older ones)
if command -v dnf >/dev/null 2>&1;
then echo "dnf is installed."
export SYSTEMOS="RHL"  # Set SYSTEMOS to RHL if dnf is detected
elif command -v yum >/dev/null 2>&1;
then echo "yum is installed."
export SYSTEMOS="RHL"  # Set SYSTEMOS to RHL if yum is detected
else
echo "No package manager (dnf or yum) found."
fi
else
echo "Unable to detect the Linux distribution version."
fi
fi
# Print the final detected OS
echo "Final operating system detected: $SYSTEMOS"
############################### Intel or GNU Compiler Option #############
# Only proceed with RHL-specific logic if the system is RHL
if [ "$SYSTEMOS" = "RHL" ];
then
# Check for 32-bit RHL system
if [ "$SYSTEMBIT" = "32" ];
then
echo "Your system is not compatible with this script."
exit
fi
# Check for 64-bit RHL system
if [ "$SYSTEMBIT" = "64" ];
then
echo "Your system is a 64-bit version of RHL Based Linux Kernel."
echo "Intel compilers are not compatible with this script."
echo "Setting compiler to GNU."
export RHL_64bit_GNU=1
echo "RHL_64bit_GNU=$RHL_64bit_GNU"
# Check for the version of the GNU compiler (gcc)
export gcc_test_version=$(gcc -dumpversion 2>&1 | awk '{print $1}')
export gcc_test_version_major=$(echo $gcc_test_version | awk -F. '{print $1}')
export gcc_version_9="9"
if [[ $gcc_test_version_major -lt $gcc_version_9 ]];
then export RHL_64bit_GNU=2
echo "OLD GNU FILES FOUND."
echo "RHL_64bit_GNU=$RHL_64bit_GNU"
fi
fi
fi
# Check for 64-bit Linux system (Debian/Ubuntu)
if [ "$SYSTEMBIT" = "64" ] && [ "$SYSTEMOS" = "Linux" ];
then
echo "Your system is a 64-bit version of Debian Linux Kernel."
echo ""
# Check if Ubuntu_64bit_Intel or Ubuntu_64bit_GNU environment variables are set
if [ -n "$Ubuntu_64bit_Intel" ] || [ -n "$Ubuntu_64bit_GNU" ];
then echo "The environment variable Ubuntu_64bit_Intel/GNU is already set."
else echo "The environment variable Ubuntu_64bit_Intel/GNU is not set."
# Prompt user to select a compiler (Intel or GNU)
while read -r -p "Which compiler do you want to use?
- Intel
-- Please note that WRF_CMAQ is only compatible with GNU Compilers
- GNU
Please answer Intel or GNU and press enter (case-sensitive): "
yn;
do
case $yn in Intel)
echo "Intel is selected for installation."
export Ubuntu_64bit_Intel=1
break
;;
GNU)
echo "GNU is selected for installation."
export Ubuntu_64bit_GNU=1
break
;;
*)
echo "Please answer Intel or GNU (case-sensitive)."
;;
esac
done
fi
fi
# Check for 32-bit Linux system
if [ "$SYSTEMBIT" = "32" ] && [ "$SYSTEMOS" = "Linux" ];
then
echo "Your system is not compatible with this script."
exit
fi
############################# macOS Handling ##############################
# Check for 32-bit MacOS system
if [ "$SYSTEMBIT" = "32" ] && [ "$SYSTEMOS" = "MacOS" ];
then
echo "Your system is not compatible with this script."
exit
fi
# Check for 64-bit Intel-based MacOS system
if [ "$SYSTEMBIT" = "64" ] && [ "$SYSTEMOS" = "MacOS" ] && [ "$MAC_CHIP" = "Intel" ];
then
echo "Your system is a 64-bit version of macOS with an Intel chip."
echo "Intel compilers are not compatible with this script."
echo "Setting compiler to GNU."
export macos_64bit_GNU=1
# Ensure Xcode Command Line Tools are installed
if ! xcode-select --print-path &>/dev/null;
then
echo "Installing Xcode Command Line Tools..."
xcode-select --install
fi
# Install Homebrew for Intel Macs in /usr/local
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/usr/local/bin/brew shellenv)"' >>~/.profile
eval "$(/usr/local/bin/brew shellenv)"
chsh -s /bin/bash
fi
# Check for 64-bit ARM-based MacOS system (M1, M2 chips)
if [ "$SYSTEMBIT" = "64" ] && [ "$SYSTEMOS" = "MacOS" ] && [ "$MAC_CHIP" = "ARM" ];
then
echo "Your system is a 64-bit version of macOS with an ARM chip (M1/M2)."
echo "Intel compilers are not compatible with this script."
echo "Setting compiler to GNU."
export macos_64bit_GNU=1
# Ensure Xcode Command Line Tools are installed
if ! xcode-select --print-path &>/dev/null;
then
echo "Installing Xcode Command Line Tools..."
xcode-select --install
fi
# Install Homebrew for ARM Macs in /opt/homebrew
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.profile
eval "$(/opt/homebrew/bin/brew shellenv)"
chsh -s /bin/bash
fi
################### System Information Tests ##############################
echo "-------------------------------------------------- "
echo "Testing for Storage Space for installation."
export HOME=$(
cd
pwd
)
export Storage_Space_Required="10"
# Function to determine available storage space
get_available_storage()
{
case "$(uname -s)" in
Linux*)
df -h --output=avail ${HOME} | awk 'NR==2'
;;
Darwin*)
df -h ${HOME} | awk 'NR==2 {print $4}'
;;
*)
echo "Unsupported OS"
exit 1
;;
esac
}
# Get available storage space and units
Storage_Space_Avail=$(get_available_storage)
Storage_Space_Size=$(echo ${Storage_Space_Avail} | tr -cd '[:digit:]')
Storage_Space_Units=$(echo ${Storage_Space_Avail} | tr -cd '[:alpha:]')
# Check if there is enough space for installation
case $Storage_Space_Units in
[Pp]* | [Tt]*)
echo "Sufficient storage space for installation found."
echo "-------------------------------------------------- "
;;
[Gg]*)
if [[ ${Storage_Space_Size} -lt ${Storage_Space_Required} ]];
then
echo "Not enough storage space for installation. 350GB is required."
echo "-------------------------------------------------- "
exit 1
else
echo "Sufficient storage space for installation found."
echo "-------------------------------------------------- "
fi
;;
[MmKk]*)
echo "Not enough storage space for installation. 350GB is required."
echo "-------------------------------------------------- "
exit 1
;;
*)
echo "Not enough storage space for installation. 350GB is required."
echo "Storage Space Available: $Storage_Space_Size $Storage_Space_Units"
echo "-------------------------------------------------- "
exit
;;
esac
