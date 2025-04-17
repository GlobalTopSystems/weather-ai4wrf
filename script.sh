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
export METPLUS_Version=5.1.0
export met_Version_number=11.1.1
export met_VERSION_number=11.1
export METPLUS_DATA=5.1
export Zlib_Version=1.3.1
export Mpich_Version=4.2.3
export Libpng_Version=1.6.39
export Jasper_Version=1.900.1
export HDF5_Version=1.14.4
export HDF5_Sub_Version=3
export Pnetcdf_Version=1.13.0
export Netcdf_C_Version=4.9.2
export Netcdf_Fortran_Version=4.6.1
export WRF_VERSION=4.6.1
export WPS_VERSION=4.6.0
############################### Citation Requirement  ####################
echo " "
echo " The Global Top Systems Company at GitHub site for Weather-AI software (Version 2.0.2.5) by B. Vasiliu (2025)"
echo " "
echo " It is important to note that any usage or publication that incorporates or references this software must include a proper citation to acknowledge the work of the author."
echo " "
echo -e " This is not only a matter of respect and academic integrity, but also a \e[31mrequirement\e[0m set by the author."
echo " "
echo " Please ensure to adhere to this guideline when using this software."
echo " "
echo " Citation: Vasiliu, B., Global Top Systems Company [GTS]."
echo " "
echo -e " \e[31mWeather-AI:\e[0m HyperConvergent Meteorological Infrastructure Appliances \e[31m[HCMIA]\e[0m, modular and cross-platform toolkit"
echo -e " for configuring and installing OpenSource Weather Software \e[31m[Computer software]\e[0m."
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
############################# Enter sudo users information #############################
echo "-------------------------------------------------- "
while true; do
	# Prompt for the initial password
	read -r -s -p "
    Password is only saved locally and will not be seen when typing.
    Please enter your sudo password: " password1
	echo " "
	# Prompt for password verification
	read -r -s -p "Please re-enter your password to verify: " password2
	echo " "

	# Check if the passwords match
	if [ "$password1" = "$password2" ];
	then
	export PASSWD=$password1
	echo "Password verified successfully."
	break
	else
	echo "Passwords do not match. Please enter the passwords again."
	fi
done
echo "Beginning Installation"
############################# Chose GrADS or OpenGrADS #########################
while read -r -p "Which graphic display software should be install?
-OpenGrADS
-GrADS (Not available for MacOS)
Please answer with either OpenGrADS or GrADS and press enter.
    " yn; do

	case $yn in
	OpenGrADS)

		echo " "
		echo "OpenGrADS selected for installation"
		echo "-------------------------------------------------- "
		export GRADS_PICK=1 #variable set for grads or opengrads choice
		break
		;;
	GrADS)
		echo " "
		echo "GrADS selected for installation"
		echo "-------------------------------------------------- "
		export GRADS_PICK=2 #variable set for grads or opengrads choice
		break
		;;
	*)
		echo " "
		echo "Please answer OpenGrADS or GrADS (case sensative)."
		;;

	esac
done

echo " "
##################################### Auto Configuration Test ##################
while true; do
	echo " Auto Configuration Check"
	read -r -p "
    Would you like the script to select all the configure options for you?
    Please note, that you should not have to type anything else in the terminal.
    
    This will use Basic Nesting for WRF Configuration
    
    (Y/N)    " yn
	case $yn in
	[Yy]*)
		export auto_config=1 #variable set for one click config and installation
		break
		;;
	[Nn]*)
		export auto_config=0 #variable set for manual config and installation
		break
		;;
	*) echo "Please answer yes or no." ;;
	esac
done

echo " "

################################# DTC MET Tools Test ##################
while true; do
	echo " NCAR's DTC MET Tools Install"
	read -r -p "
    Would you like the script to install the NCAR's DTC Model Evaluation Tools?
    ***DTC MET Tools are not available for Intel Compilers at this time***
    
    (Y/N)    " yn
	case $yn in
	[Yy]*)
		export DTC_MET=1
		break
		;;
	[Nn]*)
		export DTC_MET=0
		break
		;;
	*) echo "Please answer yes or no." ;;
	esac
done

echo " "

################################# GEOG WPS Geographical Input Data Mandatory for Specific Applications ##################
while true; do
	echo "-------------------------------------------------- "
	echo " "
	echo "Would you like to download the WPS Geographical Input Data for Specific Applications? (Optional)"
	echo " "
	echo "Specific Applications files can be viewed here:  "
	echo " "
	printf '\e]8;;https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html\e\\Specific GEOG Applications Website (right click to open link) \e]8;;\e\\\n'
	echo " "
	read -r -p "(Y/N)   " yn
	case $yn in
	[Yy]*)
		export WPS_Specific_Applications=1 #variable set for "YES" for specific application data
		break
		;;
	[Nn]*)
		export WPS_Specific_Applications=0 #variable set for "NO" for specific application data
		break
		;;
	*) echo "Please answer yes or no." ;;
	esac
done

echo " "

################################# GEOG Optional WPS Geographical Input Data ##################
while true; do
	echo "-------------------------------------------------- "
	echo " "
	echo "Would you like to download the GEOG Optional WPS Geographical Input Data? (Optional)"
	echo " "
	echo "Optional Geographical files can be viewed here:  "
	echo " "
	printf '\e]8;;https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html\e\\Optional GEOG File Applications Website (right click to open link) \e]8;;\e\\\n'
	echo " "
	read -r -p "(Y/N)    " yn
	echo " "
	case $yn in
	[Yy]*)
		export Optional_GEOG=1 #variable set for "YES" for Optional GEOG Data
		break
		;;
	[Nn]*)
		export Optional_GEOG=0 #variable set for "NO" for Optional GEOG Data
		break
		;;
	*) echo "Please answer yes or no." ;;
	esac
done

echo " "

############################## Choice for which version of WRF to Install ############
# Define the colored messages
CMAQ_MESSAGE="\e[91m(Not available on MacOS && GNU Only)\e[0m"

echo -e "Which version of WRF would you like to install?
-WRF
-WRFCHEM
-WRFHYDRO_COUPLED
-WRFHYDRO_STANDALONE
-WRF_SFIRE
-WRF_CMAQ $CMAQ_MESSAGE

Please enter one of the above options and press enter (Case Sensitive):"

while read -r yn; do
	case $yn in
	WRF_SFIRE)
		echo " "
		echo "WRF_SFIRE selected for installation"
		export SFIRE_PICK=1 #variable set for grads or opengrads choice
		break
		;;
	WRF_CMAQ)
		echo " "
		echo "WRF_CMAQ selected for installation"
		echo "WRF_CMAQ is only compatible with GNU Compilers"
		export CMAQ_PICK=1 #variable set for grads or opengrads choice
		break
		;;
	WRF)
		echo " "
		echo "WRF selected for installation"
		export WRF_PICK=1 #variable set for grads or opengrads choice
		break
		;;
	WRFCHEM)
		echo " "
		echo "WRFCHEM selected for installation"
		export WRFCHEM_PICK=1 #variable set for grads or opengrads choice
		break
		;;
	WRFHYDRO_COUPLED)
		echo " "
		echo "WRFHYDRO_COUPLED selected for installation"
		export WRFHYDRO_COUPLED_PICK=1 #variable set for grads or opengrads choice
		break
		;;
	WRFHYDRO_STANDALONE)
		echo " "
		echo "WRFHYDRO_STANDALONE selected for installation"
		export WRFHYDRO_STANDALONE_PICK=1 #variable set for grads or opengrads choice
		break
		;;
	*)
		echo " "
		echo "Please answer WRF, WRFCHEM, WRFHYDRO_COUPLED, WRFHYDRO_STANDALONE, WRF_SFIRE, WRF_CMAQ, or HURRICANE_WRF (All Upper Case)."
		;;
	esac
done

################################# WRF-CHEM Tools Test ##################
if [ "$WRFCHEM_PICK" = "1" ]; then
	while true; do
		echo " NCAR's WRF-CHEM Tools Install"
		read -r -p "
        Would you like the script to install the NCAR's WRF-CHEM Tools?
        
        Not available for MacOS.  Please Select No
        
        (Y/N)    " yn
		case $yn in
		[Yy]*)
			export WRFCHEM_TOOLS=1
			break
			;;
		[Nn]*)
			export WRFCHEM_TOOLS=0
			break
			;;
		*) echo "Please answer yes or no." ;;
		esac
	done
fi
echo " "


if [ "$Ubuntu_64bit_GNU" = "1" ] && [ "$DTC_MET" = "1" ]; then

	echo $PASSWD | sudo -S sudo apt install git
	echo "MET INSTALLING"
	export HOME=$(
		cd
		pwd
	)
	#Basic Package Management for Model Evaluation Tools (MET)

	#############################basic package managment############################
	echo $PASSWD | sudo -S apt -y update
	echo $PASSWD | sudo -S apt -y upgrade

	release_version=$(lsb_release -r -s)

	# Compare the release version
	if [ "$release_version" = "24.04" ]; then
		# Install Emacs without recommended packages
		echo $PASSWD | sudo -S apt install emacs --no-install-recommends -y
	else
		# Attempt to install Emacs if the release version is not 24.04
		echo "The release version is not 24.04, attempting to install Emacs."
		echo $PASSWD | sudo -S apt install emacs -y
	fi

	echo $PASSWD | sudo -S apt -y install autoconf automake autotools-dev bison build-essential byacc cmake csh curl default-jdk default-jre flex libfl-dev g++ gawk gcc gfortran git ksh libcurl4-openssl-dev libjpeg-dev libncurses6 libpixman-1-dev libpng-dev libtool libxml2 libxml2-dev libxml-libxml-perl m4 make ncview okular openbox pipenv pkg-config python3 python3-dev python3-pip python3-dateutil tcsh unzip xauth xorg time

	#Downloading latest dateutil due to python3.8 running old version.
	echo $PASSWD | sudo -S apt -y install python3-dateutil

	#Directory Listings
	if [ "$WRFCHEM_PICK" = "1" ];
	then
	mkdir $HOME/WRFCHEM
	export WRF_FOLDER=$HOME/WRFCHEM
	fi
	if [ "$WRFHYDRO_COUPLED_PICK" = "1" ];
	then
	mkdir $HOME/WRFHYDRO_COUPLED
	export WRF_FOLDER=$HOME/WRFHYDRO_COUPLED
	fi
	if [ "$WRFHYDRO_STANDALONE_PICK" = "1" ];
	then
	mkdir $HOME/WRFHYDRO_STANDALONE
	export WRF_FOLDER=$HOME/WRFHYDRO_STANDALONE
	fi
	if [ "$WRF_PICK" = "1" ];
	then
	mkdir $HOME/WRF
	export WRF_FOLDER=$HOME/WRF
	fi
	if [ "$CMAQ_PICK" = "1" ];
	then
	mkdir $HOME/WRF_CMAQ
	export WRF_FOLDER=$HOME/WRF_CMAQ
	fi
	if [ "$SFIRE_PICK" = "1" ];
	then
	mkdir $HOME/WRF_SFIRE_Intel
	export WRF_FOLDER=$HOME/WRF_SFIRE
	fi
	mkdir "${WRF_FOLDER}"/MET-$met_Version_number
	mkdir "${WRF_FOLDER}"/MET-$met_Version_number/Downloads
	mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version
	mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
	#Downloading MET and untarring files
	#Note weblinks change often update as needed.
	cd "${WRF_FOLDER}"/MET-$met_Version_number/Downloads
	wget -c https://raw.githubusercontent.com/dtcenter/MET/main_v$met_VERSION_number/internal/scripts/installation/compile_MET_all.sh
	wget -c https://dtcenter.ucar.edu/dfiles/code/METplus/MET/installation/tar_files.met-v$met_VERSION_number.tgz
	wget -c https://github.com/dtcenter/MET/archive/refs/tags/v$met_Version_number.tar.gz
	cp compile_MET_all.sh "${WRF_FOLDER}"/MET-$met_Version_number
	tar -xvzf tar_files.met-v$met_VERSION_number.tgz -C "${WRF_FOLDER}"/MET-$met_Version_number
	cp v$met_Version_number.tar.gz "${WRF_FOLDER}"/MET-$met_Version_number/tar_files
	cd "${WRF_FOLDER}"/MET-$met_Version_number
	# Installation of Model Evaluation Tools
	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -O3"
	cd "${WRF_FOLDER}"/MET-$met_Version_number
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	export PYTHON_VERSION=$(/usr/bin/python3 -V 2>&1 | awk '{print $2}')
	export PYTHON_VERSION_MAJOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $1}')
	export PYTHON_VERSION_MINOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $2}')
	export PYTHON_VERSION_COMBINED=$PYTHON_VERSION_MAJOR_VERSION.$PYTHON_VERSION_MINOR_VERSION
	export FC=/usr/bin/gfortran
	export F77=/usr/bin/gfortran
	export F90=/usr/bin/gfortran
	export gcc_version=$(gcc -dumpfullversion)
	export TEST_BASE="${WRF_FOLDER}"/MET-$met_Version_number
	export COMPILER=gnu_$gcc_version
	export MET_SUBDIR=${TEST_BASE}
	export MET_TARBALL=v$met_Version_number.tar.gz
	export USE_MODULES=FALSE
	export MET_PYTHON=/usr
	export MET_PYTHON_CC="-I${MET_PYTHON}/include/python${PYTHON_VERSION_COMBINED}"
	export MET_PYTHON_LD="$(python3-config --ldflags) -L${MET_PYTHON}/lib -lpython${PYTHON_VERSION_COMBINED}"
	export SET_D64BIT=FALSE
	echo "CC=$CC"
	echo "CXX=$CXX"
	echo "FC=$FC"
	echo "F77=$F77"
	echo "F90=$F90"
	echo "gcc_version=$gcc_version"
	echo "TEST_BASE=$TEST_BASE"
	echo "COMPILER=$COMPILER"
	echo "MET_SUBDIR=$MET_SUBDIR"
	echo "MET_TARBALL=$MET_TARBALL"
	echo "USE_MODULES=$USE_MODULES"
	echo "MET_PYTHON=$MET_PYTHON"
	echo "MET_PYTHON_CC=$MET_PYTHON_CC"
	echo "MET_PYTHON_LD=$MET_PYTHON_LD"
	echo "SET_D64BIT=$SET_D64BIT"
	export MAKE_ARGS="-j 4"
	chmod 775 compile_MET_all.sh
	time ./compile_MET_all.sh 2>&1 | tee compile_MET_all.log
	export PATH="${WRF_FOLDER}"/MET-$met_Version_number/bin:$PATH
	#basic Package Management for Model Evaluation Tools (METplus)
	echo $PASSWD | sudo -S apt -y update
	echo $PASSWD | sudo -S apt -y upgrade
	#Directory Listings for Model Evaluation Tools (METplus
	mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version
	mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Sample_Data
	mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Output
	mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
	#Downloading METplus and untarring files
	cd "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
	wget -c https://github.com/dtcenter/METplus/archive/refs/tags/v$METPLUS_Version.tar.gz
	tar -xvzf v$METPLUS_Version.tar.gz -C "${WRF_FOLDER}"
	# Installlation of Model Evaluation Tools Plus
	cd "${WRF_FOLDER}"/METplus-$METPLUS_Version/parm/metplus_config
	sed -i "s|MET_INSTALL_DIR = /path/to|MET_INSTALL_DIR = "${WRF_FOLDER}"/MET-$met_Version_number|" defaults.conf
	sed -i "s|INPUT_BASE = /path/to|INPUT_BASE = "${WRF_FOLDER}"/METplus-$METPLUS_Version/Sample_Data|" defaults.conf
	sed -i "s|OUTPUT_BASE = /path/to|OUTPUT_BASE = "${WRF_FOLDER}"/METplus-$METPLUS_Version/Output|" defaults.conf
	# Downloading Sample Data
	cd "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
	wget -c https://dtcenter.ucar.edu/dfiles/code/METplus/METplus_Data/v$METPLUS_DATA/sample_data-met_tool_wrapper-$METPLUS_DATA.tgz
	tar -xvzf sample_data-met_tool_wrapper-$METPLUS_DATA.tgz -C "${WRF_FOLDER}"/METplus-$METPLUS_Version/Sample_Data
	# Testing if installation of MET & METPlus was sucessfull
	# If you see in terminal "METplus has successfully finished running."
	# Then MET & METPLUS is sucessfully installed
	echo 'Testing MET & METPLUS Installation.'
	$WRF_FOLDER/METplus-$METPLUS_Version/ush/run_metplus.py -c $WRF_FOLDER/METplus-$METPLUS_Version/parm/use_cases/met_tool_wrapper/GridStat/GridStat.conf
	# Check if the previous command was successful
	if [ $? -eq 0 ];
	then
	echo " "
	echo "MET and METPLUS successfully installed with GNU compilers."
	echo " "
	export PATH=$WRF_FOLDER/METplus-$METPLUS_Version/ush:$PATH
	else
	echo " "
	echo "Error: MET and METPLUS installation failed."
	echo " "
	# Handle the error case, e.g., exit the script or retry installation
	exit 1
	fi
fi

if [ "$RHL_64bit_GNU" = "1" ] && [ "$DTC_MET" = "1" ];
then
export HOME=$(
cd
pwd
)
echo $PASSWD | sudo -S sudo dnf install git
#Basic Package Management for Model Evaluation Tools (MET)
echo $PASSWD | sudo -S yum install epel-release -y
echo $PASSWD | sudo -S yum install dnf -y
echo $PASSWD | sudo -S dnf install epel-release -y
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig-devel fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk ksh libX11-devel libX11-devel libXaw libXaw-devel libXext-devel libXext-devel libXmu-devel libXrender-devel libXrender-devel libstdc++ libstdc++-devel libxml2 libxml2-devel m4 nfs-utils perl "perl(XML::LibXML)" pkgconfig pixman-devel python3 python3-devel tcsh time unzip wget
echo $PASSWD | sudo -S dnf -y install python3-dateutil
echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo " "
#Directory Listings
if [ "$WRFCHEM_PICK" = "1" ];
then
mkdir $HOME/WRFCHEM
export WRF_FOLDER=$HOME/WRFCHEM
fi
if [ "$WRFHYDRO_COUPLED_PICK" = "1" ];
then
mkdir $HOME/WRFHYDRO_COUPLED
export WRF_FOLDER=$HOME/WRFHYDRO_COUPLED
fi
if [ "$WRFHYDRO_STANDALONE_PICK" = "1" ];
then
mkdir $HOME/WRFHYDRO_STANDALONE
export WRF_FOLDER=$HOME/WRFHYDRO_STANDALONE
fi
if [ "$WRF_PICK" = "1" ];
then
mkdir $HOME/WRF
export WRF_FOLDER=$HOME/WRF
fi
if [ "$CMAQ_PICK" = "1" ];
then
mkdir $HOME/WRF_CMAQ
export WRF_FOLDER=$HOME/WRF_CMAQ
fi
if [ "$SFIRE_PICK" = "1" ];
then
mkdir $HOME/WRF_SFIRE_Intel
export WRF_FOLDER=$HOME/WRF_SFIRE
fi
mkdir "${WRF_FOLDER}"/MET-$met_Version_number
mkdir "${WRF_FOLDER}"/MET-$met_Version_number/Downloads
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
#Downloading MET and untarring files
#Note weblinks change often update as needed.
cd "${WRF_FOLDER}"/MET-$met_Version_number/Downloads
wget -c https://raw.githubusercontent.com/dtcenter/MET/main_v$met_VERSION_number/internal/scripts/installation/compile_MET_all.sh
wget -c https://dtcenter.ucar.edu/dfiles/code/METplus/MET/installation/tar_files.met-v$met_VERSION_number.tgz
wget -c https://github.com/dtcenter/MET/archive/refs/tags/v$met_Version_number.tar.gz
cp compile_MET_all.sh "${WRF_FOLDER}"/MET-$met_Version_number
tar -xvzf tar_files.met-v$met_VERSION_number.tgz -C "${WRF_FOLDER}"/MET-$met_Version_number
cp v$met_Version_number.tar.gz "${WRF_FOLDER}"/MET-$met_Version_number/tar_files
cd "${WRF_FOLDER}"/MET-$met_Version_number
# Installation of Model Evaluation Tools
cd "${WRF_FOLDER}"/MET-$met_Version_number
export PYTHON_VERSION=$(/usr/bin/python3 -V 2>&1 | awk '{print $2}')
export PYTHON_VERSION_MAJOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $1}')
export PYTHON_VERSION_MINOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $2}')
export PYTHON_VERSION_COMBINED=$PYTHON_VERSION_MAJOR_VERSION.$PYTHON_VERSION_MINOR_VERSION
export CC=gcc
export CXX=g++
export CFLAGS="-fPIC -fPIE -O3"
export FC=gfortran
export F77=gfortran
export F90=gfortran
export gcc_version=$(gcc -dumpfullversion)
export TEST_BASE="${WRF_FOLDER}"/MET-$met_Version_number
export COMPILER=gnu_$gcc_version
export MET_SUBDIR=${TEST_BASE}
export MET_TARBALL=v$met_Version_number.tar.gz
export USE_MODULES=FALSE
export MET_PYTHON=/usr
export MET_PYTHON_CC="-I${MET_PYTHON}/include/python${PYTHON_VERSION_COMBINED}"
export MET_PYTHON_LD="$(python3-config --ldflags) -L${MET_PYTHON}/lib -lpython${PYTHON_VERSION_COMBINED}"
export SET_D64BIT=FALSE
echo "CC=$CC"
echo "CXX=$CXX"
echo "FC=$FC"
echo "F77=$F77"
echo "F90=$F90"
echo "gcc_version=$gcc_version"
echo "TEST_BASE=$TEST_BASE"
echo "COMPILER=$COMPILER"
echo "MET_SUBDIR=$MET_SUBDIR"
echo "MET_TARBALL=$MET_TARBALL"
echo "USE_MODULES=$USE_MODULES"
echo "MET_PYTHON=$MET_PYTHON"
echo "MET_PYTHON_CC=$MET_PYTHON_CC"
echo "MET_PYTHON_LD=$MET_PYTHON_LD"
echo "SET_D64BIT=$SET_D64BIT"
export MAKE_ARGS="-j 4"
chmod 775 compile_MET_all.sh
time ./compile_MET_all.sh 2>&1 | tee compile_MET_all.log
export PATH="${WRF_FOLDER}"/MET-$met_Version_number/bin:$PATH
#basic Package Management for Model Evaluation Tools (METplus)
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
#Directory Listings for Model Evaluation Tools (METplus
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Sample_Data
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Output
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
#Downloading METplus and untarring files
cd "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
wget -c https://github.com/dtcenter/METplus/archive/refs/tags/v$METPLUS_Version.tar.gz
tar -xvzf v$METPLUS_Version.tar.gz -C "${WRF_FOLDER}"
# Insatlllation of Model Evaluation Tools Plus
cd "${WRF_FOLDER}"/METplus-$METPLUS_Version/parm/metplus_config
sed -i "s|MET_INSTALL_DIR = /path/to|MET_INSTALL_DIR = "${WRF_FOLDER}"/MET-$met_Version_number|" defaults.conf
sed -i "s|INPUT_BASE = /path/to|INPUT_BASE = "${WRF_FOLDER}"/METplus-$METPLUS_Version/Sample_Data|" defaults.conf
sed -i "s|OUTPUT_BASE = /path/to|OUTPUT_BASE = "${WRF_FOLDER}"/METplus-$METPLUS_Version/Output|" defaults.conf
# Downloading Sample Data
cd "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
wget -c https://dtcenter.ucar.edu/dfiles/code/METplus/METplus_Data/v$METPLUS_DATA/sample_data-met_tool_wrapper-$METPLUS_DATA.tgz
tar -xvzf sample_data-met_tool_wrapper-$METPLUS_DATA.tgz -C "${WRF_FOLDER}"/METplus-$METPLUS_Version/Sample_Data
# Testing if installation of MET & METPlus was sucessfull
# If you see in terminal "METplus has successfully finished running."
# Then MET & METPLUS is sucessfully installed
echo 'Testing MET & METPLUS Installation.'
$WRF_FOLDER/METplus-$METPLUS_Version/ush/run_metplus.py -c $WRF_FOLDER/METplus-$METPLUS_Version/parm/use_cases/met_tool_wrapper/GridStat/GridStat.conf
# Check if the previous command was successful
if [ $? -eq 0 ];
then
echo " "
echo "MET and METPLUS successfully installed with GNU compilers."
echo " "
export PATH=$WRF_FOLDER/METplus-$METPLUS_Version/ush:$PATH
else
echo " "
echo "Error: MET and METPLUS installation failed."
echo " "
# Handle the error case, e.g., exit the script or retry installation
exit 1
fi
fi
if [ "$RHL_64bit_GNU" = "2" ] && [ "$DTC_MET" = "1" ];
then
echo $PASSWD | sudo -S sudo dnf install git
echo "MET INSTALLING"
export HOME=$(
cd
pwd
)
#Basic Package Management for Model Evaluation Tools (MET)
echo $PASSWD | sudo -S yum install epel-release -y
echo $PASSWD | sudo -S yum install dnf -y
echo $PASSWD | sudo -S dnf install epel-release -y
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig-devel fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk ksh libX11-devel libX11-devel libXaw libXaw-devel libXext-devel libXext-devel libXmu-devel libXrender-devel libXrender-devel libstdc++ libstdc++-devel libxml2 libxml2-devel m4 nfs-utils perl "perl(XML::LibXML)" pkgconfig pixman-devel python3 python3-devel tcsh time unzip wget
echo $PASSWD | sudo -S dnf -y install python3-dateutil --break-system-packages
echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo " "
echo "old version of GNU detected"
echo $PASSWD | sudo -S yum install RHL-release-scl -y
echo $PASSWD | sudo -S yum clean all
echo $PASSWD | sudo -S yum remove devtoolset-11*
echo $PASSWD | sudo -S yum install devtoolset-11
echo $PASSWD | sudo -S yum install devtoolset-11-\* -y
source /opt/rh/devtoolset-11/enable
gcc --version
echo $PASSWD | sudo -S yum install rh-python38* -y
source /opt/rh/rh-python38/enable
python3 -V
echo $PASSWD | sudo echo $PASSWD | sudo -S ./opt/rh/rh-python38/root/bin/pip3.8 install python-dateutil --break-system-packages
#Directory Listings
if [ "$WRFCHEM_PICK" = "1" ];
then
mkdir $HOME/WRFCHEM
export WRF_FOLDER=$HOME/WRFCHEM
fi

if [ "$WRFHYDRO_COUPLED_PICK" = "1" ];
then
mkdir $HOME/WRFHYDRO_COUPLED
export WRF_FOLDER=$HOME/WRFHYDRO_COUPLED
fi
if [ "$WRFHYDRO_STANDALONE_PICK" = "1" ];
then
mkdir $HOME/WRFHYDRO_STANDALONE
export WRF_FOLDER=$HOME/WRFHYDRO_STANDALONE
fi
if [ "$WRF_PICK" = "1" ];
then
mkdir $HOME/WRF
export WRF_FOLDER=$HOME/WRF
fi
if [ "$CMAQ_PICK" = "1" ];
then
mkdir $HOME/WRF_CMAQ
export WRF_FOLDER=$HOME/WRF_CMAQ
fi
if [ "$SFIRE_PICK" = "1" ];
then
mkdir $HOME/WRF_SFIRE_Intel
export WRF_FOLDER=$HOME/WRF_SFIRE
fi
mkdir "${WRF_FOLDER}"/MET-$met_Version_number
mkdir "${WRF_FOLDER}"/MET-$met_Version_number/Downloads
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
#Downloading MET and untarring files
#Note weblinks change often update as needed.
cd "${WRF_FOLDER}"/MET-$met_Version_number/Downloads
wget -c https://raw.githubusercontent.com/dtcenter/MET/main_v$met_VERSION_number/internal/scripts/installation/compile_MET_all.sh
wget -c https://dtcenter.ucar.edu/dfiles/code/METplus/MET/installation/tar_files.met-v$met_VERSION_number.tgz
wget -c https://github.com/dtcenter/MET/archive/refs/tags/v$met_Version_number.tar.gz
cp compile_MET_all.sh "${WRF_FOLDER}"/MET-$met_Version_number
tar -xvzf tar_files.met-v$met_VERSION_number.tgz -C "${WRF_FOLDER}"/MET-$met_Version_number
cp v$met_Version_number.tar.gz "${WRF_FOLDER}"/MET-$met_Version_number/tar_files
cd "${WRF_FOLDER}"/MET-$met_Version_number
# Installation of Model Evaluation Tools
cd "${WRF_FOLDER}"/MET-$met_Version_number
export PYTHON_VERSION=$(/opt/rh/rh-python38/root/usr/bin/python3 -V 2>&1 | awk '{print $2}')
export PYTHON_VERSION_MAJOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $1}')
export PYTHON_VERSION_MINOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $2}')
export PYTHON_VERSION_COMBINED=$PYTHON_VERSION_MAJOR_VERSION.$PYTHON_VERSION_MINOR_VERSION
export CC=gcc
export CXX=g++
export CFLAGS="-fPIC -fPIE -O3"
export FC=gfortran
export F77=gfortran
export F90=gfortran
export gcc_version=$(gcc -dumpfullversion)
export TEST_BASE="${WRF_FOLDER}"/MET-$met_Version_number
export COMPILER=gnu_$gcc_version
export MET_SUBDIR=${TEST_BASE}
export MET_TARBALL=v$met_Version_number.tar.gz
export USE_MODULES=FALSE
export MET_PYTHON=/opt/rh/rh-python38/root/usr/
export MET_PYTHON_CC="-I${MET_PYTHON}/include/python${PYTHON_VERSION_COMBINED}"
export MET_PYTHON_LD="$(python3-config --ldflags) -L${MET_PYTHON}/lib -lpython${PYTHON_VERSION_COMBINED}"
export SET_D64BIT=FALSE
echo "CC=$CC"
echo "CXX=$CXX"
echo "FC=$FC"
echo "F77=$F77"
echo "F90=$F90"
echo "gcc_version=$gcc_version"
echo "TEST_BASE=$TEST_BASE"
echo "COMPILER=$COMPILER"
echo "MET_SUBDIR=$MET_SUBDIR"
echo "MET_TARBALL=$MET_TARBALL"
echo "USE_MODULES=$USE_MODULES"
echo "MET_PYTHON=$MET_PYTHON"
echo "MET_PYTHON_CC=$MET_PYTHON_CC"
echo "MET_PYTHON_LD=$MET_PYTHON_LD"
echo "SET_D64BIT=$SET_D64BIT"
export MAKE_ARGS="-j 4"
chmod 775 compile_MET_all.sh
time ./compile_MET_all.sh 2>&1 | tee compile_MET_all.log
export PATH="${WRF_FOLDER}"/MET-$met_Version_number/bin:$PATH
#basic Package Management for Model Evaluation Tools (METplus)
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
#Directory Listings for Model Evaluation Tools (METplus
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Sample_Data
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Output
mkdir "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
#Downloading METplus and untarring files
cd "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
wget -c https://github.com/dtcenter/METplus/archive/refs/tags/v$METPLUS_Version.tar.gz
tar -xvzf v$METPLUS_Version.tar.gz -C "${WRF_FOLDER}"
# Insatlllation of Model Evaluation Tools Plus
cd "${WRF_FOLDER}"/METplus-$METPLUS_Version/parm/metplus_config
sed -i "s|MET_INSTALL_DIR = /path/to|MET_INSTALL_DIR = "${WRF_FOLDER}"/MET-$met_Version_number|" defaults.conf
sed -i "s|INPUT_BASE = /path/to|INPUT_BASE = "${WRF_FOLDER}"/METplus-$METPLUS_Version/Sample_Data|" defaults.conf
sed -i "s|OUTPUT_BASE = /path/to|OUTPUT_BASE = "${WRF_FOLDER}"/METplus-$METPLUS_Version/Output|" defaults.conf
# Downloading Sample Data
cd "${WRF_FOLDER}"/METplus-$METPLUS_Version/Downloads
wget -c https://dtcenter.ucar.edu/dfiles/code/METplus/METplus_Data/v$METPLUS_DATA/sample_data-met_tool_wrapper-$METPLUS_DATA.tgz
tar -xvzf sample_data-met_tool_wrapper-$METPLUS_DATA.tgz -C "${WRF_FOLDER}"/METplus-$METPLUS_Version/Sample_Data
# Testing if installation of MET & METPlus was sucessfull
# If you see in terminal "METplus has successfully finished running."
# Then MET & METPLUS is sucessfully installed
echo 'Testing MET & METPLUS Installation.'
$WRF_FOLDER/METplus-$METPLUS_Version/ush/run_metplus.py -c $WRF_FOLDER/METplus-$METPLUS_Version/parm/use_cases/met_tool_wrapper/GridStat/GridStat.conf
# Check if the previous command was successful
if [ $? -eq 0 ];
then
echo " "
echo "MET and METPLUS successfully installed with GNU compilers."
echo " "
export PATH=$WRF_FOLDER/METplus-$METPLUS_Version/ush:$PATH
else
echo " "
echo "Error: MET and METPLUS installation failed."
echo " "
# Handle the error case, e.g., exit the script or retry installation
exit 1
fi
fi
if [ "$Ubuntu_64bit_GNU" = "1" ] && [ "$CMAQ_PICK" = "1" ];
then
#############################basic package managment############################
echo $PASSWD | sudo -S apt -y update
echo $PASSWD | sudo -S apt -y upgrade
release_version=$(lsb_release -r -s)
# Compare the release version
if [ "$release_version" = "24.04" ];
then
# Install Emacs without recommended packages
echo $PASSWD | sudo -S apt install emacs --no-install-recommends -y
else
# Attempt to install Emacs if the release version is not 24.04
echo "The release version is not 24.04, attempting to install Emacs."
echo $PASSWD | sudo -S apt install emacs -y
fi
echo $PASSWD | sudo -S apt -y install autoconf automake autotools-dev bison build-essential byacc cmake csh curl default-jdk default-jre flex libfl-dev g++ gawk gcc gfortran git ksh libcurl4-openssl-dev libjpeg-dev libncurses6 libpixman-1-dev libpng-dev libtool libxml2 libxml2-dev libxml-libxml-perl m4 make ncview okular openbox pipenv pkg-config python3 python3-dev python3-pip python3-dateutil tcsh unzip xauth xorg time

echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRF_CMAQ
export WRF_FOLDER=$HOME/WRF_CMAQ
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
echo " "
#############################Core Management####################################
export CPU_CORE=$(nproc) # number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))     #quarter of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) #Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
then
#If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system.
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
cd Downloads
wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
wget -c https://www.cmascenter.org/ioapi/download/ioapi-3.2.tar.gz
echo " "
####################################Compilers#####################################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -O3 "
#IF statement for GNU compiler issue
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
#Uncalling compilers due to comfigure issue with zlib$Zlib_Version
#With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
#make check
echo " "
##############################MPICH############################
#F90= due to compiler issues with mpich install
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
# make check
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
#make check
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
#make check
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
#make check
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
#############################Install Parallel-netCDF##############################
#Make file created with half of available cpu cores
#Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
#make check
export PNETCDF=$DIR/grib2
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
#make check
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
#make check
echo " "
###############################  I/O API  ###################################
cd "${WRF_FOLDER}"/Downloads
mkdir ioapi
cd ioapi
tar -xzvf "${WRF_FOLDER}"/Downloads/ioapi-3.2.tar.gz
#set gnu version
export BIN=Linux2_x86_64gfort10
export CPLMODE=nocpl
mkdir $BIN
#Link netcdf and grib lib folders to ioapi
ln -sf "${WRF_FOLDER}"/Libs/NETCDF/lib/* "${WRF_FOLDER}"/Downloads/ioapi/$BIN
ln -sf "${WRF_FOLDER}"/Libs/grib2/lib/* "${WRF_FOLDER}"/Downloads/ioapi/$BIN
#copy makefiles from ioapi directory to source makefile
#cp "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makefile.nocpl "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makefile
#cp "${WRF_FOLDER}"/Downloads/ioapi/m3tools/Makefile.nocpl "${WRF_FOLDER}"/Downloads/ioapi/m3tools/Makefile
cp "${WRF_FOLDER}"/Downloads/ioapi/Makefile.template "${WRF_FOLDER}"/Downloads/ioapi/Makefile
# Add proper sed statements needed for gfortran
sed -i '193s|-lnetcdff -lnetcdf| -lnetcdff -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -ljpeg -lm -lz -lcurl|g' "${WRF_FOLDER}"/Downloads/ioapi/Makefile
sed -i '210s|${IODIR}/Makefile ${TOOLDIR}/Makefile| |g' "${WRF_FOLDER}"/Downloads/ioapi/Makefile
#Remove openmnp flags from Makefile
sed -i '30s/ -fopenmp//g' "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makeinclude.$BIN
sed -i '31s/ -fopenmp//g' "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makeinclude.$BIN
# Build IOAPI
make configure 2>&1 | tee configure.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
#If statement to check that libioapi.a & m3xtract exist
cd "${WRF_FOLDER}"/Downloads/ioapi/$BIN
n=$(ls -lrt libioapi.a | wc -l)
m=$(ls -rlt m3xtract | wc -l)
if ((($n == 1) && ($m == 1)));
then
echo "All expected files created."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
echo " "
mv "${WRF_FOLDER}"/Downloads/ioapi/$BIN "${WRF_FOLDER}"/Downloads/ioapi/Linux2_x86_64gfort
export BIN=Linux2_x86_64gfort
#################################### System Environment Tests ##############
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
#exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
############################ CMAQ Source Code #################################
cd "${WRF_FOLDER}"/Downloads
git clone -b main https://github.com/USEPA/CMAQ.git #clone CMAQ github to WRF_CMAQ Main Folder
cd CMAQ
cp bldit_project.csh bldit_project.csh.old # Create backup of build project script
# Set path to where CMAQ will be built
sed -i '19s|/home/username/path|"${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4|g' "${WRF_FOLDER}"/Downloads/CMAQ/bldit_project.csh
# Build CMAQ Project
./bldit_project.csh
cd "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4
cp config_cmaq.csh config_cmaq.csh.old # Create backup of configure script
# Sed statements to configure the Build_WRFv${WRF_VERSION}-CMAQv5.4
sed -i '146s|netcdf_root_gcc|"${WRF_FOLDER}"/Libs/NETCDF|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '147s|ioapi_root_gcc|"${WRF_FOLDER}"/Downloads/ioapi|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '148s|WRF_ARCH|WRF_ARCH 34|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
# sed statements for paths in configure file
sed -i '151s|ioapi_inc_gcc|"${WRF_FOLDER}"/Downloads/ioapi/ioapi/fixed_src|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '152s|ioapi_lib_gcc|"${WRF_FOLDER}"/Downloads/ioapi/$BIN|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '153s|netcdf_lib_gcc |"${WRF_FOLDER}"/Libs/NETCDF/lib|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '154s|netcdf_inc_gcc|"${WRF_FOLDER}"/Libs/NETCDF/include|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '155s|netcdff_lib_gcc|"${WRF_FOLDER}"/Libs/NETCDF/lib|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '156s|netcdff_inc_gcc|"${WRF_FOLDER}"/Libs/NETCDF/include|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '157s|mpi_incl_gcc|"${WRF_FOLDER}"/Libs/MPICH|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '158s|mpi_lib_gcc|"${WRF_FOLDER}"/Libs/MPICH|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
# compile the Chemistry Transport Model (CCTM) preprocess
cd "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts
cp bldit_cctm.csh bldit_cctm.csh.old # make a back up copy of .csh script
# Sed statements for configuration
sed -i '74s|-j|-j $CPU_QUARTER_EVEN|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh # set multicore to half of available cpus
sed -i '84s|#set|set|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh                # build two way
sed -i '103s|v4.4|v${WRF_VERSION}|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh   # change wrf version from 4.4 to ${WPS_VERSION}
sed -i '446s| if ( $? != 0 ) then| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '447s|    set shaID   = "not_a_repo"| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '448s| endif| |g' "${WRF_FOLDER}"/Downloads/CMAQ//Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '791s|  if ($? == 0) then| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '793s|  endif| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '822s|compile em_real|compile -j $CPU_QUARTER_EVEN em_real|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
# Build WRF-CMAQ
./bldit_cctm.csh gcc 2>&1 | tee bldit.cctm.twoway.gcc.log
# Move built folder to top level directory
mv "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/BLD_WRFv${WRF_VERSION}_CCTM_v54_gcc "${WRF_FOLDER}"/WRFv${WRF_VERSION}_CMAQv5.4
export WRF_DIR="${WRF_FOLDER}"/WRFv${WRF_VERSION}_CMAQv5.4
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WRFv${WRF_VERSION}_CMAQv5.4/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
############################WPS#####################################
## WPS v${WPS_VERSION}
## Downloaded from git tagged releases
#Option 3 for gfortran and distributed memory
########################################################################
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
./clean -a
if [ ${auto_config} -eq 1 ];
then
echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
else
./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
fi
./compile 2>&1 | tee compile.wps.log
echo " "
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd "${WRF_FOLDER}"/Downloads
mkdir "${WRF_FOLDER}"/GEOG
mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
echo " "
echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
if [ ${WPS_Specific_Applications} -eq 1 ];
then
echo " "
echo " WPS Geographical Input Data Mandatory for Specific Applications"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
tar -xvf gsl_gwd.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
if [ ${Optional_GEOG} -eq 1 ];
then
echo " "
echo "Optional WPS Geographical Input Data"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
fi
if [ "$RHL_64bit_GNU" = "1" ] && [ "$CMAQ_PICK" = "1" ];
then
#############################basic package managment############################
echo $PASSWD | sudo -S yum install epel-release -y
echo $PASSWD | sudo -S yum install dnf -y
echo $PASSWD | sudo -S dnf install epel-release -y
echo $PASSWD | sudo -S dnf install dnf -y
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk ksh libjpeg libjpeg-devel libX11 libX11-devel libXaw libXaw-devel libXext-devel libXmu libXmu-devel libXrender libXrender-devel libXt libXt-devel libxml2 libxml2-devel libXmu libXmu-devel libgeotiff libgeotiff-devel libtiff libtiff-devel m4 nfs-utils perl pkgconfig pixman pixman-devel python3 python3-devel tcsh time unzip wget
echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRF_CMAQ
export WRF_FOLDER=$HOME/WRF_CMAQ
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
echo " "
#############################Core Management####################################
export CPU_CORE=$(nproc)
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4)) 
# quarter of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) 
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
then
# If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system.
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
cd Downloads
wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
wget -c https://www.cmascenter.org/ioapi/download/ioapi-3.2.tar.gz
echo " "
####################################Compilers#####################################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -O3"
#IF statement for GNU compiler issue
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "CFLAGS = $CFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib$Zlib_Version
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
make -j $CPU_QUARTER_EVEN check
echo " "
##############################MPICH############################
# F90= due to compiler issues with mpich install
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
# make check
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
#############################Install Parallel-netCDF##############################
#Make file created with half of available cpu cores
#Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=mpifort
export MPIF77=mpifort
export MPIF90=mpifort
export MPICC=mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
echo " "
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
echo $CFLAGS
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
echo $CFLAGS
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
###############################  I/O API  ###################################
cd "${WRF_FOLDER}"/Downloads
mkdir ioapi
cd ioapi
tar -xzvf "${WRF_FOLDER}"/Downloads/ioapi-3.2.tar.gz
#set gnu version
export BIN=Linux2_x86_64gfort10
export CPLMODE=nocpl
mkdir $BIN
#Link netcdf and grib lib folders to ioapi
ln -sf "${WRF_FOLDER}"/Libs/NETCDF/lib/* "${WRF_FOLDER}"/Downloads/ioapi/$BIN
ln -sf "${WRF_FOLDER}"/Libs/grib2/lib/* "${WRF_FOLDER}"/Downloads/ioapi/$BIN
#copy makefiles from ioapi directory to source makefile
#cp "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makefile.nocpl "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makefile
#cp "${WRF_FOLDER}"/Downloads/ioapi/m3tools/Makefile.nocpl "${WRF_FOLDER}"/Downloads/ioapi/m3tools/Makefile
cp "${WRF_FOLDER}"/Downloads/ioapi/Makefile.template "${WRF_FOLDER}"/Downloads/ioapi/Makefile
# Add proper sed statements needed for gfortran
sed -i '193s|-lnetcdff -lnetcdf| -lnetcdff -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -ljpeg -lm -lz -lcurl|g' "${WRF_FOLDER}"/Downloads/ioapi/Makefile
sed -i '210s|${IODIR}/Makefile ${TOOLDIR}/Makefile| |g' "${WRF_FOLDER}"/Downloads/ioapi/Makefile
#Remove openmnp flags from Makefile
sed -i '30s/ -fopenmp//g' "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makeinclude.$BIN
sed -i '31s/ -fopenmp//g' "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makeinclude.$BIN
# Build IOAPI
make configure 2>&1 | tee configure.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
#If statement to check that libioapi.a & m3xtract exist
cd "${WRF_FOLDER}"/Downloads/ioapi/$BIN
n=$(ls -lrt libioapi.a | wc -l)
m=$(ls -rlt m3xtract | wc -l)
if ((($n == 1) && ($m == 1)));
then
echo "All expected files created."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
echo " "
mv "${WRF_FOLDER}"/Downloads/ioapi/$BIN "${WRF_FOLDER}"/Downloads/ioapi/Linux2_x86_64gfort
export BIN=Linux2_x86_64gfort
#################################### System Environment Tests ##############
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
############################ CMAQ Source Code #################################
cd "${WRF_FOLDER}"/Downloads
git clone -b main https://github.com/USEPA/CMAQ.git #clone CMAQ github to WRF_CMAQ Main Folder
cd CMAQ
cp bldit_project.csh bldit_project.csh.old # Create backup of build project script
# Set path to where CMAQ will be built
sed -i '19s|/home/username/path|"${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4|g' "${WRF_FOLDER}"/Downloads/CMAQ/bldit_project.csh
# Build CMAQ Project
./bldit_project.csh
cd "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4
cp config_cmaq.csh config_cmaq.csh.old # Create backup of configure script
# Sed statements to configure the Build_WRFv${WRF_VERSION}-CMAQv5.4
sed -i '146s|netcdf_root_gcc|"${WRF_FOLDER}"/Libs/NETCDF|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '147s|ioapi_root_gcc|"${WRF_FOLDER}"/Downloads/ioapi|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '148s|WRF_ARCH|WRF_ARCH 34|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
# sed statements for paths in configure file
sed -i '151s|ioapi_inc_gcc|"${WRF_FOLDER}"/Downloads/ioapi/ioapi/fixed_src|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '152s|ioapi_lib_gcc|"${WRF_FOLDER}"/Downloads/ioapi/$BIN|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '153s|netcdf_lib_gcc |"${WRF_FOLDER}"/Libs/NETCDF/lib|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '154s|netcdf_inc_gcc|"${WRF_FOLDER}"/Libs/NETCDF/include|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '155s|netcdff_lib_gcc|"${WRF_FOLDER}"/Libs/NETCDF/lib|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '156s|netcdff_inc_gcc|"${WRF_FOLDER}"/Libs/NETCDF/include|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '157s|mpi_incl_gcc|"${WRF_FOLDER}"/Libs/MPICH|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '158s|mpi_lib_gcc|"${WRF_FOLDER}"/Libs/MPICH|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
# compile the Chemistry Transport Model (CCTM) preprocess
cd "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts
cp bldit_cctm.csh bldit_cctm.csh.old # make a back up copy of .csh script
# Sed statements for configuration
sed -i '74s|-j|-j $CPU_QUARTER_EVEN|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh 
# set multicore to half of available cpus
sed -i '84s|#set|set|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh  
# build two way
sed -i '103s|v4.4|v${WRF_VERSION}|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh 
# change wrf version from 4.4 to ${WPS_VERSION}
sed -i '446s| if ( $? != 0 ) then| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '447s|    set shaID   = "not_a_repo"| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '448s| endif| |g' "${WRF_FOLDER}"/Downloads/CMAQ//Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '791s|  if ($? == 0) then| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '793s|  endif| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '822s|compile em_real|compile -j $CPU_QUARTER_EVEN em_real|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
# Build WRF-CMAQ
./bldit_cctm.csh gcc 2>&1 | tee bldit.cctm.twoway.gcc.log
# Move built folder to top level directory
mv "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/BLD_WRFv${WRF_VERSION}_CCTM_v54_gcc "${WRF_FOLDER}"/WRFv${WRF_VERSION}_CMAQv5.4
export WRF_DIR="${WRF_FOLDER}"/WRFv${WRF_VERSION}_CMAQv5.4
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WRFv${WRF_VERSION}_CMAQv5.4/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
############################WPS#####################################
## WPS v${WPS_VERSION}
## Downloaded from git tagged releases
#Option 3 for gfortran and distributed memory
########################################################################
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
./clean -a
if [ ${auto_config} -eq 1 ];
then
echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
else
./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
fi
./compile 2>&1 | tee compile.wps.log
echo " "
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd "${WRF_FOLDER}"/Downloads
mkdir "${WRF_FOLDER}"/GEOG
mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
echo " "
echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
if [ ${WPS_Specific_Applications} -eq 1 ];
then
echo " "
echo " WPS Geographical Input Data Mandatory for Specific Applications"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
tar -xvf gsl_gwd.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
if [ ${Optional_GEOG} -eq 1 ];
then
echo " "
echo "Optional WPS Geographical Input Data"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
fi
if [ "$RHL_64bit_GNU" = "2" ] && [ "$CMAQ_PICK" = "1" ];
then
#############################basic package managment############################
echo "old version of GNU detected"
echo $PASSWD | sudo -S yum install epel-release -y
echo $PASSWD | sudo -S yum install RHL-release-scl -y
echo $PASSWD | sudo -S yum clean all
echo $PASSWD | sudo -S yum remove devtoolset-11*
echo $PASSWD | sudo -S yum install devtoolset-11
echo $PASSWD | sudo -S yum install devtoolset-11-\* -y
echo $PASSWD | sudo -S yum -y update
echo $PASSWD | sudo -S yum -y upgrade
source /opt/rh/devtoolset-11/enable
gcc --version
echo $PASSWD | sudo -S yum install epel-release -y
echo $PASSWD | sudo -S yum install dnf -y
echo $PASSWD | sudo -S dnf install epel-release -y
echo $PASSWD | sudo -S dnf install dnf -y
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk ksh libjpeg libjpeg-devel libX11 libX11-devel libXaw libXaw-devel libXext-devel libXmu libXmu-devel libXrender libXrender-devel libXt libXt-devel libxml2 libxml2-devel libXmu libXmu-devel libgeotiff libgeotiff-devel libtiff libtiff-devel m4 nfs-utils perl pkgconfig pixman pixman-devel python3 python3-devel tcsh time unzip wget
echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
source /opt/rh/devtoolset-11/enable
echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRF_CMAQ
export WRF_FOLDER=$HOME/WRF_CMAQ
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
echo " "
#############################Core Management####################################
export CPU_CORE=$(nproc) 
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))                          
# quarter of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) 
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
then
#If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system.
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
cd Downloads
wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
wget -c https://www.cmascenter.org/ioapi/download/ioapi-3.2.tar.gz
echo " "
####################################Compilers#####################################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -O3"
#IF statement for GNU compiler issue
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "CFLAGS = $CFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
#Uncalling compilers due to comfigure issue with zlib$Zlib_Version
#With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
# F90= due to compiler issues with mpich install
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
#############################Install Parallel-netCDF##############################
#Make file created with half of available cpu cores
#Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=mpifort
export MPIF77=mpifort
export MPIF90=mpifort
export MPICC=mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
echo " "
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
echo $CFLAGS
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
echo $CFLAGS
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
###############################  I/O API  ###################################
cd "${WRF_FOLDER}"/Downloads
mkdir ioapi
cd ioapi
tar -xzvf "${WRF_FOLDER}"/Downloads/ioapi-3.2.tar.gz
#set gnu version
export BIN=Linux2_x86_64gfort10
export CPLMODE=nocpl
mkdir $BIN
#Link netcdf and grib lib folders to ioapi
ln -sf "${WRF_FOLDER}"/Libs/NETCDF/lib/* "${WRF_FOLDER}"/Downloads/ioapi/$BIN
ln -sf "${WRF_FOLDER}"/Libs/grib2/lib/* "${WRF_FOLDER}"/Downloads/ioapi/$BIN
#copy makefiles from ioapi directory to source makefile
#cp "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makefile.nocpl "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makefile
#cp "${WRF_FOLDER}"/Downloads/ioapi/m3tools/Makefile.nocpl "${WRF_FOLDER}"/Downloads/ioapi/m3tools/Makefile
cp "${WRF_FOLDER}"/Downloads/ioapi/Makefile.template "${WRF_FOLDER}"/Downloads/ioapi/Makefile
# Add proper sed statements needed for gfortran
sed -i '193s|-lnetcdff -lnetcdf| -lnetcdff -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -ljpeg -lm -lz -lcurl|g' "${WRF_FOLDER}"/Downloads/ioapi/Makefile
sed -i '210s|${IODIR}/Makefile ${TOOLDIR}/Makefile| |g' "${WRF_FOLDER}"/Downloads/ioapi/Makefile
#Remove openmnp flags from Makefile
sed -i '30s/ -fopenmp//g' "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makeinclude.$BIN
sed -i '31s/ -fopenmp//g' "${WRF_FOLDER}"/Downloads/ioapi/ioapi/Makeinclude.$BIN
# Build IOAPI
make configure 2>&1 | tee configure.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
#If statement to check that libioapi.a & m3xtract exist
cd "${WRF_FOLDER}"/Downloads/ioapi/$BIN
n=$(ls -lrt libioapi.a | wc -l)
m=$(ls -rlt m3xtract | wc -l)
if ((($n == 1) && ($m == 1)));
then
echo "All expected files created."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
echo " "
mv "${WRF_FOLDER}"/Downloads/ioapi/$BIN "${WRF_FOLDER}"/Downloads/ioapi/Linux2_x86_64gfort
export BIN=Linux2_x86_64gfort
#################################### System Environment Tests ##############
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
############################ CMAQ Source Code #################################
cd "${WRF_FOLDER}"/Downloads
git clone -b main https://github.com/USEPA/CMAQ.git #clone CMAQ github to WRF_CMAQ Main Folder
cd CMAQ
cp bldit_project.csh bldit_project.csh.old # Create backup of build project script
# Set path to where CMAQ will be built
sed -i '19s|/home/username/path|"${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4|g' "${WRF_FOLDER}"/Downloads/CMAQ/bldit_project.csh
# Build CMAQ Project
./bldit_project.csh
cd "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4
cp config_cmaq.csh config_cmaq.csh.old # Create backup of configure script
# Sed statements to configure the Build_WRFv${WRF_VERSION}-CMAQv5.4
sed -i '146s|netcdf_root_gcc|"${WRF_FOLDER}"/Libs/NETCDF|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '147s|ioapi_root_gcc|"${WRF_FOLDER}"/Downloads/ioapi|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '148s|WRF_ARCH|WRF_ARCH 34|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
# sed statements for paths in configure file
sed -i '151s|ioapi_inc_gcc|"${WRF_FOLDER}"/Downloads/ioapi/ioapi/fixed_src|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '152s|ioapi_lib_gcc|"${WRF_FOLDER}"/Downloads/ioapi/$BIN|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '153s|netcdf_lib_gcc |"${WRF_FOLDER}"/Libs/NETCDF/lib|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '154s|netcdf_inc_gcc|"${WRF_FOLDER}"/Libs/NETCDF/include|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '155s|netcdff_lib_gcc|"${WRF_FOLDER}"/Libs/NETCDF/lib|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '156s|netcdff_inc_gcc|"${WRF_FOLDER}"/Libs/NETCDF/include|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '157s|mpi_incl_gcc|"${WRF_FOLDER}"/Libs/MPICH|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
sed -i '158s|mpi_lib_gcc|"${WRF_FOLDER}"/Libs/MPICH|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/config_cmaq.csh
# compile the Chemistry Transport Model (CCTM) preprocess
cd "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts
cp bldit_cctm.csh bldit_cctm.csh.old # make a back up copy of .csh script
# Sed statements for configuration
sed -i '74s|-j|-j $CPU_QUARTER_EVEN|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
# set multicore to half of available cpus
sed -i '84s|#set|set|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh               
# build two way
sed -i '103s|v4.4|v${WRF_VERSION}|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh  
# change wrf version from 4.4 to ${WPS_VERSION}
sed -i '446s| if ( $? != 0 ) then| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '447s|    set shaID   = "not_a_repo"| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '448s| endif| |g' "${WRF_FOLDER}"/Downloads/CMAQ//Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '791s|  if ($? == 0) then| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '793s|  endif| |g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
sed -i '822s|compile em_real|compile -j $CPU_QUARTER_EVEN em_real|g' "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/bldit_cctm.csh
# Build WRF-CMAQ
./bldit_cctm.csh gcc 2>&1 | tee bldit.cctm.twoway.gcc.log
# Move built folder to top level directory
mv "${WRF_FOLDER}"/Downloads/CMAQ/Build_WRFv${WRF_VERSION}-CMAQv5.4/CCTM/scripts/BLD_WRFv${WRF_VERSION}_CCTM_v54_gcc "${WRF_FOLDER}"/WRFv${WRF_VERSION}_CMAQv5.4
export WRF_DIR="${WRF_FOLDER}"/WRFv${WRF_VERSION}_CMAQv5.4
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WRFv${WRF_VERSION}_CMAQv5.4/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
############################WPS#####################################
## WPS v${WPS_VERSION}
## Downloaded from git tagged releases
#Option 3 for gfortran and distributed memory
########################################################################
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
./clean -a
if [ ${auto_config} -eq 1 ];
then
echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
else
./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
fi
./compile 2>&1 | tee compile.wps.log
echo " "
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd "${WRF_FOLDER}"/Downloads
mkdir "${WRF_FOLDER}"/GEOG
mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
echo " "
echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
if [ ${WPS_Specific_Applications} -eq 1 ]
then
echo " "
echo " WPS Geographical Input Data Mandatory for Specific Applications"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
tar -xvf gsl_gwd.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
if [ ${Optional_GEOG} -eq 1 ];
then
echo " "
echo "Optional WPS Geographical Input Data"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
fi
############################################# WRF SFIRE #################################
## WRF_SFIRE installation with parallel process.
# Download and install required library and data files for WRF_SFIRE.
# Tested in Ubuntu 20.0${WPS_VERSION} LTS & Ubuntu 22.04, Rocky Linux 9 & MacOS Ventura 64bit
# Built in 64-bit system
# Built with Intel or GNU compilers
# Tested with current available libraries on 10/10/2023
# If newer libraries exist edit script paths for changes
# Estimated Run Time ~ 30 - 60 Minutes with 10mb/s downloadspeed.
# Special thanks to:
# Youtube's meteoadriatic, GitHub user jamal919.
# University of Manchester's  Doug L
# University of Tunis El Manar's Hosni
# GSL's Jordan S.
# NCAR's Mary B., Christine W., & Carl D.
# DTC's Julie P., Tara J., George M., & John H.
# UCAR's Katelyn F., Jim B., Jordan P., Kevin M.,
# University of Colorado Denver's Jan M.
##############################################################
if [ "$Ubuntu_64bit_GNU" = "1" ] && [ "$SFIRE_PICK" = "1" ];
then
#############################basic package managment############################
echo $PASSWD | sudo -S apt -y update
echo $PASSWD | sudo -S apt -y upgrade
echo $PASSWD | sudo -S apt -y install autoconf automake bison build-essential byacc cmake csh curl default-jdk default-jre emacs --no-install-recommendsflex libfl-dev g++ gawk gcc gfortran git ksh libcurl4-openssl-dev libjpeg-dev libncurses6 libpixman-1-dev libpng-dev libtool libxml2 libxml2-dev m4 make ncview okular openbox pipenv pkg-config python3 python3-dev python3-pip python3-dateutil tcsh unzip xauth xorg time libgeotiff-dev
echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRF_SFIRE
export WRF_FOLDER=$HOME/WRF_SFIRE
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
echo " "
#############################Core Management####################################
export CPU_CORE=$(nproc) 
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))                          
# quarter of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) 
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
then
# If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system.
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
# Force use of ipv4 with -4
cd Downloads
wget -c -4 https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c -4 https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c -4 https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c -4 https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c -4 https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c -4 https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
wget -c -4 https://github.com/openwfm/convert_geotiff/releases/download/v0.1/convert_geotiff-0.1.0.tar.gz
echo " "
####################################Compilers#####################################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -O3"
# IF statement for GNU compiler issue
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib$Zlib_Version
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
# F90= due to compiler issues with mpich install
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
############################# Convert Geo Tiff #################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf convert_geotiff-0.1.0.tar.gz
cd convert_geotiff-0.1.0
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure -exec-prefix=$DIR/grib2 --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
#################################### System Environment Tests ##############
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c -4 https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
###############################NCEPlibs#####################################
# The libraries are built and installed with
# ./make_ncep_libs.sh -s MACHINE -c COMPILER -d NCEPLIBS_DIR -o OPENMP [-m mpi] [-a APPLICATION]
# It is recommended to install the NCEPlibs into their own directory, which must be created before running the installer.
# Further information on the command line arguments can be obtained with ./make_ncep_libs.sh -h
# If iand error occurs go to https://github.com/NCAR/NCEPlibs/pull/16/files make adjustment and re-run ./make_ncep_libs.sh
############################################################################
cd "${WRF_FOLDER}"/Downloads
git clone https://github.com/NCAR/NCEPlibs.git
cd NCEPlibs
mkdir $DIR/nceplibs
export JASPER_INC=$DIR/grib2/include
export PNG_INC=$DIR/grib2/include
export NETCDF=$DIR/NETCDF
# for loop to edit linux.gnu for nceplibs to install
# make if statement for gcc-9 or older
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i "24s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "28s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "32s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "36s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "40s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "45s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "49s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "53s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "56s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "60s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "64s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "68s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "69s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "73s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "74s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "79s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
fi
if [ ${auto_config} -eq 1 ];
then
echo yes | ./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp
else
./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp
fi
export PATH=$DIR/nceplibs:$PATH
echo " "
######################## ARWpost V3.1  ############################
## ARWpost
## Configure #3
###################################################################
cd "${WRF_FOLDER}"/Downloads
wget -c -4 http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"/
cd "${WRF_FOLDER}"/ARWpost
./clean -a
sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
export NETCDF=$DIR/NETCDF
if [ ${auto_config} -eq 1 ];
then
echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
else
./configure #Option 3 gfortran compiler with distributed memory
fi
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i '32s/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4 ${fallow_argument} /g' configure.arwp
fi
sed -i -e 's/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
./compile
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/ARWpost
n=$(ls ./*.exe | wc -l)
if (($n == 1));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH
echo " "
################################ OpenGrADS ##################################
#Verison 2.2.1 32bit of Linux
#############################################################################
if [[ $GRADS_PICK -eq 1 ]];
then
cd "${WRF_FOLDER}"/Downloads
tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
cd "${WRF_FOLDER}"/
mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
cd GrADS/Contents
wget -c -4 https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
chmod +x g2ctl.pl
wget -c -4 https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
tar -xzvf wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
cd wgrib2-v0.1.9.4/bin
mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
cd "${WRF_FOLDER}"/GrADS/Contents
rm wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
rm -r wgrib2-v0.1.9.4
export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH
echo " "
fi
################################## GrADS ###############################
# Version  2.2.1
# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
########################################################################
if [[ $GRADS_PICK -eq 2 ]];
then
echo $PASSWD | sudo -S apt -y install grads
fi
##################### NCAR COMMAND LANGUAGE           ##################
########### NCL compiled via Conda                    ##################
########### This is the preferred method by NCAR      ##################
########### https://www.ncl.ucar.edu/index.shtml      ##################
# Installing Miniconda3 to WRF-Hydro directory and updating libraries
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
wget -c -4 https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
echo " "
echo " "
#Installing NCL via Conda
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create -n ncl_stable -c conda-forge ncl -y
conda activate ncl_stable
conda deactivate
conda deactivate
conda deactivate
echo " "
############################## RIP4 #####################################
mkdir "${WRF_FOLDER}"/RIP4
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/RIP_47.tar.gz
tar -xvzf RIP_47.tar.gz -C "${WRF_FOLDER}"/RIP4
cd "${WRF_FOLDER}"/RIP4/RIP_47
mv * ..
cd "${WRF_FOLDER}"/RIP4
rm -rd RIP_47
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda activate ncl_stable
conda install -c conda-forge ncl c-compiler fortran-compiler cxx-compiler -y
export RIP_ROOT="${WRF_FOLDER}"/RIP4
export NETCDF=$DIR/NETCDF
export NCARG_ROOT="${WRF_FOLDER}"/miniconda3/envs/ncl_stable
sed -i '349s|-L${NETCDF}/lib -lnetcdf $NETCDFF|-L${NETCDF}/lib $NETCDFF -lnetcdff -lnetcdf -lnetcdf -lnetcdff_C -lhdf5 |g' "${WRF_FOLDER}"/RIP4/configure
sed -i '27s|NETCDFLIB	= -L${NETCDF}/lib -lnetcdf CONFIGURE_NETCDFF_LIB|NETCDFLIB	= -L</usr/lib/x86_64-linux-gnu/libm.a> -lm -L${NETCDF}/lib CONFIGURE_NETCDFF_LIB -lnetcdf -lhdf5 -lhdf5_hl -lgfortran -lgcc -lz |g' "${WRF_FOLDER}"/RIP4/arch/preamble
sed -i '31s|-L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz CONFIGURE_NCARG_LIB| -L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz -lcairo -lfontconfig -lpixman-1 -lfreetype -lexpat -lpthread -lbz2 -lXrender -lgfortran -lgcc -L</usr/lib/x86_64-linux-gnu/> -lm -lhdf5 -lhdf5_hl |g' "${WRF_FOLDER}"/RIP4/arch/preamble
sed -i '33s| -O|-fallow-argument-mismatch -O |g' "${WRF_FOLDER}"/RIP4/arch/configure.defaults
sed -i '35s|=|= -L"${WRF_FOLDER}"/LIBS/grib2/lib -lhdf5 -lhdf5_hl |g' "${WRF_FOLDER}"/RIP4/arch/configure.defaults
if [ ${auto_config} -eq 1 ];
then
echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
else
./configure #Option 3 gfortran compiler with distributed memory
fi
./compile
conda deactivate
conda deactivate
conda deactivate
echo " "
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
######################### Climate Data Operators ############
######################### CDO compiled via Conda ###########
####################### This is the preferred method #######
################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create --name cdo_stable -y
conda activate cdo_stable
conda install -c conda-forge cdo -y
conda update --all -y
conda deactivate
conda deactivate
conda deactivate
echo " "
################################## QGIS #####################################
# QGIS (Quantum Geographic Information System) is a free and open-source platform that allows users to
# analyze, view, and edit geospatial data. It supports both vector and raster layers, as well as various
# web services, and is extensible through community-developed plugins. Key features include map
#creation, spatial analysis, and data management.
#############################################################################
conda env create -f $HOME/weather-ai/qgis.3.28.8.yml
echo " "
############################ WRF-SFIRE  #################################
## WRF-SFIRE
# Cloned from openwfm
# option 34, option 1 for gfortran and distributed memory w/basic nesting
# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WRF-SFIRE.git
cd "${WRF_FOLDER}"/WRF-SFIRE/
./clean -a # Clean old configuration files
if [ ${auto_config} -eq 1 ];
then
sed -i '428s/.*/  $response = "34 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl 
# Answer for compiler choice
sed -i '869s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl  
#Answer for basic nesting
./configure 2>&1 | tee configure.log
else
./configure 2>&1 | tee configure.log #Option 34 gfortran compiler with distributed memory option 1 for basic nesting
fi
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
cd "${WRF_FOLDER}"/WRF-SFIRE/
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
cd "${WRF_FOLDER}"/WRF-SFIRE
./compile -j $CPU_QUARTER_EVEN em_fire 2>&1 | tee compile.wrfsfire.log
export WRF_DIR="${WRF_FOLDER}"/WRF-SFIRE
############################WPSV4.2#####################################
## WPS v4.2
## Downloaded from git tagged releases
# Cloned from openwfm
# Option 3 for gfortran and distributed memory
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WPS.git
cd "${WRF_FOLDER}"/WPS
./clean -a
cd "${WRF_FOLDER}"/WPS
if [ ${auto_config} -eq 1 ];
then
FFLAGS=$FFLAGS echo 3 | ./configure 2>&1 | tee configure.log
# Option 3 for gfortran and distributed memory
else
FFLAGS=$FFLAGS ./configure 2>&1 | tee configure.log
# Option 3 gfortran compiler with distributed memory
fi
# sed statements for issue with GNUv10+
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i '70s/-frecord-marker=4/-frecord-marker=4 -m64 -fallow-argument-mismatch/g' "${WRF_FOLDER}"/WPS/configure.wps
sed -i '71s/-frecord-marker=4/-frecord-marker=4 -m64 -fallow-argument-mismatch/g' "${WRF_FOLDER}"/WPS/configure.wps
fi
./compile 2>&1 | tee compile.wps.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
./compile 2>&1 | tee compile.wps2.log
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd "${WRF_FOLDER}"/Downloads
mkdir "${WRF_FOLDER}"/GEOG
mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
echo " "
echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
if [ ${WPS_Specific_Applications} -eq 1 ];
then
echo " "
echo " WPS Geographical Input Data Mandatory for Specific Applications"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
tar -xvf gsl_gwd.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
fi
if [ ${Optional_GEOG} -eq 1 ];
then
echo " "
echo "Optional WPS Geographical Input Data"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
#fi
if [ "$Ubuntu_64bit_Intel" = "1" ] && [ "$SFIRE_PICK" = "1" ];
then
echo $PASSWD | sudo -S apt -y update
echo $PASSWD | sudo -S apt -y upgrade
# download the key to system keyring; this and the following echo command are
# needed in order to install the Intel compilers
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg >/dev/null
# add signed entry to apt sources and configure the APT client to use Intel repository:
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
# this update should get the Intel package info from the Intel repository
echo $PASSWD | sudo -S apt -y update
echo $PASSWD | sudo -S apt -y install autoconf automake bison build-essential byacc cmake csh curl default-jdk default-jre emacs --no-install-recommendsflex libfl-dev g++ gawk gcc gfortran git ksh libcurl4-openssl-dev libjpeg-dev libncurses6 libpixman-1-dev libpng-dev libtool libxml2 libxml2-dev m4 make ncview okular openbox pipenv pkg-config python3 python3-dev python3-pip python3-dateutil tcsh unzip xauth xorg time libgeotiff-dev
# install the Intel compilers
echo $PASSWD | sudo -S apt -y install intel-basekit
echo $PASSWD | sudo -S apt -y install intel-hpckit
echo $PASSWD | sudo -S apt -y install intel-oneapi-python
echo $PASSWD | sudo -S apt -y update
#Fix any broken installations
echo $PASSWD | sudo -S apt --fix-broken install
# make sure some critical packages have been installed
which cmake pkg-config make gcc g++ gfortran
# add the Intel compiler file paths to various environment variables
source /opt/intel/oneapi/setvars.sh --force
# some of the libraries we install below need one or more of these variables
export CC=icx
export CXX=icpx
export FC=ifx
export F77=ifx
export F90=ifx
export MPIFC=mpiifx
export MPIF77=mpiifx
export MPIF90=mpiifx
export MPICC=mpiicx
export MPICXX=mpiicpc
export CFLAGS="-fPIC -fPIE -O3 -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types -Wno-unused-command-line-argument"
export FFLAGS="-m64"
export FCFLAGS="-m64"
############################# CPU Core Management ####################################
export CPU_CORE=$(nproc) 
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4)) 
# quarter of availble cores on system
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
# If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system.
if [ $CPU_CORE -le $CPU_6CORE ];
then
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
############################## Directory Listing ############################
# makes necessary directories
#
############################################################################
export HOME=$(
cd
pwd
)
export WRF_FOLDER=$HOME/WRF_SFIRE_Intel
export DIR="${WRF_FOLDER}"/Libs
mkdir "${WRF_FOLDER}"
cd "${WRF_FOLDER}"
mkdir Downloads
mkdir WRFPLUS
mkdir WRFDA
mkdir Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
echo " "
##############################Downloading Libraries############################
# Force use of ipv4 with -4
cd Downloads
wget -c -4 https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c -4 https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c -4 https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c -4 https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c -4 https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c -4 https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
wget -c -4 https://github.com/openwfm/convert_geotiff/releases/download/v0.1/convert_geotiff-0.1.0.tar.gz
echo " "
############################# ZLib ############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
############################# LibPNG ############################
cd "${WRF_FOLDER}"/Downloads
# other libraries below need these variables to be set
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
############################# JasPer ############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
# other libraries below need these variables to be set
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
############################# HDF5 library for NetCDF4 & parallel functionality ############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
# other libraries below need these variables to be set
export HDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
export PATH=$HDF5/bin:$PATH
export PHDF5=$DIR/grib2
echo " "
#############################Install Parallel-netCDF##############################
#Make file created with half of available cpu cores
#Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
############################## Install NETCDF-C Library ############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
# these variables need to be set for the NetCDF-C install to work
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgcc -lm -ldl -lpnetcdf"
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
# other libraries below need these variables to be set
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
############################## NetCDF-Fortran library ############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
# these variables need to be set for the NetCDF-Fortran install to work
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc"
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
############################# Convert Geo Tiff #################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf convert_geotiff-0.1.0.tar.gz
cd convert_geotiff-0.1.0
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure -exec-prefix=$DIR/grib2 --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
#################################### System Environment Tests ##############
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c -4 https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
######################## ARWpost V3.1  ############################
## ARWpost
##Configure #3
###################################################################
cd "${WRF_FOLDER}"/Downloads
wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"
cd "${WRF_FOLDER}"/ARWpost
./clean -a
sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
export NETCDF=$DIR/NETCDF
if [ ${auto_config} -eq 1 ];
then
echo 2 | ./configure #Option 2 intel compiler with distributed memory
else
./configure #Option 2 intel compiler with distributed memory
fi
sed -i -e '31s/ifort/ifx/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
sed -i -e '36s/gcc/icx/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
sed -i -e '38s/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
./compile
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/ARWpost
n=$(ls ./*.exe | wc -l)
if (($n == 1));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH
echo " "
################################OpenGrADS######################################
#Verison 2.2.1 64bit of Linux
#############################################################################
if [[ $GRADS_PICK -eq 1 ]];
then
cd "${WRF_FOLDER}"/Downloads
tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
cd "${WRF_FOLDER}"/
mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
cd GrADS/Contents
wget -c https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
chmod +x g2ctl.pl
wget -c https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
tar -xzvf wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
cd wgrib2-v0.1.9.4/bin
mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
cd "${WRF_FOLDER}"/GrADS/Contents
rm wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
rm -r wgrib2-v0.1.9.4
export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH
fi
################################## GrADS ###############################
# Version  2.2.1
# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
########################################################################
if [[ $GRADS_PICK -eq 2 ]];
then
echo $PASSWD | sudo -S apt -y install grads
fi
##################### NCAR COMMAND LANGUAGE           ##################
########### NCL compiled via Conda                    ##################
########### This is the preferred method by NCAR      ##################
########### https://www.ncl.ucar.edu/index.shtml      ##################
echo " "
echo " "
# Installing Miniconda3 to WRF directory and updating libraries
echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
# Special Thanks to @_WaylonWalker for code development
echo " "
# Installing NCL via Conda
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create -n ncl_stable -c conda-forge ncl -y
conda activate ncl_stable
conda deactivate
conda deactivate
conda deactivate
echo " "
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
######################### Climate Data Operators ############
######################### CDO compiled via Conda ###########
####################### This is the preferred method #######
################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html ####################### source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create --name cdo_stable -y
conda activate cdo_stable
conda install -c conda-forge cdo -y
conda update --all -y
conda deactivate
conda deactivate
conda deactivate
echo " "
############################ WRF-SFIRE  #################################
## WRF-SFIRE
# Cloned from openwfm
# option 34, option 1 for gfortran and distributed memory w/basic nesting
# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
########################################################################
source /opt/intel/oneapi/setvars.sh --force
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WRF-SFIRE.git
cd "${WRF_FOLDER}"/WRF-SFIRE/
./clean -a # Clean old configuration files
if [ ${auto_config} -eq 1 ];
then
sed -i '428s/.*/  $response = "78 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl 
# Answer for compiler choice
sed -i '869s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl  
# Answer for basic nesting
./configure 2>&1 | tee configure.log
else
./configure 2>&1 | tee configure.log 
# Option 34 gfortran compiler with distributed memory option 1 for basic nesting
fi
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
cd "${WRF_FOLDER}"/WRF-SFIRE/
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
cd "${WRF_FOLDER}"/WRF-SFIRE
./compile -j $CPU_QUARTER_EVEN em_fire 2>&1 | tee compile.wrfsfire.log
export WRF_DIR="${WRF_FOLDER}"/WRF-SFIRE
############################WPSV4.2#####################################
## WPS v4.2
## Downloaded from git tagged releases
# Cloned from openwfm
# Option 3 for gfortran and distributed memory
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WPS.git
cd "${WRF_FOLDER}"/WPS
./clean -a
cd "${WRF_FOLDER}"/WPS
if [ ${auto_config} -eq 1 ];
then
echo 19 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
else
./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
fi
sed -i '65s|mpif90|mpiifx|g' "${WRF_FOLDER}"/WPS/configure.wps
sed -i '66s|mpicc|mpiicx|g' "${WRF_FOLDER}"/WPS/configure.wps
./compile 2>&1 | tee compile.wps.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
./compile 2>&1 | tee compile.wps2.log
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd "${WRF_FOLDER}"/Downloads
mkdir "${WRF_FOLDER}"/GEOG
mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
echo " "
echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
if [ ${WPS_Specific_Applications} -eq 1 ];
then
echo " "
echo " WPS Geographical Input Data Mandatory for Specific Applications"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
tar -xvf gsl_gwd.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
if [ ${Optional_GEOG} -eq 1 ];
then
echo " "
echo "Optional WPS Geographical Input Data"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
fi
if [ "$macos_64bit_GNU" = "1" ] && [ "$SFIRE_PICK" = "1" ] && [ "$MAC_CHIP" = "Intel" ];
then
#############################basic package managment############################
brew update
outdated_packages=$(brew outdated --quiet)
# List of packages to check/install
packages=(
"autoconf" "automake" "bison" "byacc" "cmake" "curl" "flex" "gcc"
"gdal" "gedit" "git" "gnu-sed" "grads" "imagemagick" "java" "ksh"
"libtool" "libxml2" "m4" "make" "python@3.12" "snapcraft" "tcsh" "wget"
"xauth" "xorgproto" "xorgrgb" "xquartz"
)
for pkg in "${packages[@]}"; do
if brew list "$pkg" &>/dev/null;
then
echo "$pkg is already installed."
if [[ $outdated_packages == *"$pkg"* ]];
then
echo "$pkg has a newer version available. Upgrading..."
brew upgrade "$pkg"
fi
else
echo "$pkg is not installed. Installing..."
brew install "$pkg"
fi
sleep 1
done
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export PATH=/usr/local/bin:$PATH
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRF_SFIRE
export WRF_FOLDER=$HOME/WRF_SFIRE
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir -p Libs/grib2
mkdir -p Libs/NETCDF
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
#############################Core Management####################################
export CPU_CORE=$(sysctl -n hw.ncpu) 
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))
# 1/2 of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
# then
# If statement for low core systems 
# Forces computers to only use 1 core if there are 4 cores or less on the system
then
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c -4 https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c -4 https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c -4 https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c -4 https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c -4 https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c -4 https://github.com/openwfm/convert_geotiff/releases/download/v0.1/convert_geotiff-0.1.0.tar.gz
echo " "
#############################Compilers############################
# Symlink to avoid clang conflicts with compilers
# default gcc path /usr/bin/gcc
# default homebrew path /usr/local/bin
# Find the highest version of GCC in /usr/local/bin
latest_gcc=$(ls /usr/local/bin/gcc-* 2>/dev/null | grep -o 'gcc-[0-9]*' | sort -V | tail -n 1)
latest_gpp=$(ls /usr/local/bin/g++-* 2>/dev/null | grep -o 'g++-[0-9]*' | sort -V | tail -n 1)
latest_gfortran=$(ls /usr/local/bin/gfortran-* 2>/dev/null | grep -o 'gfortran-[0-9]*' | sort -V | tail -n 1)
# Display the chosen versions
echo "Selected gcc version: $latest_gcc"
echo "Selected g++ version: $latest_gpp"
echo "Selected gfortran version: $latest_gfortran"
# Check if GCC, G++, and GFortran were found
if [ -z "$latest_gcc" ];
then
echo "No GCC version found in /usr/local/bin."
exit 1
fi
# Create or update the symbolic links for GCC, G++, and GFortran
echo "Linking the latest GCC version: $latest_gcc"
echo $PASSWD | sudo -S ln -sf /usr/local/bin/$latest_gcc /usr/local/bin/gcc
if [ ! -z "$latest_gpp" ];
then
echo "Linking the latest G++ version: $latest_gpp"
echo $PASSWD | sudo -S ln -sf /usr/local/bin/$latest_gpp /usr/local/bin/g++
fi
if [ ! -z "$latest_gfortran" ];
then
echo "Linking the latest GFortran version: $latest_gfortran"
echo $PASSWD | sudo -S ln -sf /usr/local/bin/$latest_gfortran /usr/local/bin/gfortran
fi
echo "Updated symbolic links for GCC, G++, and GFortran."
echo $PASSWD | sudo -S ln -sf /usr/local/bin/python3.12 /usr/local/bin/python3
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wall"
echo " "
# IF statement for GNU compiler issue
export GCC_VERSION=$($CC -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$($FC -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$($CXX -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib1.2.12
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$CC CXX=$CXX FC=$FC F77=$F77 ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS="$fallow_argument -m64" FCFLAGS="$fallow_argument -m64" 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee install.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
read -r -t 3 -p
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
read -r -t 3 -p
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
read -r -t 3 -p
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
echo " "
read -r -t 3 -p
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
read -r -t 3 -p
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
read -r -t 3 -p
############################# Convert Geo Tiff #################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf convert_geotiff-0.1.0.tar.gz
cd convert_geotiff-0.1.0
# Adjust CPP flags for Geo Tiff
export TIFF_LIB=$(echo /usr/local/Cellar/libtiff/*/lib)
export TIFF_INC=$(echo /usr/local/Cellar/libtiff/*/include)
export GEOTIFF_LIB=$(echo /usr/local/Cellar/libgeotiff/*/lib)
export GEOTIFF_INC=$(echo /usr/local/Cellar/libgeotiff/*/include)
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include -I$GEOTIFF_INC -I$TIFF_INC"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib -L$GEOTIFF_LIB -L$TIFF_LIB"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure -exec-prefix=$DIR/grib2 --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
# Changes flags back to netcdf only
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
read -r -t 3 -p
#################################### System Environment Tests ##############
mkdir -p "${WRF_FOLDER}"/Tests/Environment
mkdir -p "${WRF_FOLDER}"/Tests/Compatibility
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c -4 https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
gfortran-12 TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
gfortran-12 TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
gcc-12 TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
gcc-12 -c -m64 TEST_4_fortran+c_c.c
gfortran-12 -c -m64 TEST_4_fortran+c_f.f90
gfortran-12 -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
gfortran-12 -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
gfortran-12 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
read -r -t 3 -p
################################OpenGrADS######################################
# Verison 2.2.1 64bit of Linux
#############################################################################
if [[ $GRADS_PICK -eq 1 ]];
then
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/macOS/opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg
sudo -S installer -pkg opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg -target /Applications/OpenGrads <<<"$PASSWD"
fi
################################## GrADS ###############################
# Version  2.2.1
# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
########################################################################
if [[ $GRADS_PICK -eq 2 ]];
then
brew install grads
fi
#########################################################################
# Installing Miniconda3 to WRF directory and updating libraries
#########################################################################
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
wget -c -4 https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
echo " "
# Installing NCL via Conda
# source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create -n ncl_stable -c conda-forge ncl -y
conda activate ncl_stable
conda deactivate
conda deactivate
conda deactivate
echo " "
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
######################### Climate Data Operators ############
######################### CDO compiled via Conda ###########
####################### This is the preferred method #######
################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create --name cdo_stable -y
conda activate cdo_stable
conda install -c conda-forge cdo -y
conda update --all -y
conda deactivate
conda deactivate
conda deactivate
echo " "
################################## QGIS #####################################
# QGIS (Quantum Geographic Information System) is a free and open-source platform that allows users to
# analyze, view, and edit geospatial data. It supports both vector and raster layers, as well as various 
# web services, and is extensible through community-developed plugins. Key features include map
# creation, spatial analysis, and data management.
#############################################################################
conda env create -f $HOME/weather-ai/qgis.3.28.8.yml
echo " "
read -r -t 3 -p
############################ WRF-SFIRE  #################################
## WRF-SFIRE
# Cloned from openwfm
# option 34, option 1 for gfortran and distributed memory w/basic nesting
# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WRF-SFIRE.git
cd "${WRF_FOLDER}"/WRF-SFIRE/
./clean -a # Clean old configuration files
if [ ${auto_config} -eq 1 ];
then
sed -i '428s/.*/  $response = "17 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl # Answer for compiler choice
sed -i '869s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl  #Answer for basic nesting
./configure 2>&1 | tee configure.log
else
./configure 2>&1 | tee configure.log #Option 17 gfortran compiler with distributed memory option 1 for basic nesting
fi
sed -i'' -e '145s/-c/-c -fPIC -fPIE -O3  -Wno-error=implicit-function-declaration/g' configure.wrf
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
cd "${WRF_FOLDER}"/WRF-SFIRE/
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
read -r -t 3 -p
cd "${WRF_FOLDER}"/WRF-SFIRE
./compile -j $CPU_QUARTER_EVEN em_fire 2>&1 | tee compile.wrfsfire.log
export WRF_DIR="${WRF_FOLDER}"/WRF-SFIRE
read -r -t 3 -p
############################WPSV4.2#####################################
## WPS v4.2
## Downloaded from git tagged releases
# Cloned from openwfm
# Option 3 for gfortran and distributed memory
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WPS.git
cd "${WRF_FOLDER}"/WPS
./clean -a
cd "${WRF_FOLDER}"/WPS
if [ ${auto_config} -eq 1 ];
then
FFLAGS=$FFLAGS echo 19 | ./configure 2>&1 | tee configure.log 
# Option 19 for gfortran and distributed memory
else
FFLAGS=$FFLAGS ./configure 2>&1 | tee configure.log 
# Option 19 gfortran compiler with distributed memory
fi
# sed statements for issue with GNUv10+
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i '70s/-frecord-marker=4/-frecord-marker=4 -m64 -fallow-argument-mismatch/g' "${WRF_FOLDER}"/WPS/configure.wps
sed -i '71s/-frecord-marker=4/-frecord-marker=4 -m64 -fallow-argument-mismatch/g' "${WRF_FOLDER}"/WPS/configure.wps
fi
./compile 2>&1 | tee compile.wps.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
./compile 2>&1 | tee compile.wps2.log
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
read -r -t 3 -p
echo " "
######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd "${WRF_FOLDER}"/Downloads
mkdir "${WRF_FOLDER}"/GEOG
mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
echo " "
echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
if [ ${WPS_Specific_Applications} -eq 1 ];
then
echo " "
echo " WPS Geographical Input Data Mandatory for Specific Applications"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
tar -xvf gsl_gwd.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
if [ ${Optional_GEOG} -eq 1 ];
then
echo " "
echo "Optional WPS Geographical Input Data"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
fi
if [ "$macos_64bit_GNU" = "1" ] && [ "$SFIRE_PICK" = "1" ] && [ "$MAC_CHIP" = "ARM" ];
then
#############################basic package managment############################
brew update
outdated_packages=$(brew outdated --quiet)
# List of packages to check/install
packages=(
"autoconf" "automake" "bison" "byacc" "cmake" "curl" "flex" "gcc"
"gdal" "gedit" "git" "gnu-sed" "grads" "imagemagick" "java" "ksh"
"libtool" "libxml2" "m4" "make" "python@3.12" "snapcraft" "tcsh" "wget"
"xauth" "xorgproto" "xorgrgb" "xquartz"
)
for pkg in "${packages[@]}"; do
if brew list "$pkg" &>/dev/null;
then
echo "$pkg is already installed."
if [[ $outdated_packages == *"$pkg"* ]];
then
echo "$pkg has a newer version available. Upgrading..."
brew upgrade "$pkg"
fi
else
echo "$pkg is not installed. Installing..."
brew install "$pkg"
fi
sleep 1
done
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export PATH=/usr/local/bin:$PATH
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRF_SFIRE
export WRF_FOLDER=$HOME/WRF_SFIRE
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir -p Libs/grib2
mkdir -p Libs/NETCDF
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
#############################Core Management####################################
export CPU_CORE=$(sysctl -n hw.ncpu) # number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))
# 1/2 of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
# then
# If statement for low core systems 
# Forces computers to only use 1 core if there are 4 cores or less on the system
then
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c -4 https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c -4 https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c -4 https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c -4 https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c -4 https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c -4 https://github.com/openwfm/convert_geotiff/releases/download/v0.1/convert_geotiff-0.1.0.tar.gz
echo " "
#############################Compilers############################
# Unlink previous GCC, G++, and GFortran symlinks in Homebrew path to avoid conflicts
echo $PASSWD | sudo -S unlink /opt/homebrew/bin/gfortran
echo $PASSWD | sudo -S unlink /opt/homebrew/bin/gcc
echo $PASSWD | sudo -S unlink /opt/homebrew/bin/g++
# Source the bashrc to ensure environment variables are loaded
source ~/.bashrc
# Check current versions of gcc, g++, and gfortran (this should show no version if unlinked)
gcc --version
g++ --version
gfortran --version
# Navigate to the Homebrew binaries directory
cd /opt/homebrew/bin
# Find the latest version of GCC, G++, and GFortran
latest_gcc=$(ls gcc-* 2>/dev/null | grep -o 'gcc-[0-9]*' | sort -V | tail -n 1)
latest_gpp=$(ls g++-* 2>/dev/null | grep -o 'g++-[0-9]*' | sort -V | tail -n 1)
latest_gfortran=$(ls gfortran-* 2>/dev/null | grep -o 'gfortran-[0-9]*' | sort -V | tail -n 1)
# Check if the latest versions were found, and link them
if [ -n "$latest_gcc" ];
then
echo "Linking the latest GCC version: $latest_gcc"
echo $PASSWD | sudo -S ln -sf $latest_gcc gcc
else
echo "No GCC version found."
fi
if [ -n "$latest_gpp" ];
then
echo "Linking the latest G++ version: $latest_gpp"
echo $PASSWD | sudo -S ln -sf $latest_gpp g++
else
echo "No G++ version found."
fi
if [ -n "$latest_gfortran" ];
then
echo "Linking the latest GFortran version: $latest_gfortran"
echo $PASSWD | sudo -S ln -sf $latest_gfortran gfortran
else
echo "No GFortran version found."
fi
# Return to the home directory
cd
# Source bashrc and bash_profile to reload the environment settings
source ~/.bashrc
source ~/.bash_profile
# Check if the versions were successfully updated
gcc --version
g++ --version
gfortran --version
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wall"
echo " "
#IF statement for GNU compiler issue
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib1.2.12
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$CC CXX=$CXX FC=$FC F77=$F77 ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS="$fallow_argument -m64" FCFLAGS="$fallow_argument -m64" 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee install.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
read -r -t 3 -p
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
read -r -t 3 -p
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
read -r -t 3 -p
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
echo " "
read -r -t 3 -p
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
read -r -t 3 -p
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
read -r -t 3 -p
############################# Convert Geo Tiff #################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf convert_geotiff-0.1.0.tar.gz
cd convert_geotiff-0.1.0
# Adjust CPP flags for Geo Tiff
export TIFF_LIB=$(echo /usr/local/Cellar/libtiff/*/lib)
export TIFF_INC=$(echo /usr/local/Cellar/libtiff/*/include)
export GEOTIFF_LIB=$(echo /usr/local/Cellar/libgeotiff/*/lib)
export GEOTIFF_INC=$(echo /usr/local/Cellar/libgeotiff/*/include)
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include -I$GEOTIFF_INC -I$TIFF_INC"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib -L$GEOTIFF_LIB -L$TIFF_LIB"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure -exec-prefix=$DIR/grib2 --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
# Changes flags back to netcdf only
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
read -r -t 3 -p
#################################### System Environment Tests ##############
mkdir -p "${WRF_FOLDER}"/Tests/Environment
mkdir -p "${WRF_FOLDER}"/Tests/Compatibility
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c -4 https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
gfortran-12 TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
gfortran-12 TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
gcc-12 TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
gcc-12 -c -m64 TEST_4_fortran+c_c.c
gfortran-12 -c -m64 TEST_4_fortran+c_f.f90
gfortran-12 -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
gfortran-12 -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
gfortran-12 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
read -r -t 3 -p
################################OpenGrADS######################################
# Verison 2.2.1 64bit of Linux
#############################################################################
if [[ $GRADS_PICK -eq 1 ]];
then
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/macOS/opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg
sudo -S installer -pkg opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg -target /Applications/OpenGrads <<<"$PASSWD"
fi
################################## GrADS ###############################
# Version  2.2.1
# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
########################################################################
if [[ $GRADS_PICK -eq 2 ]];
then
brew install grads
fi
#######################################################################
# Installing Miniconda3 to WRF directory and updating libraries
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
#######################################################################
mkdir -p $Miniconda_Install_DIR
wget -c -4 https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
echo " "
# Installing NCL via Conda
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create -n ncl_stable -c conda-forge ncl -y
conda activate ncl_stable
conda deactivate
conda deactivate
conda deactivate
echo " "
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
######################### Climate Data Operators ############
######################### CDO compiled via Conda ###########
####################### This is the preferred method #######
################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################

source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create --name cdo_stable -y
conda activate cdo_stable
conda install -c conda-forge cdo -y
conda update --all -y
conda deactivate
conda deactivate
conda deactivate
echo " "
read -r -t 3 -p
############################ WRF-SFIRE  #################################
## WRF-SFIRE
# Cloned from openwfm
# option 34, option 1 for gfortran and distributed memory w/basic nesting
# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WRF-SFIRE.git
cd "${WRF_FOLDER}"/WRF-SFIRE/
./clean -a # Clean old configuration files
if [ ${auto_config} -eq 1 ];
then
sed -i '428s/.*/  $response = "17 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl # Answer for compiler choice
sed -i '869s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl  #Answer for basic nesting
./configure 2>&1 | tee configure.log
else
./configure 2>&1 | tee configure.log #Option 17 gfortran compiler with distributed memory option 1 for basic nesting
fi
sed -i'' -e '145s/-c/-c -fPIC -fPIE -O3  -Wno-error=implicit-function-declaration/g' configure.wrf
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
cd "${WRF_FOLDER}"/WRF-SFIRE/
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
read -r -t 3 -p
cd "${WRF_FOLDER}"/WRF-SFIRE
./compile -j $CPU_QUARTER_EVEN em_fire 2>&1 | tee compile.wrfsfire.log
export WRF_DIR="${WRF_FOLDER}"/WRF-SFIRE
read -r -t 3 -p
############################WPSV4.2#####################################
## WPS v4.2
## Downloaded from git tagged releases
# Cloned from openwfm
# Option 3 for gfortran and distributed memory
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WPS.git
cd "${WRF_FOLDER}"/WPS
./clean -a
cd "${WRF_FOLDER}"/WPS
if [ ${auto_config} -eq 1 ];
then
FFLAGS=$FFLAGS echo 19 | ./configure 2>&1 | tee configure.log #Option 19 for gfortran and distributed memory
else
FFLAGS=$FFLAGS ./configure 2>&1 | tee configure.log #Option 19 gfortran compiler with distributed memory
fi
# sed statements for issue with GNUv10+
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i '72s/-frecord-marker=4/-frecord-marker=4 -m64 -fallow-argument-mismatch/g' "${WRF_FOLDER}"/WPS/configure.wps
sed -i '73s/-frecord-marker=4/-frecord-marker=4 -m64 -fallow-argument-mismatch/g' "${WRF_FOLDER}"/WPS/configure.wps
fi
./compile 2>&1 | tee compile.wps.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
./compile 2>&1 | tee compile.wps2.log
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
read -r -t 3 -p
echo " "
######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd "${WRF_FOLDER}"/Downloads
mkdir "${WRF_FOLDER}"/GEOG
mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
echo " "
echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
if [ ${WPS_Specific_Applications} -eq 1 ];
then
echo " "
echo " WPS Geographical Input Data Mandatory for Specific Applications"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
tar -xvf gsl_gwd.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
if [ ${Optional_GEOG} -eq 1 ];
then
echo " "
echo "Optional WPS Geographical Input Data"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
fi
if [ "$RHL_64bit_GNU" = "1" ] && [ "$SFIRE_PICK" = "1" ];
then
#############################basic package managment############################
echo $PASSWD | sudo -S yum install epel-release -y
echo $PASSWD | sudo -S yum install dnf -y
echo $PASSWD | sudo -S dnf install epel-release -y
echo $PASSWD | sudo -S dnf install dnf -y
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk  ksh libjpeg libjpeg-devel libX11 libX11-devel libXaw libXaw-devel libXext-devel libXmu libXmu-devel libXrender libXrender-devel libXt libXt-devel libxml2 libxml2-devel libXmu libXmu-devel libgeotiff libgeotiff-devel libtiff libtiff-devel m4 nfs-utils perl pkgconfig pixman pixman-devel python3 python3-devel tcsh time unzip wget
echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRF_SFIRE
export WRF_FOLDER=$HOME/WRF_SFIRE
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
echo " "
#############################Core Management####################################
export CPU_CORE=$(nproc) 
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))             
# quarter of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) 
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
then 
# If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system.
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
# Force use of ipv4 with -4
cd Downloads
wget -c -4 https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c -4 https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c -4 https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c -4 https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c -4 https://src.fedoraproject.org/repo/pkgs/jasper/jasper-$Jasper_Version.zip/a342b2b4495b3e1394e161eb5d85d754/jasper-$Jasper_Version.zip
wget -c -4 https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
wget -c -4 https://github.com/openwfm/convert_geotiff/releases/download/v0.1/convert_geotiff-0.1.0.tar.gz
echo " "
####################################Compilers#####################################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -O3"
# IF statement for GNU compiler issue
export GCC_VERSION=$(gcc -dumpversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib$Zlib_Version
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
# F90= due to compiler issues with mpich install
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "k
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
############################# Convert Geo Tiff #################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf convert_geotiff-0.1.0.tar.gz
cd convert_geotiff-0.1.0
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include -I/usr/include/libgeotiff"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib -L/usr/lib/libgeotiff"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure -exec-prefix=$DIR/grib2 --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
#################################### System Environment Tests ##############
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c -4 https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
###############################NCEPlibs#####################################
# The libraries are built and installed with
# ./make_ncep_libs.sh -s MACHINE -c COMPILER -d NCEPLIBS_DIR -o OPENMP [-m mpi] [-a APPLICATION]
# It is recommended to install the NCEPlibs into their own directory, which must be created before running the installer.
# Further information on the command line arguments can be obtained with ./make_ncep_libs.sh -h
# If and error occurs go to https://github.com/NCAR/NCEPlibs/pull/16/files make adjustment and re-run ./make_ncep_libs.sh
############################################################################
cd "${WRF_FOLDER}"/Downloads
git clone https://github.com/NCAR/NCEPlibs.git
cd NCEPlibs
mkdir $DIR/nceplibs
export JASPER_INC=$DIR/grib2/include
export PNG_INC=$DIR/grib2/include
export NETCDF=$DIR/NETCDF
#for loop to edit linux.gnu for nceplibs to install
#make if statement for gcc-9 or older
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i "24s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "28s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "32s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "36s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "40s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "45s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "49s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "53s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "56s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "60s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "64s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "68s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "69s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "73s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "74s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "79s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
fi
if [ ${auto_config} -eq 1 ];
then
echo yes | ./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
else
./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
fi
export PATH=$DIR/nceplibs:$PATH
echo " "
######################## ARWpost V3.1  ############################
## ARWpost
## Configure #3
###################################################################
cd "${WRF_FOLDER}"/Downloads
wget -c -4 http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"/
cd "${WRF_FOLDER}"/ARWpost
./clean -a
sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
export NETCDF=$DIR/NETCDF
if [ ${auto_config} -eq 1 ];
then
echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
else
./configure #Option 3 gfortran compiler with distributed memory
fi
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i '32s/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4 ${fallow_argument} /g' configure.arwp
fi
sed -i -e 's/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
./compile
#IF statement to check that all files were created.
cd "${WRF_FOLDER}"/ARWpost
n=$(ls ./*.exe | wc -l)
if (($n == 1));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH
echo " "
################################ OpenGrADS ##################################
#Verison 2.2.1 32bit of Linux
#############################################################################
if [[ $GRADS_PICK -eq 1 ]];
then
cd "${WRF_FOLDER}"/Downloads
tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
cd "${WRF_FOLDER}"/
mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
cd GrADS/Contents
wget -c -4 https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
chmod +x g2ctl.pl
wget -c -4 https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
tar -xzvf wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
cd wgrib2-v0.1.9.4/bin
mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
cd "${WRF_FOLDER}"/GrADS/Contents
rm wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
rm -r wgrib2-v0.1.9.4
export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH
echo " "
fi
################################## GrADS ###############################
# Version  2.2.1
# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
########################################################################
if [[ $GRADS_PICK -eq 2 ]];
then
cd "${WRF_FOLDER}"/Downloads
wget -c -4 ftp://cola.gmu.edu/grads/2.2/grads-2.2.1-bin-RHL7.4-x86_64.tar.gz
tar -xzvf grads-2.2.1-bin-RHL7.4-x86_64.tar.gz -C "${WRF_FOLDER}"
cd "${WRF_FOLDER}"/grads-2.2.1/bin
chmod 775 *
fi
##################### NCAR COMMAND LANGUAGE           ##################
########### NCL compiled via Conda                    ##################
########### This is the preferred method by NCAR      ##################
########### https://www.ncl.ucar.edu/index.shtml      ##################
# Installing Miniconda3 to WRF-Hydro directory and updating libraries
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
wget -c -4 https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
echo " "
echo " "
#Installing NCL via Conda
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create -n ncl_stable -c conda-forge ncl -y
conda activate ncl_stable
conda deactivate
conda deactivate
conda deactivate
echo " "
############################## RIP4 #####################################
mkdir "${WRF_FOLDER}"/RIP4
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/RIP_47.tar.gz
tar -xvzf RIP_47.tar.gz -C "${WRF_FOLDER}"/RIP4
cd "${WRF_FOLDER}"/RIP4/RIP_47
mv * ..
cd "${WRF_FOLDER}"/RIP4
rm -rd RIP_47
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda activate ncl_stable
conda install -c conda-forge c-compiler fortran-compiler cxx-compiler -y
export RIP_ROOT="${WRF_FOLDER}"/RIP4
export NETCDF=$DIR/NETCDF
export NCARG_ROOT="${WRF_FOLDER}"/anaconda3/envs/ncl_stable
sed -i '349s|-L${NETCDF}/lib -lnetcdf $NETCDFF|-L${NETCDF}/lib $NETCDFF -lnetcdff -lnetcdf -lnetcdf -lnetcdff_C -lhdf5 |g' "${WRF_FOLDER}"/RIP4/configure
sed -i '27s|NETCDFLIB	= -L${NETCDF}/lib -lnetcdf CONFIGURE_NETCDFF_LIB|NETCDFLIB	= -L</usr/lib/x86_64-linux-gnu/libm.a> -lm -L${NETCDF}/lib CONFIGURE_NETCDFF_LIB -lnetcdf -lhdf5 -lhdf5_hl -lgfortran -lgcc -lz |g' "${WRF_FOLDER}"/RIP4/arch/preamble
sed -i '31s|-L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz CONFIGURE_NCARG_LIB| -L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz -lcairo -lfontconfig -lpixman-1 -lfreetype -lexpat -lpthread -lbz2 -lXrender -lgfortran -lgcc -L</usr/lib/x86_64-linux-gnu/> -lm -lhdf5 -lhdf5_hl |g' "${WRF_FOLDER}"/RIP4/arch/preamble
sed -i '33s| -O|-fallow-argument-mismatch -O |g' "${WRF_FOLDER}"/RIP4/arch/configure.defaults
sed -i '35s|=|= -L"${WRF_FOLDER}"/LIBS/grib2/lib -lhdf5 -lhdf5_hl |g' "${WRF_FOLDER}"/RIP4/arch/configure.defaults
if [ ${auto_config} -eq 1 ];
then
echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
else
./configure #Option 3 gfortran compiler with distributed memory
fi
./compile
conda deactivate
conda deactivate
conda deactivate
echo " "
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
echo " "
######################### Climate Data Operators ############
######################### CDO compiled via Conda ###########
####################### This is the preferred method #######
################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create --name cdo_stable -y
conda activate cdo_stable
conda install -c conda-forge cdo -y
conda update --all -y
conda deactivate
conda deactivate
conda deactivate
echo " "
################################## QGIS #####################################
# QGIS (Quantum Geographic Information System) is a free and open-source platform that allows users to
# analyze, view, and edit geospatial data. It supports both vector and raster layers, as well as various
# web services, and is extensible through community-developed plugins. Key features include map
# creation, spatial analysis, and data management.
#############################################################################
conda env create -f $HOME/weather-ai/qgis.3.28.8.yml
echo " "
############################ WRF-SFIRE  #################################
## WRF-SFIRE
# Cloned from openwfm
# option 34, option 1 for gfortran and distributed memory w/basic nesting
# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WRF-SFIRE.git
cd "${WRF_FOLDER}"/WRF-SFIRE/
./clean -a # Clean old configuration files
if [ ${auto_config} -eq 1 ];
then
sed -i '428s/.*/  $response = "34 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl # Answer for compiler choice
sed -i '869s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl  #Answer for basic nesting
./configure 2>&1 | tee configure.log
else
./configure 2>&1 | tee configure.log #Option 34 gfortran compiler with distributed memory option 1 for basic nesting
fi
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
cd "${WRF_FOLDER}"/WRF-SFIRE/
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
cd "${WRF_FOLDER}"/WRF-SFIRE
./compile -j $CPU_QUARTER_EVEN em_fire 2>&1 | tee compile.wrfsfire.log
export WRF_DIR="${WRF_FOLDER}"/WRF-SFIRE
############################WPSV4.2#####################################
## WPS v4.2
## Downloaded from git tagged releases
# Cloned from openwfm
# Option 3 for gfortran and distributed memory
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WPS.git
cd "${WRF_FOLDER}"/WPS
./clean -a
cd "${WRF_FOLDER}"/WPS
if [ ${auto_config} -eq 1 ];
then
FFLAGS=$FFLAGS echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
else
FFLAGS=$FFLAGS ./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
fi
#sed statements for issue with GNUv10+
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i '70s/-frecord-marker=4/-frecord-marker=4 -m64 -fallow-argument-mismatch/g' "${WRF_FOLDER}"/WPS/configure.wps
sed -i '71s/-frecord-marker=4/-frecord-marker=4 -m64 -fallow-argument-mismatch/g' "${WRF_FOLDER}"/WPS/configure.wps
fi
./compile 2>&1 | tee compile.wps.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
./compile 2>&1 | tee compile.wps2.log
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd "${WRF_FOLDER}"/Downloads
mkdir "${WRF_FOLDER}"/GEOG
mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
echo " "
echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
if [ ${WPS_Specific_Applications} -eq 1 ];
then
echo " "
echo " WPS Geographical Input Data Mandatory for Specific Applications"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
tar -xvf gsl_gwd.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
if [ ${Optional_GEOG} -eq 1 ];
then
echo " "
echo "Optional WPS Geographical Input Data"
echo " "
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c -4 https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
fi
if [ "$RHL_64bit_GNU" = "2" ] && [ "$SFIRE_PICK" = "1" ];
then
#############################basic package managment############################
echo "old version of GNU detected"
echo $PASSWD | sudo -S yum install epel-release -y
echo $PASSWD | sudo -S yum install RHL-release-scl -y
echo $PASSWD | sudo -S yum clean all
echo $PASSWD | sudo -S yum remove devtoolset-11*
echo $PASSWD | sudo -S yum install devtoolset-11
echo $PASSWD | sudo -S yum install devtoolset-11-\* -y
echo $PASSWD | sudo -S yum -y update
echo $PASSWD | sudo -S yum -y upgrade
source /opt/rh/devtoolset-11/enable
gcc --version
echo $PASSWD | sudo -S yum install epel-release -y
echo $PASSWD | sudo -S yum install dnf -y
echo $PASSWD | sudo -S dnf install epel-release -y
echo $PASSWD | sudo -S dnf install dnf -y
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk  ksh libjpeg libjpeg-deve libX11 libX11-devel libXaw libXaw-devel libXext-devel libXmu libXmu-devel libXrender libXrender-devel libXt libXt-devel libxml2 libxml2-devel libXmu libXmu-devel libgeotiff libgeotiff-devel libtiff libtiff-devel m4 nfs-utils perl pkgconfig pixman pixman-devel python3 python3-devel tcsh time unzip wget
echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
source /opt/rh/devtoolset-11/enable
echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRF_SFIRE
export WRF_FOLDER=$HOME/WRF_SFIRE
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
echo " "
#############################Core Management####################################
export CPU_CORE=$(nproc)
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4)) 
# quarter of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
then 
# If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system.
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
#Force use of ipv4 with -4
cd Downloads
wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c https://src.fedoraproject.org/repo/pkgs/jasper/jasper-$Jasper_Version.zip/a342b2b4495b3e1394e161eb5d85d754/jasper-$Jasper_Version.zip
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
wget -c https://github.com/openwfm/convert_geotiff/releases/download/v0.1/convert_geotiff-0.1.0.tar.gz
echo " "
####################################Compilers#####################################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -O3"
#IF statement for GNU compiler issue
export GCC_VERSION=$(gcc -dumpversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib$Zlib_Version
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
# F90= due to compiler issues with mpich install
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
############################# Convert Geo Tiff #################################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf convert_geotiff-0.1.0.tar.gz
cd convert_geotiff-0.1.0
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include -I/usr/include/libgeotiff"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib -L/usr/lib/libgeotiff"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 CFLAGS=$CFLAGS FCFLAGS=$FCFLAGS ./configure -exec-prefix=$DIR/grib2 --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
#################################### System Environment Tests ##############
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
###############################NCEPlibs#####################################
# The libraries are built and installed with
# ./make_ncep_libs.sh -s MACHINE -c COMPILER -d NCEPLIBS_DIR -o OPENMP [-m mpi] [-a APPLICATION]
# It is recommended to install the NCEPlibs into their own directory, which must be created before running the installer.
# Further information on the command line arguments can be obtained with ./make_ncep_libs.sh -h
# If iand error occurs go to https://github.com/NCAR/NCEPlibs/pull/16/files make adjustment and re-run ./make_ncep_libs.sh
############################################################################
cd "${WRF_FOLDER}"/Downloads
git clone https://github.com/NCAR/NCEPlibs.git
cd NCEPlibs
mkdir $DIR/nceplibs
export JASPER_INC=$DIR/grib2/include
export PNG_INC=$DIR/grib2/include
export NETCDF=$DIR/NETCDF
#for loop to edit linux.gnu for nceplibs to install
# make if statement for gcc-9 or older
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i "24s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "28s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "32s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "36s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "40s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "45s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "49s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "53s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "56s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "60s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "64s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "68s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "69s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "73s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "74s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
sed -i "79s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
fi
if [ ${auto_config} -eq 1 ];
then
echo yes | ./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
else
./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
fi
export PATH=$DIR/nceplibs:$PATH
echo " "
######################## ARWpost V3.1  ############################
## ARWpost
## Configure #3
###################################################################
cd "${WRF_FOLDER}"/Downloads
wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"/
cd "${WRF_FOLDER}"/ARWpost
./clean -a
sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
export NETCDF=$DIR/NETCDF
if [ ${auto_config} -eq 1 ];
then
echo 3 | ./configure
# Option 3 gfortran compiler with distributed memory
else
./configure
# Option 3 gfortran compiler with distributed memory
fi
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i '32s/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4 ${fallow_argument} /g' configure.arwp
fi
sed -i -e 's/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
./compile
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/ARWpost
n=$(ls ./*.exe | wc -l)
if (($n == 1));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
echo " "
export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH
echo " "
################################ OpenGrADS ##################################
# Verison 2.2.1 32bit of Linux
#############################################################################
if [[ $GRADS_PICK -eq 1 ]];
then
cd "${WRF_FOLDER}"/Downloads
tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
cd "${WRF_FOLDER}"/
mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
cd GrADS/Contents
wget -c https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
chmod +x g2ctl.pl
wget -c https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
tar -xzvf wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
cd wgrib2-v0.1.9.4/bin
mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
cd "${WRF_FOLDER}"/GrADS/Contents
rm wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
rm -r wgrib2-v0.1.9.4
export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH
echo " "
fi
################################## GrADS ###############################
# Version  2.2.1
# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
########################################################################
if [[ $GRADS_PICK -eq 2 ]];
then
cd "${WRF_FOLDER}"/Downloads
wget -c ftp://cola.gmu.edu/grads/2.2/grads-2.2.1-bin-RHL7.4-x86_64.tar.gz
tar -xzvf grads-2.2.1-bin-RHL7.4-x86_64.tar.gz -C "${WRF_FOLDER}"
cd "${WRF_FOLDER}"/grads-2.2.1/bin
chmod 775 *
fi
##################### NCAR COMMAND LANGUAGE           ##################
########### NCL compiled via Conda                    ##################
########### This is the preferred method by NCAR      ##################
########### https://www.ncl.ucar.edu/index.shtml      ##################
# Installing Miniconda3 to WRF-Hydro directory and updating libraries
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
echo " "
echo " "
# Installing NCL via Conda
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create -n ncl_stable -c conda-forge ncl -y
conda activate ncl_stable
conda deactivate
conda deactivate
conda deactivate
echo " "
############################## RIP4 #####################################
mkdir "${WRF_FOLDER}"/RIP4
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/src/RIP_47.tar.gz
tar -xvzf RIP_47.tar.gz -C "${WRF_FOLDER}"/RIP4
cd "${WRF_FOLDER}"/RIP4/RIP_47
mv * ..
cd "${WRF_FOLDER}"/RIP4
rm -rd RIP_47
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda activate ncl_stable
conda install -c conda-forge c-compiler fortran-compiler cxx-compiler -y
export RIP_ROOT="${WRF_FOLDER}"/RIP4
export NETCDF=$DIR/NETCDF
export NCARG_ROOT="${WRF_FOLDER}"/anaconda3/envs/ncl_stable
sed -i '349s|-L${NETCDF}/lib -lnetcdf $NETCDFF|-L${NETCDF}/lib $NETCDFF -lnetcdff -lnetcdf -lnetcdf -lnetcdff_C -lhdf5 |g' "${WRF_FOLDER}"/RIP4/configure
sed -i '27s|NETCDFLIB	= -L${NETCDF}/lib -lnetcdf CONFIGURE_NETCDFF_LIB|NETCDFLIB	= -L</usr/lib/x86_64-linux-gnu/libm.a> -lm -L${NETCDF}/lib CONFIGURE_NETCDFF_LIB -lnetcdf -lhdf5 -lhdf5_hl -lgfortran -lgcc -lz |g' "${WRF_FOLDER}"/RIP4/arch/preamble
sed -i '31s|-L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz CONFIGURE_NCARG_LIB| -L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz -lcairo -lfontconfig -lpixman-1 -lfreetype -lexpat -lpthread -lbz2 -lXrender -lgfortran -lgcc -L</usr/lib/x86_64-linux-gnu/> -lm -lhdf5 -lhdf5_hl |g' "${WRF_FOLDER}"/RIP4/arch/preamble
sed -i '33s| -O|-fallow-argument-mismatch -O |g' "${WRF_FOLDER}"/RIP4/arch/configure.defaults
sed -i '35s|=|= -L"${WRF_FOLDER}"/LIBS/grib2/lib -lhdf5 -lhdf5_hl |g' "${WRF_FOLDER}"/RIP4/arch/configure.defaults
if [ ${auto_config} -eq 1 ];
then
echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
else
./configure #Option 3 gfortran compiler with distributed memory
fi
./compile
conda deactivate
conda deactivate
conda deactivate
echo " "
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
echo " "
######################### Climate Data Operators ############
######################### CDO compiled via Conda ###########
####################### This is the preferred method #######
################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create --name cdo_stable -y
conda activate cdo_stable
conda install -c conda-forge cdo -y
conda update --all -y
conda deactivate
conda deactivate
conda deactivate
echo " "
################################## QGIS #####################################
# QGIS (Quantum Geographic Information System) is a free and open-source platform that allows users to
# analyze, view, and edit geospatial data. It supports both vector and raster layers, as well as various
# web services, and is extensible through community-developed plugins. Key features include map
# creation, spatial analysis, and data management.
#############################################################################
conda env create -f $HOME/weather-ai/qgis.3.28.8.yml
echo " "
############################ WRF-SFIRE  #################################
## WRF-SFIRE
# Cloned from openwfm
# option 34, option 1 for gfortran and distributed memory w/basic nesting
# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WRF-SFIRE.git
cd "${WRF_FOLDER}"/WRF-SFIRE/
./clean -a # Clean old configuration files
if [ ${auto_config} -eq 1 ];
then
sed -i '428s/.*/  $response = "34 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl # Answer for compiler choice
sed -i '869s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRF-SFIRE/arch/Config.pl  #Answer for basic nesting
./configure 2>&1 | tee configure.log
else
./configure 2>&1 | tee configure.log #Option 34 gfortran compiler with distributed memory option 1 for basic nesting
fi
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
cd "${WRF_FOLDER}"/WRF-SFIRE/
./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
cd "${WRF_FOLDER}"/WRF-SFIRE/main
n=$(ls ./*.exe | wc -l)
if (($n >= 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
cd "${WRF_FOLDER}"/WRF-SFIRE
export WRF_DIR="${WRF_FOLDER}"/WRF-SFIRE
############################WPSV4.2#####################################
## WPS v4.2
## Downloaded from git tagged releases
# Cloned from openwfm
# Option 3 for gfortran and distributed memory
########################################################################
cd "${WRF_FOLDER}"
git clone https://github.com/openwfm/WPS.git
cd "${WRF_FOLDER}"/WPS
./clean -a
cd "${WRF_FOLDER}"/WPS
if [ ${auto_config} -eq 1 ];
then
FFLAGS=$FFLAGS echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
else
FFLAGS=$FFLAGS ./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
fi
# sed statements for issue with GNUv10+
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
sed -i '70s/-frecord-marker=4/-frecord-marker=4 -m64 -fallow-argument-mismatch/g' "${WRF_FOLDER}"/WPS/configure.wps
sed -i '71s/-frecord-marker=4/-frecord-marker=4 -m64 -fallow-argument-mismatch/g' "${WRF_FOLDER}"/WPS/configure.wps
fi
./compile 2>&1 | tee compile.wps.log
# IF statement to check that all files were created.
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
echo "Missing one or more expected files."
echo "Running compiler again"
./compile 2>&1 | tee compile.wps2.log
cd "${WRF_FOLDER}"/WPS
n=$(ls ./*.exe | wc -l)
if (($n == 3));
then
echo "All expected files created."
read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
else
read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
# exit
fi
fi
echo " "
######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd "${WRF_FOLDER}"/Downloads
mkdir "${WRF_FOLDER}"/GEOG
mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
echo " "
echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
if [ ${WPS_Specific_Applications} -eq 1 ];
then
echo " "
echo " WPS Geographical Input Data Mandatory for Specific Applications"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
tar -xvf gsl_gwd.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
if [ ${Optional_GEOG} -eq 1 ];
then
echo " "
echo "Optional WPS Geographical Input Data"
echo " "
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
fi
fi
############################################# WRF Hydro Standalone #################################
## WRFHYDRO Standalone installation with parallel process.
# Download and install required library and data files for WRFHYDRO.
# Tested in Ubuntu 20.0${WPS_VERSION} LTS & Ubuntu 22.04, Rocky Linux 9 & MacOS Ventura 64bit
# Built in 64-bit system
# Built with Intel or GNU compilers
# Tested with current available libraries on 10/10/2023
# If newer libraries exist edit script paths for changes
# Estimated Run Time ~ 30 - 60 Minutes with 10mb/s downloadspeed.
# Special thanks to:
# Youtube's meteoadriatic, GitHub user jamal919.
# University of Manchester's  Doug L
# University of Tunis El Manar's Hosni
# GSL's Jordan S.
# NCAR's Mary B., Christine W., & Carl D.
# DTC's Julie P., Tara J., George M., & John H.
# UCAR's Katelyn F., Jim B., Jordan P., Kevin M.,
##############################################################
if [ "$Ubuntu_64bit_GNU" = "1" ] && [ "$WRFHYDRO_STANDALONE_PICK" = "1" ];
then
#############################basic package managment############################
echo $PASSWD | sudo -S apt -y update
echo $PASSWD | sudo -S apt -y upgrade
release_version=$(lsb_release -r -s)
# Compare the release version
if [ "$release_version" = "24.04" ];
then
# Install Emacs without recommended packages
echo $PASSWD | sudo -S apt install emacs --no-install-recommends -y
else
# Attempt to install Emacs if the release version is not 24.04
echo "The release version is not 24.04, attempting to install Emacs."
echo $PASSWD | sudo -S apt install emacs -y
fi
echo $PASSWD | sudo -S apt -y install autoconf automake autotools-dev bison build-essential byacc cmake csh curl default-jdk default-jre flex libfl-dev g++ gawk gcc gfortran git ksh libcurl4-openssl-dev libjpeg-dev libncurses6 libpixman-1-dev libpng-dev libtool libxml2 libxml2-dev libxml-libxml-perl m4 make ncview okular openbox pipenv pkg-config python3 python3-dev python3-pip python3-dateutil tcsh unzip xauth xorg time
echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRFHYDRO_STANDALONE
export WRF_FOLDER=$HOME/WRFHYDRO_STANDALONE
export DIR="${WRF_FOLDER}"/Libs
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir "${WRF_FOLDER}"/Hydro-Basecode
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
echo " "
#############################Core Management####################################
export CPU_CORE=$(nproc) 
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))                 
# quarter of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) 
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
# then 
# If statement for low core systems 
# Forces computers to only use 1 core if there are 4 cores or less on the system
then
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
cd Downloads
wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
echo " "
#############################Compilers############################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -O3"
# IF statement for GNU compiler issue
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "CFLAGS = $CFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib$Zlib_Version
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS="$fallow_argument -m64" FCFLAGS="$fallow_argument -m64" 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
echo " "
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#################################### System Environment Tests ##############
mkdir -p "${WRF_FOLDER}"/Tests/Environment
mkdir -p "${WRF_FOLDER}"/Tests/Compatibility
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
############################# WRF HYDRO V5.3.0 #################################
# Version 5.3.0
# Standalone mode
# GNU
################################################################################
# Set up NETCDF environment variables
export NETCDF_INC="$DIR/NETCDF/include"
export NETCDF_LIB="$DIR/NETCDF/lib"
# Create directories for Hydro Basecode and navigate to it
mkdir -p "${WRF_FOLDER}/Hydro-Basecode"
cd "${WRF_FOLDER}/Hydro-Basecode"
# Clone the WRF-Hydro repository and set up the build
git clone https://github.com/NCAR/wrf_hydro_nwm_public.git
cd wrf_hydro_nwm_public
mkdir -p build
cd build
# Run CMake configuration for WRF-Hydro with specified options
cmake .. -DSPATIAL_SOIL=1 -DWRF_HYDRO=1 -DWRF_HYDRO_NUDGING=1 -DWRFIO_NCD_LARGE_FILE_SUPPORT=1 -DCMAKE_Fortran_COMPILER=gfortran
# Compile using specified CPU settings
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make.log
# Check if the necessary executable files were created
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
# Function to rerun compilation if files are missing
rebuild_and_check() {
echo "Missing one or more expected files. Running compiler again..."
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build"
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make2.log
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
}
# IF statement to check that all expected files were created
if ((n == 2));
then
echo "All expected files created."
else
rebuild_and_check
if ((n != 2));
then
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance. Press 'Enter' to exit the script."
exit 1
else
echo "All expected files created after re-compiling."
fi
fi
# Finish the script with a pause
read -r -t 5 -p "Finished installing WRF Hydro Basecode. Waiting for 5 seconds..."
######################### Testing WRF HYDRO Compliation #########################
cd "${WRF_FOLDER}"/
mkdir -p "${WRF_FOLDER}"/domain/NWM
# Copy the *.TBL files to the NWM directory.
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/*.TBL domain/NWM
# Copy the wrf_hydro.exe file to the NWM directory.
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/wrf_hydro.exe domain/NWM
# Download test case for WRF HYDRO and move to NWM
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/NCAR/wrf_hydro_nwm_public/releases/download/v5.3.0/croton_NY_training_example_v5.2.tar.gz
tar -xzvf croton_NY_training_example_v5.2.tar.gz
cp -r example_case/FORCING "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/DOMAIN "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/RESTART "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/nudgingTimeSliceObs "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/referenceSim "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/namelist.hrldas "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/hydro.namelist "${WRF_FOLDER}"/domain/NWM
#Run Croton NY Test Case
cd "${WRF_FOLDER}"/domain/NWM
./wrf_hydro.exe
ls -lah HYDRO_RST*
echo "IF HYDRO_RST files exist and have data then wrf_hydro.exe sucessful"
echo " "
########################### Test script for output data  ###################################
# Installing Miniconda3 to WRF directory and updating libraries
echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
if [ "$Ubuntu_32bit_GNU" = "1" ];
then
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86.sh -O $Miniconda_Install_DIR/miniconda.sh
else
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
fi
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
######################### Climate Data Operators ############
######################### CDO compiled via Conda ###########
####################### This is the preferred method #######
################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create --name cdo_stable -y
conda activate cdo_stable
conda install -c conda-forge cdo -y
conda update --all -y
conda deactivate
conda deactivate
conda deactivate
echo " "
################ NEEDS TO BE IN Master folder #######################
cp $HOME/weather-ai/SurfaceRunoff.py "${WRF_FOLDER}"/domain/NWM
cd "${WRF_FOLDER}"/domain/NWM
python3 SurfaceRunoff.py
okular SurfaceRunoff.pdf
echo " "
#####################################BASH Script Finished##############################
echo "WRF HYDRO Standalone sucessfully configured and compiled"
read -r -t 5 -p "Congratulations! You've successfully installed all required files to run the Weather Research Forecast Model HYDRO verison 5.2."
##########################  Export PATH and LD_LIBRARY_PATH ################################
cd $HOME
fi
if [ "$macos_64bit_GNU" = "1" ] && [ "$WRFHYDRO_STANDALONE_PICK" = "1" ] && [ "$MAC_CHIP" = "Intel" ];
then
## WRF installation with parallel process.
# Download and install required library and data files for WRF.
# Tested in macOS Ventura 13.4.1
# Tested in 64-bit
# Tested with current available libraries on 01/01/2023
# If newer libraries exist edit script paths for changes
# Estimated Run Time ~ 90 - 150 Minutes with 10mb/s downloadspeed.
# Special thanks to  Youtube's meteoadriatic and GitHub user jamal919.
#############################basic package managment############################
brew update
outdated_packages=$(brew outdated --quiet)
# List of packages to check/install
packages=(
"autoconf" "automake" "bison" "byacc" "cmake" "curl" "flex" "gcc"
"gdal" "gedit" "git" "gnu-sed" "grads" "imagemagick" "java" "ksh"
"libtool" "libxml2" "m4" "make" "python@3.12" "snapcraft" "tcsh" "wget"
"xauth" "xorgproto" "xorgrgb" "xquartz"
)
for pkg in "${packages[@]}"; do
if brew list "$pkg" &>/dev/null;
then
echo "$pkg is already installed."
if [[ $outdated_packages == *"$pkg"* ]];
then
echo "$pkg has a newer version available. Upgrading..."
brew upgrade "$pkg"
fi
else
echo "$pkg is not installed. Installing..."
brew install "$pkg"
fi
sleep 1
done
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export PATH=/usr/local/bin:$PATH
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRFHYDRO
export WRF_FOLDER=$HOME/WRFHYDRO_STANDALONE
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
echo " "
#############################Core Management####################################
export CPU_CORE=$(sysctl -n hw.ncpu) # number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))
# 1/2 of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
# then 
# If statement for low core systems 
# Forces computers to only use 1 core if there are 4 cores or less on the system
then
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
echo " "
#############################Compilers############################
# Symlink to avoid clang conflicts with compilers
# default gcc path /usr/bin/gcc
# default homebrew path /usr/local/bin
echo $PASSWD | sudo -S ln -sf /usr/local/bin/gcc-12 /usr/local/bin/gcc
echo $PASSWD | sudo -S ln -sf /usr/local/bin/g-12 /usr/local/bin/g++
echo $PASSWD | sudo -S ln -sf /usr/local/bin/gfortran-12 /usr/local/bin/gfortran
echo $PASSWD | sudo -S ln -sf /usr/local/bin/python3.12 /usr/local/bin/python3
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wall"
echo " "
# IF statement for GNU compiler issue
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "CFLAGS = $CFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib1.2.12
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS="$fallow_argument -m64" FCFLAGS="$fallow_argument -m64" 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
echo " "
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#################################### System Environment Tests ##############
mkdir -p "${WRF_FOLDER}"/Tests/Environment
mkdir -p "${WRF_FOLDER}"/Tests/Compatibility
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
echo " "
################################OpenGrADS######################################
# Verison 2.2.1 64bit of Linux
#############################################################################
if [[ $GRADS_PICK -eq 1 ]];
then
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/macOS/opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg
sudo -S installer -pkg opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg -target /Applications/OpenGrads <<<"$PASSWD"
fi
################################## GrADS ###############################
# Version  2.2.1
# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
########################################################################
if [[ $GRADS_PICK -eq 2 ]];
then
brew install grads
fi
############################# WRF HYDRO V5.3.0 #################################
# Version 5.3.0
# Standalone mode
################################################################################
# Set up NETCDF environment variables
export NETCDF_INC="$DIR/NETCDF/include"
export NETCDF_LIB="$DIR/NETCDF/lib"
# Create directories for Hydro Basecode and navigate to it
mkdir -p "${WRF_FOLDER}/Hydro-Basecode"
cd "${WRF_FOLDER}/Hydro-Basecode"
# Clone the WRF-Hydro repository and set up the build
git clone https://github.com/NCAR/wrf_hydro_nwm_public.git
cd wrf_hydro_nwm_public
mkdir -p build
cd build
# Run CMake configuration for WRF-Hydro with specified options
cmake .. -DSPATIAL_SOIL=1 -DWRF_HYDRO=1 -DWRF_HYDRO_NUDGING=1 -DWRFIO_NCD_LARGE_FILE_SUPPORT=1 -DCMAKE_Fortran_COMPILER=gfortran
# Compile using specified CPU settings
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make.log
# Check if the necessary executable files were created
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
# Function to rerun compilation if files are missing
rebuild_and_check() {
echo "Missing one or more expected files. Running compiler again..."
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build"
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make2.log
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
}
# IF statement to check that all expected files were created
if ((n == 2));
then
echo "All expected files created."
else
rebuild_and_check
if ((n != 2));
then
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance. Press 'Enter' to exit the script."
exit 1
else
echo "All expected files created after re-compiling."
fi
fi
# Finish the script with a pause
read -r -t 5 -p "Finished installing WRF Hydro Basecode. Waiting for 5 seconds..."
######################### Testing WRF HYDRO Compliation #########################
cd "${WRF_FOLDER}"/
mkdir -p "${WRF_FOLDER}"/domain/NWM
# Copy the *.TBL files to the NWM directory.
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/*.TBL domain/NWM
# Copy the wrf_hydro.exe file to the NWM directory.
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/wrf_hydro.exe domain/NWM
# Download test case for WRF HYDRO and move to NWM
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/NCAR/wrf_hydro_nwm_public/releases/download/v5.3.0/croton_NY_training_example_v5.2.tar.gz
tar -xzvf croton_NY_training_example_v5.2.tar.gz
cp -r example_case/FORCING "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/DOMAIN "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/RESTART "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/nudgingTimeSliceObs "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/referenceSim "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/namelist.hrldas "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/hydro.namelist "${WRF_FOLDER}"/domain/NWM
# Run Croton NY Test Case
cd "${WRF_FOLDER}"/domain/NWM
mpirun -np 6 ./wrf_hydro.exe
ls -lah HYDRO_RST*
echo "IF HYDRO_RST files exist and have data then wrf_hydro.exe sucessful"
echo " "
echo " "
########################### Test script for output data  ###################################
# Installing Miniconda3 to WRF directory and updating libraries
echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
echo " "
cp $HOME/weather-ai/SurfaceRunoff.py "${WRF_FOLDER}"/domain/NWM
cd "${WRF_FOLDER}"/domain/NWM
python3 SurfaceRunoff.py
open SurfaceRunoff.pdf
echo " "
echo "WRF HYDRO Standalone sucessfully configured and compiled"
echo "Congratulations! You've successfully installed all required files to run the Weather Research Forecast Model HYDRO verison 5.2."
echo "Thank you for using this script"
fi
if [ "$macos_64bit_GNU" = "1" ] && [ "$WRFHYDRO_STANDALONE_PICK" = "1" ] && [ "$MAC_CHIP" = "ARM" ];
then
## WRF installation with parallel process.
# Download and install required library and data files for WRF.
# Tested in macOS Ventura 13.4.1
# Tested in 64-bit
# Tested with current available libraries on 01/01/2023
# If newer libraries exist edit script paths for changes
# Estimated Run Time ~ 90 - 150 Minutes with 10mb/s downloadspeed.
# Special thanks to  Youtube's meteoadriatic and GitHub user jamal919.
#############################basic package managment############################
brew update
outdated_packages=$(brew outdated --quiet)
# List of packages to check/install
packages=(
"autoconf" "automake" "bison" "byacc" "cmake" "curl" "flex" "gcc"
"gdal" "gedit" "git" "gnu-sed" "grads" "imagemagick" "java" "ksh"
"libtool" "libxml2" "m4" "make" "python@3.12" "snapcraft" "tcsh" "wget"
"xauth" "xorgproto" "xorgrgb" "xquartz"
)
for pkg in "${packages[@]}"; do
if brew list "$pkg" &>/dev/null;
then
echo "$pkg is already installed."
if [[ $outdated_packages == *"$pkg"* ]];
then
echo "$pkg has a newer version available. Upgrading..."
brew upgrade "$pkg"
fi
else
echo "$pkg is not installed. Installing..."
brew install "$pkg"
fi
sleep 1
done
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
xport PATH=/usr/local/bin:$PATH
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRFHYDRO
export WRF_FOLDER=$HOME/WRFHYDRO_STANDALONE
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
echo " "
#############################Core Management####################################
export CPU_CORE=$(sysctl -n hw.ncpu) 
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))
# 1/2 of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
# then 
# If statement for low core systems
# Forces computers to only use 1 core if there are 4 cores or less on the system
then
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
echo " "
#############################Compilers############################
echo $PASSWD | sudo -S unlink /opt/homebrew/bin/gfortran
echo $PASSWD | sudo -S unlink /opt/homebrew/bin/gcc
echo $PASSWD | sudo -S unlink /opt/homebrew/bin/g++
# Source the bashrc to ensure environment variables are loaded
source ~/.bashrc
# Check current versions of gcc, g++, and gfortran (this should show no version if unlinked)
gcc --version
g++ --version
gfortran --version
# Navigate to the Homebrew binaries directory
cd /opt/homebrew/bin
# Find the latest version of GCC, G++, and GFortran
latest_gcc=$(ls gcc-* 2>/dev/null | grep -o 'gcc-[0-9]*' | sort -V | tail -n 1)
latest_gpp=$(ls g++-* 2>/dev/null | grep -o 'g++-[0-9]*' | sort -V | tail -n 1)
latest_gfortran=$(ls gfortran-* 2>/dev/null | grep -o 'gfortran-[0-9]*' | sort -V | tail -n 1)
# Check if the latest versions were found, and link them
if [ -n "$latest_gcc" ];
then
echo "Linking the latest GCC version: $latest_gcc"
echo $PASSWD | sudo -S ln -sf $latest_gcc gcc
else
echo "No GCC version found."
fi
if [ -n "$latest_gpp" ];
then
echo "Linking the latest G++ version: $latest_gpp"
echo $PASSWD | sudo -S ln -sf $latest_gpp g++
else
echo "No G++ version found."
fi
if [ -n "$latest_gfortran" ];
then
echo "Linking the latest GFortran version: $latest_gfortran"
echo $PASSWD | sudo -S ln -sf $latest_gfortran gfortran
else
echo "No GFortran version found."
fi
# Return to the home directory
cd
# Source bashrc and bash_profile to reload the environment settings
source ~/.bashrc
source ~/.bash_profile
# Check if the versions were successfully updated
gcc --version
g++ --version
gfortran --version
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wall"
echo " "
# IF statement for GNU compiler issue
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "CFLAGS = $CFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib1.2.12
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS="$fallow_argument -m64" FCFLAGS="$fallow_argument -m64" 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
echo " "
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#################################### System Environment Tests ##############
mkdir -p "${WRF_FOLDER}"/Tests/Environment
mkdir -p "${WRF_FOLDER}"/Tests/Compatibility
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
echo " "
################################OpenGrADS######################################
# Verison 2.2.1 64bit of Linux
#############################################################################
if [[ $GRADS_PICK -eq 1 ]];
then
cd "${WRF_FOLDER}"/Downloads
wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/macOS/opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg
sudo -S installer -pkg opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg -target /Applications/OpenGrads <<<"$PASSWD"
fi
################################## GrADS ###############################
# Version  2.2.1
# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
########################################################################
if [[ $GRADS_PICK -eq 2 ]];
then
brew install grads
fi
############################# WRF HYDRO V5.3.0 #################################
# Version 5.3.0
# Standalone mode
################################################################################
# Set up NETCDF environment variables
export NETCDF_INC="$DIR/NETCDF/include"
export NETCDF_LIB="$DIR/NETCDF/lib"
# Create directories for Hydro Basecode and navigate to it
mkdir -p "${WRF_FOLDER}/Hydro-Basecode"
cd "${WRF_FOLDER}/Hydro-Basecode"
# Clone the WRF-Hydro repository and set up the build
git clone https://github.com/NCAR/wrf_hydro_nwm_public.git
cd wrf_hydro_nwm_public
mkdir -p build
cd build
# Run CMake configuration for WRF-Hydro with specified options
cmake .. -DSPATIAL_SOIL=1 -DWRF_HYDRO=1 -DWRF_HYDRO_NUDGING=1 -DWRFIO_NCD_LARGE_FILE_SUPPORT=1 -DCMAKE_Fortran_COMPILER=gfortran
# Compile using specified CPU settings
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make.log
# Check if the necessary executable files were created
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
# Function to rerun compilation if files are missing
rebuild_and_check() {
echo "Missing one or more expected files. Running compiler again..."
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build"
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make2.log
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
}
# IF statement to check that all expected files were created
if ((n == 2));
then
echo "All expected files created."
else
rebuild_and_check
if ((n != 2));
then
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance. Press 'Enter' to exit the script."
exit 1
else
echo "All expected files created after re-compiling."
fi
fi
# Finish the script with a pause
read -r -t 5 -p "Finished installing WRF Hydro Basecode. Waiting for 5 seconds..."
echo " "
######################### Testing WRF HYDRO Compliation #########################
cd "${WRF_FOLDER}"/
mkdir -p "${WRF_FOLDER}"/domain/NWM
# Copy the *.TBL files to the NWM directory.
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/*.TBL domain/NWM
#Copy the wrf_hydro.exe file to the NWM directory.
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/wrf_hydro.exe domain/NWM
# Download test case for WRF HYDRO and move to NWM
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/NCAR/wrf_hydro_nwm_public/releases/download/v5.3.0/croton_NY_training_example_v5.2.tar.gz
tar -xzvf croton_NY_training_example_v5.2.tar.gz
cp -r example_case/FORCING "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/DOMAIN "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/RESTART "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/nudgingTimeSliceObs "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/referenceSim "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/namelist.hrldas "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/hydro.namelist "${WRF_FOLDER}"/domain/NWM
# Run Croton NY Test Case
cd "${WRF_FOLDER}"/domain/NWM
mpirun -np 6 ./wrf_hydro.exe
ls -lah HYDRO_RST*
echo "IF HYDRO_RST files exist and have data then wrf_hydro.exe sucessful"
echo " "
echo " "
########################### Test script for output data  ###################################
# Installing Miniconda3 to WRF directory and updating libraries
echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
echo " "
cp $HOME/weather-ai/SurfaceRunoff.py "${WRF_FOLDER}"/domain/NWM
cd "${WRF_FOLDER}"/domain/NWM
python3 SurfaceRunoff.py
open SurfaceRunoff.pdf
echo " "
echo "WRF HYDRO Standalone sucessfully configured and compiled"
echo "Congratulations! You've successfully installed all required files to run the Weather Research Forecast Model HYDRO verison 5.2."
echo "Thank you for using this script"
fi
if [ "$Ubuntu_64bit_Intel" = "1" ] && [ "$WRFHYDRO_STANDALONE_PICK" = "1" ];
then
############################# Basic package managment ############################
echo $PASSWD | sudo -S apt -y update
echo $PASSWD | sudo -S apt -y upgrade
# download the key to system keyring; this and the following echo command are
# needed in order to install the Intel compilers
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB |	gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg >/dev/null
# add signed entry to apt sources and configure the APT client to use Intel repository:
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
# this update should get the Intel package info from the Intel repository
echo $PASSWD | sudo -S apt -y update
release_version=$(lsb_release -r -s)
# Compare the release version
if [ "$release_version" = "24.04" ];
then
# Install Emacs without recommended packages
echo $PASSWD | sudo -S apt install emacs --no-install-recommends -y
else
# Attempt to install Emacs if the release version is not 24.04
echo "The release version is not 24.04, attempting to install Emacs."
echo $PASSWD | sudo -S apt install emacs -y
fi
echo $PASSWD | sudo -S apt -y install autoconf automake autotools-dev bison build-essential byacc cmake csh curl default-jdk default-jre flex libfl-dev g++ gawk gcc gfortran git ksh libcurl4-openssl-dev libjpeg-dev libncurses6 libpixman-1-dev libpng-dev libtool libxml2 libxml2-dev libxml-libxml-perl m4 make ncview okular openbox pipenv pkg-config python3 python3-dev python3-pip python3-dateutil tcsh unzip xauth xorg time
# install the Intel compilers
echo $PASSWD | sudo -S apt -y install intel-basekit
echo $PASSWD | sudo -S apt -y install intel-hpckit
echo $PASSWD | sudo -S apt -y install intel-oneapi-python
echo $PASSWD | sudo -S apt -y update
# Fix any broken installations
echo $PASSWD | sudo -S apt --fix-broken install
# make sure some critical packages have been installed
which cmake pkg-config make gcc g++ gfortran
# add the Intel compiler file paths to various environment variables
source /opt/intel/oneapi/setvars.sh --force
# some of the libraries we install below need one or more of these variables
export CC=icx
export CXX=icpx
export FC=ifx
export F77=ifx
export F90=ifx
export MPIFC=mpiifx
export MPIF77=mpiifx
export MPIF90=mpiifx
export MPICC=mpiicx
export MPICXX=mpiicpc
export CFLAGS="-fPIC -fPIE -O3 -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types -Wno-unused-command-line-argument"
############################# CPU Core Management ####################################
export CPU_CORE=$(nproc) 
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4)) 
# quarter of availble cores on system
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
# If statement for low core systems 
# Forces computers to only use 1 core if there are 4 cores or less on the system
if [ $CPU_CORE -le $CPU_6CORE ];
then
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRFHYDRO_STANDALONE_INTEL
export WRF_FOLDER=$HOME/WRFHYDRO_STANDALONE_INTEL
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
echo " "
##############################Downloading Libraries############################
cd Downloads
wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib1.2.12
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
export PHDF5=$DIR/grib2
echo " "
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
echo " "
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --with-zlib=$DIR/grib2 --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lm -lcurl -lhdf5_hl -lhdf5 -lz -ldl"
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#################################### System Environment Tests ##############
mkdir -p "${WRF_FOLDER}"/Tests/Environment
mkdir -p "${WRF_FOLDER}"/Tests/Compatibility
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
############################# WRF HYDRO V5.3.0 #################################
# Version 5.3.0
# Standalone mode
# GNU
################################################################################
# Source Intel oneAPI environment
source /opt/intel/oneapi/setvars.sh --force
# Set up NETCDF environment variables
export NETCDF_INC="$DIR/NETCDF/include"
export NETCDF_LIB="$DIR/NETCDF/lib"
# Create directories for Hydro Basecode and navigate to it
mkdir -p "${WRF_FOLDER}/Hydro-Basecode"
cd "${WRF_FOLDER}/Hydro-Basecode"
# Clone the WRF-Hydro repository and set up the build
git clone https://github.com/NCAR/wrf_hydro_nwm_public.git
cd wrf_hydro_nwm_public
mkdir -p build
cd build
# Run CMake configuration for WRF-Hydro with specified options
cmake .. -DSPATIAL_SOIL=1 -DWRF_HYDRO=1 -DWRF_HYDRO_NUDGING=1 -DWRFIO_NCD_LARGE_FILE_SUPPORT=1 -DCMAKE_Fortran_COMPILER=ifx
# Compile using specified CPU settings
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make.log
# Check if the necessary executable files were created
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
# Function to rerun compilation if files are missing
rebuild_and_check() {
echo "Missing one or more expected files. Running compiler again..."
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build"
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make2.log
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
}
# IF statement to check that all expected files were created
if ((n == 2));
then
echo "All expected files created."
else
rebuild_and_check
if ((n != 2));
then
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance. Press 'Enter' to exit the script."
exit 1
else
echo "All expected files created after re-compiling."
fi
fi
# Finish the script with a pause
read -r -t 5 -p "Finished installing WRF Hydro Basecode. Waiting for 5 seconds..."
######################### Testing WRF HYDRO Compliation #########################
cd "${WRF_FOLDER}"/
mkdir -p "${WRF_FOLDER}"/domain/NWM
# Copy the *.TBL files to the NWM directory.
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/*.TBL domain/NWM
# Copy the wrf_hydro.exe file to the NWM directory.
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/wrf_hydro.exe domain/NWM
# Download test case for WRF HYDRO and move to NWM
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/NCAR/wrf_hydro_nwm_public/releases/download/v5.3.0/croton_NY_training_example_v5.2.tar.gz
tar -xzvf croton_NY_training_example_v5.2.tar.gz
cp -r example_case/FORCING "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/DOMAIN "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/RESTART "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/nudgingTimeSliceObs "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/referenceSim "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/namelist.hrldas "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/hydro.namelist "${WRF_FOLDER}"/domain/NWM
# Run Croton NY Test Case
cd "${WRF_FOLDER}"/domain/NWM
./wrf_hydro.exe
ls -lah HYDRO_RST*
echo "IF HYDRO_RST files exist and have data then wrf_hydro.exe sucessful"
echo " "
########################### Test script for output data  ###################################
# Installing Miniconda3 to WRF directory and updating libraries
echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
echo " "
################ NEEDS TO BE IN Master folder #######################
cp $HOME/weather-ai/SurfaceRunoff.py "${WRF_FOLDER}"/domain/NWM
cd "${WRF_FOLDER}"/domain/NWM
python3 SurfaceRunoff.py
okular SurfaceRunoff.pdf
echo " "
#####################################BASH Script Finished##############################
echo "WRF HYDRO Standalone sucessfully configured and compiled"
read -r -t 5 -p "Congratulations! You've successfully installed all required files to run the Weather Research Forecast Model HYDRO verison 5.2."
##########################  Export PATH and LD_LIBRARY_PATH ################################
cd $HOME
fi
if [ "$RHL_64bit_GNU" = "1" ] && [ "$WRFHYDRO_STANDALONE_PICK" = "1" ];
then
#############################basic package managment############################
echo $PASSWD | sudo -S yum install epel-release -y
echo $PASSWD | sudo -S yum install dnf -y
echo $PASSWD | sudo -S dnf install epel-release -y
echo $PASSWD | sudo -S dnf install dnf -y
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig-devel fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk ksh libX11-devel libX11-devel libXaw libXaw-devel libXext-devel libXext-devel libXmu-devel libXrender-devel libXrender-devel libstdc++ libstdc++-devel libxml2 libxml2-devel m4 nfs-utils perl "perl(XML::LibXML)" pkgconfig pixman-devel python3 python3-devel tcsh time unzip wget
echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRFHYDRO_STANDALONE
export WRF_FOLDER=$HOME/WRFHYDRO_STANDALONE
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir WRFPLUS
mkdir WRFDA
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
echo " "
#############################Core Management####################################
export CPU_CORE=$(nproc) 
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))                
# quarter of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
# then 
# If statement for low core systems
# Forces computers to only use 1 core if there are 4 cores or less on the system
then
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
# Force use of ipv4 with -4
cd Downloads
wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
echo " "
####################################Compilers#####################################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -O3"
# IF statement for GNU compiler issue
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "CFLAGS = $CFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib$Zlib_Version
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
# F90= due to compiler issues with mpich install
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
echo " "
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#################################### System Environment Tests ##############
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
############################# WRF HYDRO V5.3.0 #################################
# Version 5.3.0
# Standalone mode
# GNU
################################################################################
# Set up NETCDF environment variables
export NETCDF_INC="$DIR/NETCDF/include"
export NETCDF_LIB="$DIR/NETCDF/lib"
# Create directories for Hydro Basecode and navigate to it
mkdir -p "${WRF_FOLDER}/Hydro-Basecode"
cd "${WRF_FOLDER}/Hydro-Basecode"
# Clone the WRF-Hydro repository and set up the build
git clone https://github.com/NCAR/wrf_hydro_nwm_public.git
cd wrf_hydro_nwm_public
mkdir -p build
cd build
# Run CMake configuration for WRF-Hydro with specified options
cmake .. -DSPATIAL_SOIL=1 -DWRF_HYDRO=1 -DWRF_HYDRO_NUDGING=1 -DWRFIO_NCD_LARGE_FILE_SUPPORT=1 -DCMAKE_Fortran_COMPILER=gfortran
# Compile using specified CPU settings
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make.log
# Check if the necessary executable files were created
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
# Function to rerun compilation if files are missing
rebuild_and_check() {
echo "Missing one or more expected files. Running compiler again..."
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build"
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make2.log
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
}
# IF statement to check that all expected files were created
if ((n == 2));
then
echo "All expected files created."
else
rebuild_and_check
if ((n != 2));
then
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance. Press 'Enter' to exit the script."
exit 1
else
echo "All expected files created after re-compiling."
fi
fi
# Finish the script with a pause
read -r -t 5 -p "Finished installing WRF Hydro Basecode. Waiting for 5 seconds..."
######################### Testing WRF HYDRO Compliation #########################
cd "${WRF_FOLDER}"/
mkdir -p "${WRF_FOLDER}"/domain/NWM
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/*.TBL domain/NWM #Copy the *.TBL files to the NWM directory.
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/wrf_hydro.exe domain/NWM #Copy the wrf_hydro.exe file to the NWM directory.
# Download test case for WRF HYDRO and move to NWM
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/NCAR/wrf_hydro_nwm_public/releases/download/v5.3.0/croton_NY_training_example_v5.2.tar.gz
tar -xzvf croton_NY_training_example_v5.2.tar.gz
cp -r example_case/FORCING "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/DOMAIN "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/RESTART "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/nudgingTimeSliceObs "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/referenceSim "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/namelist.hrldas "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/hydro.namelist "${WRF_FOLDER}"/domain/NWM
# Run Croton NY Test Case
cd "${WRF_FOLDER}"/domain/NWM
./wrf_hydro.exe
ls -lah HYDRO_RST*
echo "IF HYDRO_RST files exist and have data then wrf_hydro.exe sucessful"
echo " "
# Installing Miniconda3 to WRF directory and updating libraries
echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
echo " "
################ NEEDS TO BE IN Master folder #######################
cp $HOME/weather-ai/SurfaceRunoff.py "${WRF_FOLDER}"/domain/NWM
cd "${WRF_FOLDER}"/domain/NWM
python3 SurfaceRunoff.py
envince SurfaceRunoff.pdf
echo " "
#####################################BASH Script Finished##############################
echo "WRF HYDRO Standalone sucessfully configured and compiled"
read -r -t 5 -p "Congratulations! You've successfully installed all required files to run the Weather Research Forecast Model HYDRO verison 5.2."
##########################  Export PATH and LD_LIBRARY_PATH ################################
cd $HOME
fi
if [ "$RHL_64bit_GNU" = "2" ] && [ "$WRFHYDRO_STANDALONE_PICK" = "1" ];
then
#############################basic package managment############################
echo "old version of GNU detected"
echo $PASSWD | sudo -S yum install RHL-release-scl -y
echo $PASSWD | sudo -S yum clean all
echo $PASSWD | sudo -S yum remove devtoolset-11*
echo $PASSWD | sudo -S yum install devtoolset-11
echo $PASSWD | sudo -S yum install devtoolset-11-\* -y
source /opt/rh/devtoolset-11/enable
gcc --version
echo $PASSWD | sudo -S yum install epel-release -y
echo $PASSWD | sudo -S yum install dnf -y
echo $PASSWD | sudo -S dnf install epel-release -y
echo $PASSWD | sudo -S dnf install dnf -y
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig-devel fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk ksh libX11-devel libX11-devel libXaw libXaw-devel libXext-devel libXext-devel libXmu-devel libXrender-devel libXrender-devel libstdc++ libstdc++-devel libxml2 libxml2-devel m4 nfs-utils perl "perl(XML::LibXML)" pkgconfig pixman-devel python3 python3-devel tcsh time unzip wget
echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
echo $PASSWD | sudo -S dnf -y update
echo $PASSWD | sudo -S dnf -y upgrade
echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
mkdir $HOME/WRFHYDRO_STANDALONE
export WRF_FOLDER=$HOME/WRFHYDRO_STANDALONE
cd "${WRF_FOLDER}"/
mkdir Downloads
mkdir WRFPLUS
mkdir WRFDA
mkdir Libs
export DIR="${WRF_FOLDER}"/Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH
mkdir -p Tests/Environment
mkdir -p Tests/Compatibility
echo " "
#############################Core Management####################################
export CPU_CORE=$(nproc) 
# number of available threads on system
export CPU_6CORE="6"
export CPU_QUARTER=$(($CPU_CORE / 4))                    
# quarter of availble cores on system
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) 
# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
if [ $CPU_CORE -le $CPU_6CORE ];
# then
# If statement for low core systems
# Forces computers to only use 1 core if there are 4 cores or less on the system
then
export CPU_QUARTER_EVEN="2"
else
export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
fi
echo "##########################################"
echo "Number of Threads being used $CPU_QUARTER_EVEN"
echo "##########################################"
echo " "
##############################Downloading Libraries############################
# Force use of ipv4 with -4
cd Downloads
wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
echo " "
####################################Compilers#####################################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export CFLAGS="-fPIC -fPIE -O3"
# IF statement for GNU compiler issue
export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
export version_10="10"
if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
then
export fallow_argument=-fallow-argument-mismatch
export boz_argument=-fallow-invalid-boz
else
export fallow_argument=
export boz_argument=
fi
export FFLAGS="$fallow_argument -m64"
export FCFLAGS="$fallow_argument -m64"
echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "CFLAGS = $CFLAGS"
echo "##########################################"
echo " "
#############################zlib############################
# Uncalling compilers due to comfigure issue with zlib$Zlib_Version
# With CC & CXX definied ./configure uses different compiler Flags
cd "${WRF_FOLDER}"/Downloads
tar -xvzf zlib-$Zlib_Version.tar.gz
cd zlib-$Zlib_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
##############################MPICH############################
# F90= due to compiler issues with mpich install
cd "${WRF_FOLDER}"/Downloads
tar -xvzf mpich-$Mpich_Version.tar.gz
cd mpich-$Mpich_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/MPICH/bin:$PATH
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
echo " "
#############################libpng############################
cd "${WRF_FOLDER}"/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-$Libpng_Version.tar.gz
cd libpng-$Libpng_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#############################JasPer############################
cd "${WRF_FOLDER}"/Downloads
unzip jasper-$Jasper_Version.zip
cd jasper-$Jasper_Version/
autoreconf -i -f 2>&1 | tee autoreconf.log
./configure --prefix=$DIR/grib2
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo " "
#############################hdf5 library for netcdf4 functionality############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
cd hdf5-$HDF5_Version-$HDF5_Sub_Version
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export HDF5=$DIR/grib2
export PHDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
echo " "
#############################Install Parallel-netCDF##############################
# Make file created with half of available cpu cores
# Hard path for MPI added
##################################################################################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
cd pnetcdf-$Pnetcdf_Version
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PNETCDF=$DIR/grib2
echo " "
##############################Install NETCDF C Library############################
cd "${WRF_FOLDER}"/Downloads
tar -xzvf v$Netcdf_C_Version.tar.gz
cd netcdf-c-$Netcdf_C_Version/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF
echo " "
##############################NetCDF fortran library############################
cd "${WRF_FOLDER}"/Downloads
tar -xvzf v$Netcdf_Fortran_Version.tar.gz
cd netcdf-fortran-$Netcdf_Fortran_Version/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
autoreconf -i -f 2>&1 | tee autoreconf.log
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
automake -a -f 2>&1 | tee automake.log
make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
echo " "
#################################### System Environment Tests ##############
cd "${WRF_FOLDER}"/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
export one="1"
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Environment
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Environment Testing "
echo "Test 1"
$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 1 Passed"
else
echo "Environment Compiler Test 1 Failed"
# exit
fi
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 2 Passed"
else
echo "Environment Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 3"
$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 3 Passed"
else
echo "Environment Compiler Test 3 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 4"
$CC -c -m64 TEST_4_fortran+c_c.c
$FC -c -m64 TEST_4_fortran+c_f.f90
$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Enviroment Test 4 Passed"
else
echo "Environment Compiler Test 4 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
############## Testing Environment #####
cd "${WRF_FOLDER}"/Tests/Compatibility
cp ${NETCDF}/include/netcdf.inc .
echo " "
echo " "
echo "Library Compatibility Tests "
echo "Test 1"
$FC -c 01_fortran+c+netcdf_f.f
$CC -c 01_fortran+c+netcdf_c.c
$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 1 Passed"
else
echo "Compatibility Compiler Test 1 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo "Test 2"
$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
$MPICC -c 02_fortran+c+netcdf+mpi_c.c
$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
if [ $TEST_PASS -ge 1 ];
then
echo "Compatibility Test 2 Passed"
else
echo "Compatibility Compiler Test 2 Failed"
# exit
fi
echo " "
read -r -t 3 -p "I am going to wait for 3 seconds only ..."
echo " "
echo " All tests completed and passed"
echo " "
############################# WRF HYDRO V5.3.0 #################################
# Version 5.3.0
# Standalone mode
# GNU
################################################################################
# Set up NETCDF environment variables
export NETCDF_INC="$DIR/NETCDF/include"
export NETCDF_LIB="$DIR/NETCDF/lib"
# Create directories for Hydro Basecode and navigate to it
mkdir -p "${WRF_FOLDER}/Hydro-Basecode"
cd "${WRF_FOLDER}/Hydro-Basecode"
# Clone the WRF-Hydro repository and set up the build
git clone https://github.com/NCAR/wrf_hydro_nwm_public.git
cd wrf_hydro_nwm_public
mkdir -p build
cd build
# Run CMake configuration for WRF-Hydro with specified options
cmake .. -DSPATIAL_SOIL=1 -DWRF_HYDRO=1 -DWRF_HYDRO_NUDGING=1 -DWRFIO_NCD_LARGE_FILE_SUPPORT=1 -DCMAKE_Fortran_COMPILER=gfortran
# Compile using specified CPU settings
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make.log
# Check if the necessary executable files were created
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
# Function to rerun compilation if files are missing
rebuild_and_check() {
echo "Missing one or more expected files. Running compiler again..."
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build"
make -j "$CPU_QUARTER_EVEN" 2>&1 | tee make2.log
cd "${WRF_FOLDER}/Hydro-Basecode/wrf_hydro_nwm_public/build/Run"
n=$(ls ./*.exe 2>/dev/null | wc -l)
}
# IF statement to check that all expected files were created
if ((n == 2));
then
echo "All expected files created."
else
rebuild_and_check
if ((n != 2));
then
echo "Missing one or more expected files. Exiting the script."
read -r -p "Please contact script authors for assistance. Press 'Enter' to exit the script."
exit 1
else
echo "All expected files created after re-compiling."
fi
fi
# Finish the script with a pause
read -r -t 5 -p "Finished installing WRF Hydro Basecode. Waiting for 5 seconds..."
######################### Testing WRF HYDRO Compliation #########################
cd "${WRF_FOLDER}"/
mkdir -p "${WRF_FOLDER}"/domain/NWM
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/*.TBL domain/NWM #Copy the *.TBL files to the NWM directory.
cp wrf_hydro_nwm_public*/trunk/NDHMS/Run/wrf_hydro.exe domain/NWM #Copy the wrf_hydro.exe file to the NWM directory.
# Download test case for WRF HYDRO and move to NWM
cd "${WRF_FOLDER}"/Downloads
wget -c https://github.com/NCAR/wrf_hydro_nwm_public/releases/download/v5.3.0/croton_NY_training_example_v5.2.tar.gz
tar -xzvf croton_NY_training_example_v5.2.tar.gz
cp -r example_case/FORCING "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/DOMAIN "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/RESTART "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/nudgingTimeSliceObs "${WRF_FOLDER}"/domain/NWM
cp -r example_case/NWM/referenceSim "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/namelist.hrldas "${WRF_FOLDER}"/domain/NWM
cp example_case/NWM/hydro.namelist "${WRF_FOLDER}"/domain/NWM
# Run Croton NY Test Case
cd "${WRF_FOLDER}"/domain/NWM
./wrf_hydro.exe
ls -lah HYDRO_RST*
echo "IF HYDRO_RST files exist and have data then wrf_hydro.exe sucessful"
echo " "
# Installing Miniconda3 to WRF directory and updating libraries
echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
mkdir -p $Miniconda_Install_DIR
wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
rm -rf $Miniconda_Install_DIR/miniconda.sh
export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
$Miniconda_Install_DIR/bin/conda init bash
$Miniconda_Install_DIR/bin/conda init zsh
$Miniconda_Install_DIR/bin/conda init tcsh
$Miniconda_Install_DIR/bin/conda init xonsh
$Miniconda_Install_DIR/bin/conda init powershell
conda config --add channels conda-forge
conda config --set auto_activate_base false
conda update -n root --all -y
##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda env create -f $HOME/weather-ai/wrf-python-stable.yml
echo " "
################ NEEDS TO BE IN Master folder #######################
cp $HOME/weather-ai/SurfaceRunoff.py "${WRF_FOLDER}"/domain/NWM
cd "${WRF_FOLDER}"/domain/NWM
python3 SurfaceRunoff.py
envince SurfaceRunoff.pdf
echo " "
#####################################BASH Script Finished##############################
echo "WRF HYDRO Standalone sucessfully configured and compiled"
read -r -t 5 -p "Congratulations! You've successfully installed all required files to run the Weather Research Forecast Model HYDRO verison 5.2."
##########################  Export PATH and LD_LIBRARY_PATH ################################
cd $HOME
fi
if [ "$Ubuntu_64bit_GNU" = "1" ] && [ "$WRFCHEM_PICK" = "1" ];
then
#############################basic package managment############################
echo $PASSWD | sudo -S apt -y update
echo $PASSWD | sudo -S apt -y upgrade
release_version=$(lsb_release -r -s)
# Compare the release version
if [ "$release_version" = "24.04" ];
then
# Install Emacs without recommended packages
echo $PASSWD | sudo -S apt install emacs --no-install-recommends -y
else
# Attempt to install Emacs if the release version is not 24.04
echo "The release version is not 24.04, attempting to install Emacs."
echo $PASSWD | sudo -S apt install emacs -y
fi
echo $PASSWD | sudo -S apt -y install autoconf automake autotools-dev bison build-essential byacc cmake csh curl default-jdk default-jre flex libfl-dev g++ gawk gcc gfortran git ksh libcurl4-openssl-dev libjpeg-dev libncurses6 libpixman-1-dev libpng-dev libtool libxml2 libxml2-dev libxml-libxml-perl m4 make ncview okular openbox pipenv pkg-config python3 python3-dev python3-pip python3-dateutil tcsh unzip xauth xorg time
echo " "
##############################Directory Listing############################
export HOME=$(
cd
pwd
)
	mkdir $HOME/WRFCHEM
	export WRF_FOLDER=$HOME/WRFCHEM
	cd "${WRF_FOLDER}"/
	mkdir Downloads
	mkdir Libs
	export DIR="${WRF_FOLDER}"/Libs
	mkdir Libs/grib2
	mkdir Libs/NETCDF
	mkdir Libs/MPICH
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility
	echo " "
	#############################Core Management####################################
	export CPU_CORE=$(nproc) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4))                          #quarter of availble cores on system
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) #Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.

	if [ $CPU_CORE -le $CPU_6CORE ]; then #If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system. then
		export CPU_QUARTER_EVEN="2"
	else
		export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi

	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"
	echo " "
	##############################Downloading Libraries############################
	cd Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
	wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz

	echo " "
	#############################Compilers############################
	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -O3 "

	#IF statement for GNU compiler issue
	export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')

	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

	export version_10="10"

	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]; then
		export fallow_argument=-fallow-argument-mismatch
		export boz_argument=-fallow-invalid-boz
	else
		export fallow_argument=
		export boz_argument=
	fi

	export FFLAGS="$fallow_argument -m64"
	export FCFLAGS="$fallow_argument -m64"

	echo "##########################################"
	echo "FFLAGS = $FFLAGS"
	echo "FCFLAGS = $FCFLAGS"
	echo "CFLAGS = $CFLAGS"
	echo "##########################################"

	echo " "
	#############################zlib############################
	#Uncalling compilers due to comfigure issue with zlib$Zlib_Version
	#With CC & CXX definied ./configure uses different compiler Flags

	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	echo " "
	##############################MPICH############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf mpich-$Mpich_Version.tar.gz
	cd mpich-$Mpich_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS="$fallow_argument -m64" FCFLAGS="$fallow_argument -m64" 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PATH=$DIR/MPICH/bin:$PATH
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx

	echo " "
	#############################libpng############################
	cd "${WRF_FOLDER}"/Downloads
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#############################JasPer############################
	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include

	echo " "
	#############################hdf5 library for netcdf4 functionality############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export HDF5=$DIR/grib2
	export PHDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH

	echo " "

	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PNETCDF=$DIR/grib2

	echo " "

	##############################Install NETCDF C Library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "
	##############################NetCDF fortran library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	echo " "
	#################################### System Environment Tests ##############

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar

	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
	export one="1"
	echo " "
	############## Testing Environment #####

	cd "${WRF_FOLDER}"/Tests/Environment
	cp ${NETCDF}/include/netcdf.inc .

	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f
	./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 1 Passed"
	else
		echo "Environment Compiler Test 1 Failed"
		exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90
	./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 2 Passed"
	else
		echo "Environment Compiler Test 2 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c
	./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 3 Passed"
	else
		echo "Environment Compiler Test 3 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o
	./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 4 Passed"
	else
		echo "Environment Compiler Test 4 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	############## Testing Environment #####

	cd "${WRF_FOLDER}"/Tests/Compatibility

	cp ${NETCDF}/include/netcdf.inc .

	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o \
		-L${NETCDF}/lib -lnetcdff -lnetcdf

	./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Compatibility Test 1 Passed"
	else
		echo "Compatibility Compiler Test 1 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "

	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o \
		02_fortran+c+netcdf+mpi_c.o \
		-L${NETCDF}/lib -lnetcdff -lnetcdf

	$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Compatibility Test 2 Passed"
	else
		echo "Compatibility Compiler Test 2 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "

	echo " All tests completed and passed"
	echo " "

	###############################NCEPlibs#####################################
	#The libraries are built and installed with
	# ./make_ncep_libs.sh -s MACHINE -c COMPILER -d NCEPLIBS_DIR -o OPENMP [-m mpi] [-a APPLICATION]
	#It is recommended to install the NCEPlibs into their own directory, which must be created before running the installer. Further information on the command line arguments can be obtained with
	# ./make_ncep_libs.sh -h

	#If iand error occurs go to https://github.com/NCAR/NCEPlibs/pull/16/files make adjustment and re-run ./make_ncep_libs.sh
	############################################################################

	cd "${WRF_FOLDER}"/Downloads
	git clone https://github.com/NCAR/NCEPlibs.git
	cd NCEPlibs
	mkdir $DIR/nceplibs

	export JASPER_INC=$DIR/grib2/include
	export PNG_INC=$DIR/grib2/include
	export NETCDF=$DIR/NETCDF

	#for loop to edit linux.gnu for nceplibs to install
	#make if statement for gcc-9 or older
	export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')

	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

	export version_10="10"

	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]; then
		sed -i "24s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "28s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "32s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "36s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "40s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "45s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "49s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "53s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "56s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "60s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "64s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "68s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "69s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "73s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "74s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
		sed -i "79s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"

	fi

	if [ ${auto_config} -eq 1 ]; then
		echo yes | ./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp
	else
		./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp
	fi

	export PATH=$DIR/nceplibs:$PATH

	echo " "
	
	######################## ARWpost V3.1  ############################
	## ARWpost
	##Configure #3
	###################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
	tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/ARWpost
	./clean -a
	sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
	export NETCDF=$DIR/NETCDF

	if [ ${auto_config} -eq 1 ]; then
		echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
	else
		./configure #Option 3 gfortran compiler with distributed memory
	fi

	export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')

	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

	export version_10="10"

	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]; then
		sed -i '32s/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4 ${fallow_argument} /g' configure.arwp
	fi

	sed -i -e 's/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	./compile

	#IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/ARWpost
	n=$(ls ./*.exe | wc -l)
	if (($n == 1)); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files. Exiting the script."
		read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
		exit
	fi

	echo " "

	export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH

	echo " "
	################################ OpenGrADS ##################################
	#Verison 2.2.1 32bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]]; then

		cd "${WRF_FOLDER}"/Downloads
		tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
		cd "${WRF_FOLDER}"/
		mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
		cd GrADS/Contents
		wget -c https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
		chmod +x g2ctl.pl
		wget -c https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
		tar -xzvf wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
		cd wgrib2-v0.1.9.4/bin
		mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
		cd "${WRF_FOLDER}"/GrADS/Contents
		rm wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
		rm -r wgrib2-v0.1.9.4

		export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH

	fi

	echo " "

	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]]; then

		echo $PASSWD | sudo -S apt -y install grads

	fi

	##################### NCAR COMMAND LANGUAGE           ##################
	########### NCL compiled via Conda                    ##################
	########### This is the preferred method by NCAR      ##################
	########### https://www.ncl.ucar.edu/index.shtml      ##################
	echo " "
	#Installing Miniconda3 to WRF directory and updating libraries
	echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd

	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3

	mkdir -p $Miniconda_Install_DIR

	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR

	rm -rf $Miniconda_Install_DIR/miniconda.sh

	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH

	source $Miniconda_Install_DIR/etc/profile.d/conda.sh

	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell

	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y

	echo " "

	echo " "
	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable

	conda deactivate
	conda deactivate
	conda deactivate

	echo " "

	############################OBSGRID###############################
	## OBSGRID
	## Downloaded from git tagged releases
	## Option #2
	########################################################################
	cd "${WRF_FOLDER}"/
	git clone https://github.com/wrf-model/OBSGRID.git
	cd "${WRF_FOLDER}"/OBSGRID

	./clean -a
	
	export DIR="${WRF_FOLDER}"/Libs
	export NETCDF=$DIR/NETCDF

	if [ ${auto_config} -eq 1 ]; then
		echo 2 | ./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	else
		./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	fi

	sed -i '27s/-lnetcdf -lnetcdff/ -lnetcdff -lnetcdf/g' configure.oa

	sed -i '31s/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo -lfontconfig -lpixman-1 -lfreetype -lhdf5 -lhdf5_hl /g' configure.oa

	sed -i '39s/-frecord-marker=4/-frecord-marker=4 ${fallow_argument} /g' configure.oa

	sed -i '44s/=	/=	${fallow_argument} /g' configure.oa

	sed -i '45s/-C -P -traditional/-P -traditional/g' configure.oa

	echo " "
	./compile 2>&1 | tee compile.obsgrid.log


	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/OBSGRID
	n=$(ls ./*.exe | wc -l)
	if (($n == 1)); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing OBSGRID. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files. Exiting the script."
		read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
		exit
	fi

	echo " "
	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml

	echo " "

	######################### Climate Data Operators ############
	######################### CDO compiled via Conda ###########
	####################### This is the preferred method #######
	################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################

	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create --name cdo_stable -y
	conda activate cdo_stable
	conda install -c conda-forge cdo -y
	conda update --all -y
	conda deactivate
	conda deactivate
	conda deactivate

	############################WRFDA 3DVAR###############################
	## WRFDA v${WPS_VERSION} 3DVAR
	## Downloaded from git tagged releases
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 34 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	mkdir -p "${WRF_FOLDER}"/WRFDA
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA

	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ]; then
		mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}

	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	cd "${WRF_FOLDER}"/WRFDA

	ulimit -s unlimited
	export WRF_CHEM=1
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1

	./clean -a

	# SED statements to fix configure error
	sed -i '186s/==/=/g' "${WRF_FOLDER}"/WRFDA/configure
	sed -i '318s/==/=/g' "${WRF_FOLDER}"/WRFDA/configure
	sed -i '919s/==/=/g' "${WRF_FOLDER}"/WRFDA/configure

	if [ ${auto_config} -eq 1 ]; then
		echo 34 | ./configure wrfda 2>&1 | tee configure.log #Option 34 for gfortran/gcc and distribunted memory
	else
		./configure wrfda 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar.log
	echo " "

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1))); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files."
		echo "Running compiler again"
		cd "${WRF_FOLDER}"/WRFDA
		./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
		cd "${WRF_FOLDER}"/WRFDA/var/da
		n=$(ls ./*.exe | wc -l)
		cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
		m=$(ls ./*.exe | wc -l)
		if ((($n == 43) && ($m == 1))); then
			echo "All expected files created."
			read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
		else
			read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
			exit
		fi
	fi

	echo " "

	############################ WRFCHEM ${WPS_VERSION} #################################
	## WRF CHEM v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 34, option 1 for gfortran and distributed memory w/basic nesting
	# If the script comes back asking to locate a file (libfl.a)
	# Use locate command to find file. in a new terminal and then copy that location
	#locate *name of file*
	#Optimization set to 0 due to buffer overflow dump
	#sed -i -e 's/="-O"/="-O0/' configure_kpp
	# io_form_boundary
	# io_form_history
	# io_form_auxinput2
	# io_form_auxhist2
	# Note that you need set nocolons = .true. in the section &time_control of namelist.input
	########################################################################
	#Setting up WRF-CHEM/KPP
	cd "${WRF_FOLDER}"/Downloads

	ulimit -s unlimited
	export WRF_EM_CORE=1
	export WRF_NMM_CORE=0
	export WRF_CHEM=1
	export WRF_KPP=1
	export YACC='/usr/bin/yacc -d'
	export FLEX=/usr/bin/flex
	export FLEX_LIB_DIR=/usr/lib/x86_64-linux-gnu/
	export KPP_HOME="${WRF_FOLDER}"/WRFV${WRF_VERSION}/chem/KPP/kpp/kpp-2.1
	export WRF_SRC_ROOT_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	export PATH=$KPP_HOME/bin:$PATH
	export SED=/usr/bin/sed
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1

	#Downloading WRF code

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/

	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ]; then
		mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}

	cd chem/KPP
	sed -i -e 's/="-O"/="-O0"/' configure_kpp
	cd -

	./clean -a

	if [ ${auto_config} -eq 1 ]; then
		sed -i '443s/.*/  $response = "34 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
		sed -i '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
		./configure 2>&1 | tee configure.log
	else
		./configure 2>&1 | tee configure.log #Option 34 gfortran compiler with distributed memory option 1 for basic nesting
	fi

	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
	./compile -j $CPU_QUARTER_EVEN emi_conv 2>&1 | tee compile.emis.log

	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3)); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files."
		echo "Running compiler again"
		cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
		./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
		cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
		n=$(ls ./*.exe | wc -l)
		if (($n >= 3)); then
			echo "All expected files created."
			read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
		else
			read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
			exit
		fi
	fi

	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}

	./clean -a

	if [ ${auto_config} -eq 1 ]; then
		echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
	else
		./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
	fi
	./compile 2>&1 | tee compile.wps.log

	echo " "

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3)); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files."
		echo "Running compiler again"
		./compile 2>&1 | tee compile.wps2.log
		cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
		n=$(ls ./*.exe | wc -l)
		if (($n == 3)); then
			echo "All expected files created."
			read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
		else
			read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
			exit
		fi
	fi

	echo " "

	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG

	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG

	if [ ${WPS_Specific_Applications} -eq 1 ]; then
		echo " "
		echo " WPS Geographical Input Data Mandatory for Specific Applications"
		echo " "
		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
		tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
		tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
		tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
		tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
		tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
		tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
		tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
		tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
		tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
		tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi

	if [ ${Optional_GEOG} -eq 1 ]; then

		echo " "
		echo "Optional WPS Geographical Input Data"
		echo " "

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
		tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
		tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
		tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
		tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
		tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
		tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	fi

fi

if [ "$Ubuntu_64bit_Intel" = "1" ] && [ "$WRFCHEM_PICK" = "1" ]; then

	############################# Basic package managment ############################

	echo $PASSWD | sudo -S apt -y update
	echo $PASSWD | sudo -S apt -y upgrade

	# download the key to system keyring; this and the following echo command are
	# needed in order to install the Intel compilers
	wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB |
		gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg >/dev/null

	# add signed entry to apt sources and configure the APT client to use Intel repository:
	echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list

	# this update should get the Intel package info from the Intel repository
	echo $PASSWD | sudo -S apt -y update

	release_version=$(lsb_release -r -s)

	# Compare the release version
	if [ "$release_version" = "24.04" ]; then
		# Install Emacs without recommended packages
		echo $PASSWD | sudo -S apt install emacs --no-install-recommends -y
	else
		# Attempt to install Emacs if the release version is not 24.04
		echo "The release version is not 24.04, attempting to install Emacs."
		echo $PASSWD | sudo -S apt install emacs -y
	fi

	echo $PASSWD | sudo -S apt -y install autoconf automake autotools-dev bison build-essential byacc cmake csh curl default-jdk default-jre flex libfl-dev g++ gawk gcc gfortran git ksh libcurl4-openssl-dev libjpeg-dev libncurses6 libpixman-1-dev libpng-dev libtool libxml2 libxml2-dev libxml-libxml-perl m4 make ncview okular openbox pipenv pkg-config python3 python3-dev python3-pip python3-dateutil tcsh unzip xauth xorg time

	# install the Intel compilers
	echo $PASSWD | sudo -S apt -y install intel-basekit
	echo $PASSWD | sudo -S apt -y install intel-hpckit
	echo $PASSWD | sudo -S apt -y install intel-oneapi-python

	echo $PASSWD | sudo -S apt -y update

	#Fix any broken installations
	echo $PASSWD | sudo -S apt --fix-broken install

	# make sure some critical packages have been installed
	which cmake pkg-config make gcc g++ gfortran

	# add the Intel compiler file paths to various environment variables
	source /opt/intel/oneapi/setvars.sh --force

	# some of the libraries we install below need one or more of these variables
	export CC=icx
	export CXX=icpx
	export FC=ifx
	export F77=ifx
	export F90=ifx
	export MPIFC=mpiifx
	export MPIF77=mpiifx
	export MPIF90=mpiifx
	export MPICC=mpiicx
	export MPICXX=mpiicpc
	export CFLAGS="-fPIC -fPIE -O3 -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types -Wno-unused-command-line-argument"
	export FFLAGS="-m64"
	export FCFLAGS="-m64"
	############################# CPU Core Management ####################################

	export CPU_CORE=$(nproc) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4)) # quarter of availble cores on system
	# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))

	# If statement for low core systems. 
	# Forces computers to only use 1 core if there are 4 cores or less on the system.
	if [ $CPU_CORE -le $CPU_6CORE ]; then
		export CPU_QUARTER_EVEN="2"
	else
		export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi

	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"

	############################## Directory Listing ############################
	# makes necessary directories
	#
	############################################################################

	export HOME=$(
		cd
		pwd
	)
	export WRF_FOLDER=$HOME/WRFCHEM_Intel
	export DIR="${WRF_FOLDER}"/Libs
	mkdir "${WRF_FOLDER}"
	cd "${WRF_FOLDER}"
	mkdir Downloads
	mkdir WRFDA
	mkdir Libs
	mkdir Libs/grib2
	mkdir Libs/NETCDF
	mkdir Libs/MPICH

	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility

	echo " "
	############################## Downloading Libraries ############################

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
	wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz

	echo " "
	############################# ZLib ############################

	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log

	echo " "
	############################# LibPNG ############################

	cd "${WRF_FOLDER}"/Downloads

	# other libraries below need these variables to be set
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include

	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log

	echo " "
	############################# JasPer ############################

	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log

	# other libraries below need these variables to be set
	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include

	echo " "
	############################# HDF5 library for NetCDF4 & parallel functionality ############################

	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log

	# other libraries below need these variables to be set
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	export PATH=$HDF5/bin:$PATH
	export PHDF5=$DIR/grib2

	echo " "

	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PNETCDF=$DIR/grib2

	echo " "

	############################## Install NETCDF-C Library ############################

	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/

	# these variables need to be set for the NetCDF-C install to work
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log

	# other libraries below need these variables to be set
	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF

	echo " "
	############################## NetCDF-Fortran library ############################

	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/

	# these variables need to be set for the NetCDF-Fortran install to work
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc"
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log

	echo " "
	#################################### System Environment Tests ##############

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar

	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility

	export one="1"
	echo " "
	############## Testing Environment #####

	cd "${WRF_FOLDER}"/Tests/Environment

	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f
	./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 1 Passed"
	else
		echo "Environment Compiler Test 1 Failed"
		exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90
	./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 2 Passed"
	else
		echo "Environment Compiler Test 2 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c
	./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 3 Passed"
	else
		echo "Environment Compiler Test 3 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o
	./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 4 Passed"
	else
		echo "Environment Compiler Test 4 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	############## Testing Environment #####

	cd "${WRF_FOLDER}"/Tests/Compatibility

	cp ${NETCDF}/include/netcdf.inc .

	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o \
		-L${NETCDF}/lib -lnetcdff -lnetcdf

	./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Compatibility Test 1 Passed"
	else
		echo "Compatibility Compiler Test 1 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "

	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o \
		02_fortran+c+netcdf+mpi_c.o \
		-L${NETCDF}/lib -lnetcdff -lnetcdf

	mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Compatibility Test 2 Passed"
	else
		echo "Compatibility Compiler Test 2 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "

	echo " All tests completed and passed"
	echo " "

	######################## ARWpost V3.1  ############################
	## ARWpost
	##Configure #3
	###################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
	tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"
	cd "${WRF_FOLDER}"/ARWpost
	./clean -a
	sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
	export NETCDF=$DIR/NETCDF

	if [ ${auto_config} -eq 1 ]; then
		echo 2 | ./configure #Option 2 intel compiler with distributed memory
	else
		./configure #Option 2 intel compiler with distributed memory
	fi

	sed -i -e '31s/ifort/ifx/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	sed -i -e '36s/gcc/icx/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	sed -i -e '38s/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	./compile

	#IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/ARWpost
	n=$(ls ./*.exe | wc -l)
	if (($n == 1)); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files. Exiting the script."
		read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
		exit
	fi

	echo " "

	export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH

	echo " "
	################################OpenGrADS######################################
	#Verison 2.2.1 64bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]]; then
		cd "${WRF_FOLDER}"/Downloads
		tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
		cd "${WRF_FOLDER}"/
		mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
		cd GrADS/Contents
		wget -c https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
		chmod +x g2ctl.pl
		wget -c https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
		tar -xzvf wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
		cd wgrib2-v0.1.9.4/bin
		mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
		cd "${WRF_FOLDER}"/GrADS/Contents
		rm wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
		rm -r wgrib2-v0.1.9.4

		export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH
	fi
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]]; then

		echo $PASSWD | sudo -S apt -y install grads

	fi

	##################### NCAR COMMAND LANGUAGE           ##################
	########### NCL compiled via Conda                    ##################
	########### This is the preferred method by NCAR      ##################
	########### https://www.ncl.ucar.edu/index.shtml      ##################
	echo " "
	#Installing Miniconda3 to WRF directory and updating libraries
	echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd

	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3

	mkdir -p $Miniconda_Install_DIR

	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR

	rm -rf $Miniconda_Install_DIR/miniconda.sh

	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH

	source $Miniconda_Install_DIR/etc/profile.d/conda.sh

	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell

	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y

	#Special Thanks to @_WaylonWalker for code development

	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable

	conda deactivate
	conda deactivate
	conda deactivate

	echo " "

	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml

	######################### Climate Data Operators ############
	######################### CDO compiled via Conda ###########
	####################### This is the preferred method #######
	################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################

	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create --name cdo_stable -y
	conda activate cdo_stable
	conda install -c conda-forge cdo -y
	conda update --all -y
	conda deactivate
	conda deactivate
	conda deactivate

	echo " "

	############################WRFDA 3DVAR###############################
	## WRFDA v${WPS_VERSION} 3DVAR
	## Downloaded from git tagged releases
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 34 for gfortran/gcc and distribunted memory
	########################################################################
	source /opt/intel/oneapi/setvars.sh --force

	cd "${WRF_FOLDER}"/Downloads
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	mkdir -p "${WRF_FOLDER}"/WRFDA
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ]; then
		mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	cd "${WRF_FOLDER}"/WRFDA

	ulimit -s unlimited
	export WRF_CHEM=1
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1

	./clean -a

	if [ ${auto_config} -eq 1 ]; then
		echo 78 | ./configure wrfda 2>&1 | tee configure.log #option 78 for intel and distribunted memory
	else
		./configure wrfda 2>&1 | tee configure.log #option 78 for intel and distribunted memory
	fi
	echo " "

	#Need to remove mpich/GNU config calls to Intel config calls
	sed -i '136s|mpif90 -f90=$(SFC)|mpiifx|g' "${WRF_FOLDER}"/WRFDA/configure.wrf
	sed -i '137s|mpicc -cc=$(SCC)|mpiicx|g' "${WRF_FOLDER}"/WRFDA/configure.wrf

	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar.log
	echo " "

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1))); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files."
		echo "Running compiler again"
		cd "${WRF_FOLDER}"/WRFDA
		./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
		cd "${WRF_FOLDER}"/WRFDA/var/da
		n=$(ls ./*.exe | wc -l)
		cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
		m=$(ls ./*.exe | wc -l)
		if ((($n == 43) && ($m == 1))); then
			echo "All expected files created."
			read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
		else
			read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
			exit
		fi
	fi
	echo " "

	############################ WRF #################################
	## WRF v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 78, option 1 for intel and distributed memory w/basic nesting
	# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
	########################################################################

	cd "${WRF_FOLDER}"/Downloads

	ulimit -s unlimited
	export WRF_EM_CORE=1
	export WRF_NMM_CORE=0
	export WRF_CHEM=1
	export WRF_KPP=1
	export YACC='/usr/bin/yacc -d'
	export FLEX=/usr/bin/flex
	export FLEX_LIB_DIR=/usr/lib/x86_64-linux-gnu/
	export KPP_HOME="${WRF_FOLDER}"/WRFV${WRF_VERSION}/chem/KPP/kpp/kpp-2.1
	export WRF_SRC_ROOT_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	export PATH=$KPP_HOME/bin:$PATH
	export SED=/usr/bin/sed
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ]; then
		mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}

	cd chem/KPP
	sed -i -e 's/="-O"/="-O0"/' configure_kpp
	cd -

	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	./clean -a

	if [ ${auto_config} -eq 1 ]; then
		sed -i '443s/.*/  $response = "78 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
		sed -i '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
		./configure 2>&1 | tee configure.log
	else
		./configure 2>&1 | tee configure.log #option 78 intel compiler with distributed memory option 1 for basic nesting
	fi

	#Need to remove mpich/GNU config calls to Intel config calls
	sed -i '136s|mpif90 -f90=$(SFC)|mpiifx|g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/configure.wrf
	sed -i '137s|mpicc -cc=$(SCC)|mpiicx|g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/configure.wrf

	./compile -j $((CPU_QUARTER_EVEN / 2)) em_real 2>&1 | tee compile.wrf1.log
	./compile -j $((CPU_QUARTER_EVEN / 2)) emi_conv 2>&1 | tee compile.emis.log

	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3)); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files."
		echo "Running compiler again"
		cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
		./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
		cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
		n=$(ls ./*.exe | wc -l)
		if (($n >= 3)); then
			echo "All expected files created."
			read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
		else
			read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
			exit
		fi
	fi

	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a

	if [ ${auto_config} -eq 1 ]; then
		echo 19 | ./configure 2>&1 | tee configure.log #Option 19 for intel and distributed memory
	else
		./configure 2>&1 | tee configure.log #Option 19 intel compiler with distributed memory
	fi

	sed -i '67s|mpif90|mpiifx|g' "${WRF_FOLDER}"/WPS-${WPS_VERSION}/configure.wps
	sed -i '68s|mpicc|mpiicx|g' "${WRF_FOLDER}"/WPS-${WPS_VERSION}/configure.wps

	./compile 2>&1 | tee compile.wps.log

	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3)); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files."
		echo "Running compiler again"
		./compile 2>&1 | tee compile.wps2.log
		cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
		n=$(ls ./*.exe | wc -l)
		if (($n == 3)); then
			echo "All expected files created."
			read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
		else
			read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
			exit
		fi
	fi

	echo " "

	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG

	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG

	if [ ${WPS_Specific_Applications} -eq 1 ]; then
		echo " "
		echo " WPS Geographical Input Data Mandatory for Specific Applications"
		echo " "

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
		tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
		tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
		tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
		tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
		tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
		tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
		tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
		tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
		tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
		tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi

	if [ ${Optional_GEOG} -eq 1 ]; then
		echo " "
		echo "Optional WPS Geographical Input Data"
		echo " "

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
		tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
		tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
		tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
		tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
		tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
		tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi

fi

if [ "$macos_64bit_GNU" = "1" ] && [ "$WRFCHEM_PICK" = "1" ] && [ "$MAC_CHIP" = "Intel" ]; then

	#############################basic package managment############################
	brew update
	outdated_packages=$(brew outdated --quiet)

	# List of packages to check/install
	packages=(
		"autoconf" "automake" "bison" "byacc" "cmake" "curl" "flex" "gcc"
		"gdal" "gedit" "git" "gnu-sed" "grads" "imagemagick" "java" "ksh"
		"libtool" "libxml2" "m4" "make" "python@3.12" "snapcraft" "tcsh" "wget"
		"xauth" "xorgproto" "xorgrgb" "xquartz"
	)

	for pkg in "${packages[@]}"; do
		if brew list "$pkg" &>/dev/null; then
			echo "$pkg is already installed."
			if [[ $outdated_packages == *"$pkg"* ]]; then
				echo "$pkg has a newer version available. Upgrading..."
				brew upgrade "$pkg"
			fi
		else
			echo "$pkg is not installed. Installing..."
			brew install "$pkg"
		fi
		sleep 1
	done

	export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
	export PATH=/usr/local/bin:$PATH

	##############################Directory Listing############################

	export HOME=$(
		cd
		pwd
	)
	mkdir $HOME/WRFCHEM
	export WRF_FOLDER=$HOME/WRFCHEM
	cd "${WRF_FOLDER}"/
	mkdir Downloads
	mkdir WRFDA
	mkdir Libs
	export DIR="${WRF_FOLDER}"/Libs
	mkdir -p Libs/grib2
	mkdir -p Libs/NETCDF
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility

	#############################Core Management####################################
	export CPU_CORE=$(sysctl -n hw.ncpu) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4))
	#1/2 of availble cores on system
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	#Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.

	if [ $CPU_CORE -le $CPU_6CORE ]; then #If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system. then
		export CPU_QUARTER_EVEN="2"
	else
		export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi

	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"
	echo " "

	##############################Downloading Libraries############################

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz

	echo " "

	#############################Compilers############################

	#Symlink to avoid clang conflicts with compilers
	#default gcc path /usr/bin/gcc
	#default homebrew path /usr/local/bin

	# Find the highest version of GCC in /usr/local/bin
		latest_gcc=$(ls /usr/local/bin/gcc-* 2>/dev/null | grep -o 'gcc-[0-9]*' | sort -V | tail -n 1)
	latest_gpp=$(ls /usr/local/bin/g++-* 2>/dev/null | grep -o 'g++-[0-9]*' | sort -V | tail -n 1)
	latest_gfortran=$(ls /usr/local/bin/gfortran-* 2>/dev/null | grep -o 'gfortran-[0-9]*' | sort -V | tail -n 1)

	# Display the chosen versions
	echo "Selected gcc version: $latest_gcc"
	echo "Selected g++ version: $latest_gpp"
	echo "Selected gfortran version: $latest_gfortran"

	# Check if GCC, G++, and GFortran were found
	if [ -z "$latest_gcc" ]; then
		echo "No GCC version found in /usr/local/bin."
		exit 1
	fi

	# Create or update the symbolic links for GCC, G++, and GFortran
	echo "Linking the latest GCC version: $latest_gcc"
	echo $PASSWD | sudo -S ln -sf /usr/local/bin/$latest_gcc /usr/local/bin/gcc

	if [ ! -z "$latest_gpp" ]; then
		echo "Linking the latest G++ version: $latest_gpp"
		echo $PASSWD | sudo -S ln -sf /usr/local/bin/$latest_gpp /usr/local/bin/g++
	fi

	if [ ! -z "$latest_gfortran" ]; then
		echo "Linking the latest GFortran version: $latest_gfortran"
		echo $PASSWD | sudo -S ln -sf /usr/local/bin/$latest_gfortran /usr/local/bin/gfortran
	fi

	echo "Updated symbolic links for GCC, G++, and GFortran."
	echo $PASSWD | sudo -S ln -sf /usr/local/bin/python3.12 /usr/local/bin/python3

	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wall"

	echo " "

	#IF statement for GNU compiler issue
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')

	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

	export version_10="10"

	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]; then
		export fallow_argument=-fallow-argument-mismatch
		export boz_argument=-fallow-invalid-boz
	else
		export fallow_argument=
		export boz_argument=
	fi

	export FFLAGS="$fallow_argument -m64"
	export FCFLAGS="$fallow_argument -m64"

	echo "##########################################"
	echo "FFLAGS = $FFLAGS"
	echo "FCFLAGS = $FCFLAGS"
	echo "CFLAGS = $CFLAGS"
	echo "##########################################"

	echo " "

	#############################zlib############################
	#Uncalling compilers due to comfigure issue with zlib1.2.12
	#With CC & CXX definied ./configure uses different compiler Flags

	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	echo " "

	##############################MPICH############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf mpich-$Mpich_Version.tar.gz
	cd mpich-$Mpich_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS="$fallow_argument -m64" FCFLAGS="$fallow_argument -m64" 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee install.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PATH=$DIR/MPICH/bin:$PATH
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx

	echo " "

	#############################libpng############################
	cd "${WRF_FOLDER}"/Downloads
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	#make check

	echo " "
	#############################JasPer############################

	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee install.log
	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include

	echo " "
	#############################hdf5 library for netcdf4 functionality############################

	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export HDF5=$DIR/grib2
	export PHDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH

	echo " "

	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PNETCDF=$DIR/grib2

	echo " "

	##############################Install NETCDF C Library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "

	##############################NetCDF fortran library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	echo " "

	#################################### System Environment Tests ##############
	mkdir -p "${WRF_FOLDER}"/Tests/Environment
	mkdir -p "${WRF_FOLDER}"/Tests/Compatibility

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar

	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
	export one="1"
	echo " "
	############## Testing Environment #####

	cd "${WRF_FOLDER}"/Tests/Environment

	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f
	./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 1 Passed"
	else
		echo "Environment Compiler Test 1 Failed"
		exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90
	./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 2 Passed"
	else
		echo "Environment Compiler Test 2 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c
	./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 3 Passed"
	else
		echo "Environment Compiler Test 3 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o
	./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 4 Passed"
	else
		echo "Environment Compiler Test 4 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	############## Testing Environment #####

	cd "${WRF_FOLDER}"/Tests/Compatibility

	cp ${NETCDF}/include/netcdf.inc .

	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o \
		-L${NETCDF}/lib -lnetcdff -lnetcdf

	./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Compatibility Test 1 Passed"
	else
		echo "Compatibility Compiler Test 1 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "

	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o \
		02_fortran+c+netcdf+mpi_c.o \
		-L${NETCDF}/lib -lnetcdff -lnetcdf

	$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Compatibility Test 2 Passed"
	else
		echo "Compatibility Compiler Test 2 Failed"
		exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "

	echo " All tests completed and passed"
	echo " "

	################################OpenGrADS######################################
	#Verison 2.2.1 64bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]]; then
		cd "${WRF_FOLDER}"/Downloads
		wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/macOS/opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg
		sudo -S installer -pkg opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg -target /Applications/OpenGrads <<<"$PASSWD"

	fi
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]]; then

		brew install grads

	fi

	#####################################################################
	#Installing Miniconda3 to WRF directory and updating libraries
	#####################################################################
	echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd

	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3

	mkdir -p $Miniconda_Install_DIR

	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR

	rm -rf $Miniconda_Install_DIR/miniconda.sh

	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH

	source $Miniconda_Install_DIR/etc/profile.d/conda.sh

	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell

	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y

	echo " "

	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable

	conda deactivate
	conda deactivate
	conda deactivate
	echo " "

	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml

	######################### Climate Data Operators ############
	######################### CDO compiled via Conda ###########
	####################### This is the preferred method #######
	################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################

	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create --name cdo_stable -y
	conda activate cdo_stable
	conda install -c conda-forge cdo -y
	conda update --all -y
	conda deactivate
	conda deactivate
	conda deactivate

	echo " "

	############################ WRFCHEM ${WPS_VERSION} #################################
	## WRF CHEM v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 17, option 1 for gfortran and distributed memory w/basic nesting
	# If the script comes back asking to locate a file (libfl.a)
	# Use locate command to find file. in a new terminal and then copy that location
	#locate *name of file*
	#Optimization set to 0 due to buffer overflow dump
	#sed -i -e 's/="-O"/="-O0/' configure_kpp
	########################################################################
	#Setting up WRF-CHEM/KPP
	cd "${WRF_FOLDER}"/Downloads

	ulimit -s unlimited
	export MALLOC_CHECK_=0
	export WRF_EM_CORE=1
	export WRF_NMM_CORE=0
	export WRF_CHEM=1

	export WRFIO_NCD_LARGE_FILE_SUPPORT=1

	#Downloading WRF code
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/

	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ]; then
		mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}

	./clean -a

	if [ ${auto_config} -eq 1 ]; then
		sed -i'' -e '443s/.*/  $response = "17 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
		sed -i'' -e '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
		./configure 2>&1 | tee configure.log
	else
		./configure 2>&1 | tee configure.log #Option 17 gfortran compiler with distributed memory option 1 for basic nesting
	fi

	sed -i'' -e 's/-w  -c/-w  -c -fPIC -fPIE -O3 -Wno-implicit-function-declaration/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/configure.wrf

	./compile em_real 2>&1 | tee compile.wrf.log
	./compile emi_conv 2>&1 | tee compile.emis.log

	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3)); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files."
		echo "Running compiler again"
		cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
		./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
		cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
		n=$(ls ./*.exe | wc -l)
		if (($n >= 3)); then
			echo "All expected files created."
			read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
		else
			read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
			exit
		fi
	fi

	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a

	if [ ${auto_config} -eq 1 ]; then
		echo 19 | ./configure 2>&1 | tee configure.log #Option 19 for gfortran and distributed memory
	else
		./configure 2>&1 | tee configure.log #Option 19 gfortran compiler with distributed memory
	fi

	./compile 2>&1 | tee compile.wps.log

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3)); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files."
		echo "Running compiler again"
		./compile 2>&1 | tee compile.wps2.log
		cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
		n=$(ls ./*.exe | wc -l)
		if (($n == 3)); then
			echo "All expected files created."
			read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
		else
			read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
			exit
		fi
	fi

	echo " "

	############################WRFDA 3DVAR###############################
	## WRFDA v${WPS_VERSION} 3DVAR
	## Downloaded from git tagged releases
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 34 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	mkdir -p "${WRF_FOLDER}"/WRFDA
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ]; then
		mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	cd "${WRF_FOLDER}"/WRFDA

	ulimit -s unlimited
	export WRF_CHEM=1
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1

	./clean -a

	if [ ${auto_config} -eq 1 ]; then
		echo 17 | ./configure wrfda 2>&1 | tee configure.log #Option 17 for gfortran/gcc and distribunted memory
	else
		./configure wrfda 2>&1 | tee configure.log #Option 17 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile all_wrfvar 2>&1 | tee compile.chem.wrfvar.log
	echo " "

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1))); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files."
		echo "Running compiler again"
		cd "${WRF_FOLDER}"/WRFDA
		./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
		cd "${WRF_FOLDER}"/WRFDA/var/da
		n=$(ls ./*.exe | wc -l)
		cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
		m=$(ls ./*.exe | wc -l)
		if ((($n == 43) && ($m == 1))); then
			echo "All expected files created."
			read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
		else
			read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
			exit
		fi
	fi
	echo " "

	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG

	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG

	if [ ${WPS_Specific_Applications} -eq 1 ]; then
		echo " "
		echo " WPS Geographical Input Data Mandatory for Specific Applications"
		echo " "

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
		tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
		tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
		tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
		tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
		tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
		tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
		tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
		tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
		tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
		tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	fi

	if [ ${Optional_GEOG} -eq 1 ]; then

		echo " "
		echo "Optional WPS Geographical Input Data"
		echo " "

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
		tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
		tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
		tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
		tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
		tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

		wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
		tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	fi

fi

if [ "$macos_64bit_GNU" = "1" ] && [ "$WRFCHEM_PICK" = "1" ] && [ "$MAC_CHIP" = "ARM" ]; then

	#############################basic package managment############################
	brew update
	outdated_packages=$(brew outdated --quiet)

	# List of packages to check/install
	packages=(
		"autoconf" "automake" "bison" "byacc" "cmake" "curl" "flex" "gcc"
		"gdal" "gedit" "git" "gnu-sed" "grads" "imagemagick" "java" "ksh"
		"libtool" "libxml2" "m4" "make" "python@3.12" "snapcraft" "tcsh" "wget"
		"xauth" "xorgproto" "xorgrgb" "xquartz"
	)

	for pkg in "${packages[@]}"; do
		if brew list "$pkg" &>/dev/null; then
			echo "$pkg is already installed."
			if [[ $outdated_packages == *"$pkg"* ]]; then
				echo "$pkg has a newer version available. Upgrading..."
				brew upgrade "$pkg"
			fi
		else
			echo "$pkg is not installed. Installing..."
			brew install "$pkg"
		fi
		sleep 1
	done

	export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
	export PATH=/usr/local/bin:$PATH

	##############################Directory Listing############################

	export HOME=$(
		cd
		pwd
	)
	mkdir $HOME/WRFCHEM
	export WRF_FOLDER=$HOME/WRFCHEM
	cd "${WRF_FOLDER}"/
	mkdir Downloads
	mkdir WRFDA
	mkdir Libs
	export DIR="${WRF_FOLDER}"/Libs
	mkdir -p Libs/grib2
	mkdir -p Libs/NETCDF
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility

	#############################Core Management####################################
	export CPU_CORE=$(sysctl -n hw.ncpu) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4))
	#1/2 of availble cores on system
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	#Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.

	if [ $CPU_CORE -le $CPU_6CORE ]; then #If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system. then
		export CPU_QUARTER_EVEN="2"
	else
		export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi

	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"
	echo " "

	##############################Downloading Libraries############################

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz

	echo " "

	#############################Compilers############################

	echo $PASSWD | sudo -S unlink /opt/homebrew/bin/gfortran
	echo $PASSWD | sudo -S unlink /opt/homebrew/bin/gcc
	echo $PASSWD | sudo -S unlink /opt/homebrew/bin/g++

	# Source the bashrc to ensure environment variables are loaded
	source ~/.bashrc

	# Check current versions of gcc, g++, and gfortran (this should show no version if unlinked)
	gcc --version
	g++ --version
	gfortran --version

	# Navigate to the Homebrew binaries directory
	cd /opt/homebrew/bin

	# Find the latest version of GCC, G++, and GFortran
	latest_gcc=$(ls gcc-* 2>/dev/null | grep -o 'gcc-[0-9]*' | sort -V | tail -n 1)
	latest_gpp=$(ls g++-* 2>/dev/null | grep -o 'g++-[0-9]*' | sort -V | tail -n 1)
	latest_gfortran=$(ls gfortran-* 2>/dev/null | grep -o 'gfortran-[0-9]*' | sort -V | tail -n 1)

	# Check if the latest versions were found, and link them
	if [ -n "$latest_gcc" ]; then
		echo "Linking the latest GCC version: $latest_gcc"
		echo $PASSWD | sudo -S ln -sf $latest_gcc gcc
	else
		echo "No GCC version found."
	fi

	if [ -n "$latest_gpp" ]; then
		echo "Linking the latest G++ version: $latest_gpp"
		echo $PASSWD | sudo -S ln -sf $latest_gpp g++
	else
		echo "No G++ version found."
	fi

	if [ -n "$latest_gfortran" ]; then
		echo "Linking the latest GFortran version: $latest_gfortran"
		echo $PASSWD | sudo -S ln -sf $latest_gfortran gfortran
	else
		echo "No GFortran version found."
	fi

	# Return to the home directory
	cd

	# Source bashrc and bash_profile to reload the environment settings
	source ~/.bashrc
	source ~/.bash_profile

	# Check if the versions were successfully updated
	gcc --version
	g++ --version
	gfortran --version

	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wall"

	echo " "

	#IF statement for GNU compiler issue
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')

	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

	export version_10="10"

	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]; then
		export fallow_argument=-fallow-argument-mismatch
		export boz_argument=-fallow-invalid-boz
	else
		export fallow_argument=
		export boz_argument=
	fi

	export FFLAGS="$fallow_argument -m64"
	export FCFLAGS="$fallow_argument -m64"

	echo "##########################################"
	echo "FFLAGS = $FFLAGS"
	echo "FCFLAGS = $FCFLAGS"
	echo "CFLAGS = $CFLAGS"
	echo "##########################################"

	echo " "

	#############################zlib############################
	#Uncalling compilers due to comfigure issue with zlib1.2.12
	#With CC & CXX definied ./configure uses different compiler Flags

	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	echo " "

	##############################MPICH############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf mpich-$Mpich_Version.tar.gz
	cd mpich-$Mpich_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS="$fallow_argument -m64" FCFLAGS="$fallow_argument -m64" 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee install.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PATH=$DIR/MPICH/bin:$PATH
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx

	echo " "

	#############################libpng############################
	cd "${WRF_FOLDER}"/Downloads
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	#make check

	echo " "
	#############################JasPer############################

	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee install.log
	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include

	echo " "
	#############################hdf5 library for netcdf4 functionality############################

	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export HDF5=$DIR/grib2
	export PHDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH

	echo " "

	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PNETCDF=$DIR/grib2

	echo " "

	##############################Install NETCDF C Library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "

	##############################NetCDF fortran library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	echo " "

	#################################### System Environment Tests ##############
	mkdir -p "${WRF_FOLDER}"/Tests/Environment
	mkdir -p "${WRF_FOLDER}"/Tests/Compatibility

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar

	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
	export one="1"
	echo " "
	############## Testing Environment #####

	cd "${WRF_FOLDER}"/Tests/Environment

	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then echo "Enviroment Test 1 Passed"
	else echo "Environment Compiler Test 1 Failed"
	#exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ]; then
		echo "Enviroment Test 2 Passed"
	else
		echo "Environment Compiler Test 2 Failed"
		# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c
	./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then echo "Enviroment Test 3 Passed"
	else echo "Environment Compiler Test 3 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then echo "Enviroment Test 4 Passed"
	else echo "Environment Compiler Test 4 Failed"
	#exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	############## Testing Environment #####

	cd "${WRF_FOLDER}"/Tests/Compatibility

	cp ${NETCDF}/include/netcdf.inc .

	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf	./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then echo "Compatibility Test 1 Passed"
	else echo "Compatibility Compiler Test 1 Failed"
	#exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "

	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
	$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then echo "Compatibility Test 2 Passed"
	else echo "Compatibility Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "

	echo " All tests completed and passed"
	echo " "

	################################OpenGrADS######################################
	#Verison 2.2.1 64bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]]; then
		cd "${WRF_FOLDER}"/Downloads
		wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/macOS/opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg
		sudo -S installer -pkg opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg -target /Applications/OpenGrads <<<"$PASSWD"

	fi
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]]; then

		brew install grads

	fi

	#####################################################################
	#Installing Miniconda3 to WRF directory and updating libraries
	#####################################################################
	echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd

	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3

	mkdir -p $Miniconda_Install_DIR

	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR

	rm -rf $Miniconda_Install_DIR/miniconda.sh

	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH

	source $Miniconda_Install_DIR/etc/profile.d/conda.sh

	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell

	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y

	echo " "

	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable

	conda deactivate
	conda deactivate
	conda deactivate
	echo " "

	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml

	######################### Climate Data Operators ############
	######################### CDO compiled via Conda ###########
	####################### This is the preferred method #######
	################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################

	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create --name cdo_stable -y
	conda activate cdo_stable
	conda install -c conda-forge cdo -y
	conda update --all -y
	conda deactivate
	conda deactivate
	conda deactivate

	echo " "

	############################ WRFCHEM ${WPS_VERSION} #################################
	## WRF CHEM v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 17, option 1 for gfortran and distributed memory w/basic nesting
	# If the script comes back asking to locate a file (libfl.a)
	# Use locate command to find file. in a new terminal and then copy that location
	#locate *name of file*
	#Optimization set to 0 due to buffer overflow dump
	#sed -i -e 's/="-O"/="-O0/' configure_kpp
	########################################################################
	#Setting up WRF-CHEM/KPP
	cd "${WRF_FOLDER}"/Downloads

	ulimit -s unlimited
	export MALLOC_CHECK_=0
	export WRF_EM_CORE=1
	export WRF_NMM_CORE=0
	export WRF_CHEM=1

	export WRFIO_NCD_LARGE_FILE_SUPPORT=1

	#Downloading WRF code
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/

	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ]; then
		mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}

	./clean -a

	if [ ${auto_config} -eq 1 ]; then
		sed -i'' -e '443s/.*/  $response = "17 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
		sed -i'' -e '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
		./configure 2>&1 | tee configure.log
	else
		./configure 2>&1 | tee configure.log #Option 17 gfortran compiler with distributed memory option 1 for basic nesting
	fi

	sed -i'' -e 's/-w  -c/-w  -c -fPIC -fPIE -O3 -Wno-implicit-function-declaration/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/configure.wrf

	./compile em_real 2>&1 | tee compile.wrf.log
	./compile emi_conv 2>&1 | tee compile.emis.log

	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3)); then
		echo "All expected files created."
		read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
		echo "Missing one or more expected files."
		echo "Running compiler again"
		cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
		./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
		cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
		n=$(ls ./*.exe | wc -l)
		if (($n >= 3)); then
			echo "All expected files created."
			read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
		else
			read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
			exit
		fi
	fi

	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a

	if [ ${auto_config} -eq 1 ];
	then echo 19 | ./configure 2>&1 | tee configure.log #Option 19 for gfortran and distributed memory
	else ./configure 2>&1 | tee configure.log #Option 19 gfortran compiler with distributed memory
	fi
	./compile 2>&1 | tee compile.wps.log

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	./compile 2>&1 | tee compile.wps2.log
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	#exit
	fi
	fi

	echo " "

	############################WRFDA 3DVAR###############################
	## WRFDA v${WPS_VERSION} 3DVAR
	## Downloaded from git tagged releases
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 34 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	mkdir -p "${WRF_FOLDER}"/WRFDA
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	cd "${WRF_FOLDER}"/WRFDA

	ulimit -s unlimited
	export WRF_CHEM=1
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1

	./clean -a

	if [ ${auto_config} -eq 1 ];
	then
	echo 17 | ./configure wrfda 2>&1 | tee configure.log #Option 17 for gfortran/gcc and distribunted memory
	else
	./configure wrfda 2>&1 | tee configure.log #Option 17 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile all_wrfvar 2>&1 | tee compile.chem.wrfvar.log
	echo " "

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFDA
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "

	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG

	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG

	if [ ${WPS_Specific_Applications} -eq 1 ];
	then
	echo " "
	echo " WPS Geographical Input Data Mandatory for Specific Applications"
	echo " "

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
	tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
	tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
	tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
	tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
	tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
	tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
	tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
	tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
	tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
	tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	fi

	if [ ${Optional_GEOG} -eq 1 ];
	then

	echo " "
	echo "Optional WPS Geographical Input Data"
	echo " "

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
	tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
	tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
	tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
	tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
	tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
	tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG

	fi

fi

if [ "$RHL_64bit_GNU" = "1" ] && [ "$WRFCHEM_PICK" = "1" ]; then

	#############################basic package managment############################
	echo $PASSWD | sudo -S yum install epel-release -y
	echo $PASSWD | sudo -S yum install dnf -y
	echo $PASSWD | sudo -S dnf install epel-release -y
	echo $PASSWD | sudo -S dnf install dnf -y
	echo $PASSWD | sudo -S dnf -y update
	echo $PASSWD | sudo -S dnf -y upgrade
	echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig-devel fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk ksh libX11-devel libX11-devel libXaw libXaw-devel libXext-devel libXext-devel libXmu-devel libXrender-devel libXrender-devel libstdc++ libstdc++-devel libxml2 libxml2-devel m4 nfs-utils perl "perl(XML::LibXML)" pkgconfig pixman-devel python3 python3-devel tcsh time unzip wget
	echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
	echo $PASSWD | sudo -S dnf -y update
	echo $PASSWD | sudo -S dnf -y upgrade
	echo " "

	##############################Directory Listing############################
	export HOME=$(
		cd
		pwd
	)

	mkdir $HOME/WRFCHEM
	export WRF_FOLDER=$HOME/WRFCHEM
	cd "${WRF_FOLDER}"/
	mkdir Downloads
	mkdir WRFPLUS
	mkdir WRFDA
	mkdir Libs
	export DIR="${WRF_FOLDER}"/Libs
	mkdir Libs/grib2
	mkdir Libs/NETCDF
	mkdir Libs/MPICH
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility

	echo " "
	#############################Core Management####################################

	export CPU_CORE=$(nproc) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4)) # quarter of availble cores on system
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) #Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.

	if [ $CPU_CORE -le $CPU_6CORE ];
	# then
	# If statement for low core systems 
	# Forces computers to only use 1 core if there are 4 cores or less on the system
	then
		export CPU_QUARTER_EVEN="2"
	else
		export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi

	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"

	echo " "
	##############################Downloading Libraries############################
	#Force use of ipv4 with -4
	cd Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
	wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz

	echo " "
	####################################Compilers#####################################
	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -O3"

	#IF statement for GNU compiler issue
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')

	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

	export version_10="10"

	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	export fallow_argument=-fallow-argument-mismatch
	export boz_argument=-fallow-invalid-boz
	else
	export fallow_argument=
	export boz_argument=
	fi

	export FFLAGS="$fallow_argument -m64"
	export FCFLAGS="$fallow_argument -m64"

	echo "##########################################"
	echo "FFLAGS = $FFLAGS"
	echo "FCFLAGS = $FCFLAGS"
	echo "CFLAGS = $CFLAGS"
	echo "##########################################"

	echo " "
	#############################zlib############################
	#Uncalling compilers due to comfigure issue with zlib$Zlib_Version
	#With CC & CXX definied ./configure uses different compiler Flags

	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	echo " "
	##############################MPICH############################
	#F90= due to compiler issues with mpich install
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf mpich-$Mpich_Version.tar.gz
	cd mpich-$Mpich_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	# make check

	export PATH=$DIR/MPICH/bin:$PATH
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx

	echo " "
	#############################libpng############################
	cd "${WRF_FOLDER}"/Downloads
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#############################JasPer############################
	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log

	./configure --prefix=$DIR/grib2
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include

	echo " "
	#############################hdf5 library for netcdf4 functionality############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export HDF5=$DIR/grib2
	export PHDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH

	echo " "
	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PNETCDF=$DIR/grib2

	echo " "

	##############################Install NETCDF C Library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "
	##############################NetCDF fortran library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
	autoreconf -i -f 2>&1 | tee autoreconf.log

	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log

	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check

	echo " "
	#################################### System Environment Tests ##############

	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar

	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility

	export one="1"
	echo " "
	############## Testing Environment #####

	cd "${WRF_FOLDER}"/Tests/Environment

	cp ${NETCDF}/include/netcdf.inc .

	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 1 Passed"
	else
	echo "Environment Compiler Test 1 Failed"
	# exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 2 Passed"
	else
	echo "Environment Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 3 Passed"
	else
	echo "Environment Compiler Test 3 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 4 Passed"
	else
	echo "Environment Compiler Test 4 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Compatibility
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 1 Passed"
	else
	echo "Compatibility Compiler Test 1 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
	$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 2 Passed"
	else
	echo "Compatibility Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo " All tests completed and passed"
	echo " "
	###############################NCEPlibs#####################################
	#The libraries are built and installed with
	# ./make_ncep_libs.sh -s MACHINE -c COMPILER -d NCEPLIBS_DIR -o OPENMP [-m mpi] [-a APPLICATION]
	#It is recommended to install the NCEPlibs into their own directory, which must be created before running the installer. Further information on the command line arguments can be obtained with
	# ./make_ncep_libs.sh -h

	#If iand error occurs go to https://github.com/NCAR/NCEPlibs/pull/16/files make adjustment and re-run ./make_ncep_libs.sh
	############################################################################
	cd "${WRF_FOLDER}"/Downloads
	git clone https://github.com/NCAR/NCEPlibs.git
	cd NCEPlibs
	mkdir $DIR/nceplibs
	export JASPER_INC=$DIR/grib2/include
	export PNG_INC=$DIR/grib2/include
	export NETCDF=$DIR/NETCDF
	#for loop to edit linux.gnu for nceplibs to install
	#make if statement for gcc-9 or older
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	sed -i "24s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "28s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "32s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "36s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "40s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "45s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "49s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "53s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "56s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "60s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "64s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "68s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "69s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "73s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "74s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "79s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	fi
	if [ ${auto_config} -eq 1 ];
	then
	echo yes | ./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
	else
	./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
	fi
	export PATH=$DIR/nceplibs:$PATH
	echo " "
	######################## ARWpost V3.1  ############################
	## ARWpost
	##Configure #3
	###################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
	tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/ARWpost
	./clean -a
	sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
	else
	./configure #Option 3 gfortran compiler with distributed memory
	fi
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	sed -i '32s/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4 ${fallow_argument} /g' configure.arwp
	fi
	sed -i -e 's/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	./compile
	#IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/ARWpost
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH
	echo " "
	################################ OpenGrADS ##################################
	#Verison 2.2.1 32bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]];
	then
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/
	mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
	cd GrADS/Contents
	wget -c https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
	chmod +x g2ctl.pl
	wget -c https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	tar -xzvf wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	cd wgrib2-v0.1.9.4/bin
	mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
	cd "${WRF_FOLDER}"/GrADS/Contents
	rm wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	rm -r wgrib2-v0.1.9.4
	export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH
	echo " "
	fi
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]];
	then
	cd "${WRF_FOLDER}"/Downloads
	wget -c ftp://cola.gmu.edu/grads/2.2/grads-2.2.1-bin-RHL7.4-x86_64.tar.gz
	tar -xzvf grads-2.2.1-bin-RHL7.4-x86_64.tar.gz -C "${WRF_FOLDER}"
	cd "${WRF_FOLDER}"/grads-2.2.1/bin
	chmod 775 *
	fi
	##################### NCAR COMMAND LANGUAGE           ##################
	########### NCL compiled via Conda                    ##################
	########### This is the preferred method by NCAR      ##################
	########### https://www.ncl.ucar.edu/index.shtml      ##################
	echo " "
	#Installing Miniconda3 to WRF directory and updating libraries
	echo $PASSWD | sudo -S dnf -y install python3-zstandard python3-zstd
	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
	mkdir -p $Miniconda_Install_DIR
	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
	rm -rf $Miniconda_Install_DIR/miniconda.sh
	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell
	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y
	echo " "
	echo " "
	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	############################OBSGRID###############################
	## OBSGRID
	## Downloaded from git tagged releases
	## Option #2
	########################################################################
	cd "${WRF_FOLDER}"/
	git clone https://github.com/wrf-model/OBSGRID.git
	cd "${WRF_FOLDER}"/OBSGRID
	./clean -a
	export DIR="${WRF_FOLDER}"/Libs
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 2 | ./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	else
	./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	fi
	sed -i '27s/-lnetcdf -lnetcdff/ -lnetcdff -lnetcdf/g' configure.oa
	sed -i '31s/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo -lfontconfig -lpixman-1 -lfreetype -lhdf5 -lhdf5_hl /g' configure.oa
	sed -i '39s/-frecord-marker=4/-frecord-marker=4 ${fallow_argument} /g' configure.oa
	sed -i '44s/=	/=	${fallow_argument} /g' configure.oa
	sed -i '45s/-C -P -traditional/-P -traditional/g' configure.oa
	echo " "
	./compile 2>&1 | tee compile.obsgrid.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/OBSGRID
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing OBSGRID. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml
	echo " "
	############################WRFDA 3DVAR###############################
	## WRFDA v${WPS_VERSION} 3DVAR
	## Downloaded from git tagged releases
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 34 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	mkdir -p "${WRF_FOLDER}"/WRFDA
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	cd "${WRF_FOLDER}"/WRFDA
	ulimit -s unlimited
	export WRF_CHEM=1
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	./clean -a
	# SED statements to fix configure error
	sed -i '186s/==/=/g' "${WRF_FOLDER}"/WRFDA/configure
	sed -i '318s/==/=/g' "${WRF_FOLDER}"/WRFDA/configure
	sed -i '919s/==/=/g' "${WRF_FOLDER}"/WRFDA/configure
	if [ ${auto_config} -eq 1 ];
	then
	echo 34 | ./configure wrfda 2>&1 | tee configure.log #Option 34 for gfortran/gcc and distribunted memory
	else
	./configure wrfda 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFDA
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################ WRFCHEM ${WPS_VERSION} #################################
	## WRF CHEM v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 34, option 1 for gfortran and distributed memory w/basic nesting
	# If the script comes back asking to locate a file (libfl.a)
	# Use locate command to find file. in a new terminal and then copy that location
	#locate *name of file*
	#Optimization set to 0 due to buffer overflow dump
	#sed -i -e 's/="-O"/="-O0/' configure_kpp
	# io_form_boundary
	# io_form_history
	# io_form_auxinput2
	# io_form_auxhist2
	# Note that you need set nocolons = .true. in the section &time_control of namelist.input
	########################################################################
	#Setting up WRF-CHEM/KPP
	cd "${WRF_FOLDER}"/Downloads
	ulimit -s unlimited
	export WRF_EM_CORE=1
	export WRF_NMM_CORE=0
	export WRF_CHEM=1
	export WRF_KPP=1
	export YACC='/usr/bin/yacc -d'
	export FLEX=/usr/bin/flex
	export FLEX_LIB_DIR=/usr/lib64
	export KPP_HOME="${WRF_FOLDER}"/WRFV${WRF_VERSION}/chem/KPP/kpp/kpp-2.1
	export WRF_SRC_ROOT_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	export PATH=$KPP_HOME/bin:$PATH
	export SED=/usr/bin/sed
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	#Downloading WRF code
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	cd chem/KPP
	sed -i -e 's/="-O"/="-O0"/' configure_kpp
	cd -
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	sed -i '443s/.*/  $response = "34 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
	sed -i '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
	./configure 2>&1 | tee configure.log
	else
	./configure 2>&1 | tee configure.log #Option 34 gfortran compiler with distributed memory option 1 for basic nesting
	fi
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
	./compile -j $CPU_QUARTER_EVEN emi_conv 2>&1 | tee compile.emis.log
	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
	else
	./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
	fi
	./compile 2>&1 | tee compile.wps.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	./compile 2>&1 | tee compile.wps2.log
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
	if [ ${WPS_Specific_Applications} -eq 1 ];
	then
	echo " "
	echo " WPS Geographical Input Data Mandatory for Specific Applications"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
	tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
	tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
	tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG/irrigation
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG/fao "${WRF_FOLDER}"/GEOG/WPS_GEOG/irrigation
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
	tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
	tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
	tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
	tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
	tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
	tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
	tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	if [ ${Optional_GEOG} -eq 1 ];
	then
	echo " "
	echo "Optional WPS Geographical Input Data"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
	tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
	tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
	tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
	tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
	tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
	tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	fi
	if [ "$RHL_64bit_GNU" = "2" ] && [ "$WRFCHEM_PICK" = "1" ];
	then
	#############################basic package managment############################
	echo "old version of GNU detected"
	echo $PASSWD | sudo -S yum install RHL-release-scl -y
	echo $PASSWD | sudo -S yum clean all
	echo $PASSWD | sudo -S yum remove devtoolset-11*
	echo $PASSWD | sudo -S yum install devtoolset-11
	echo $PASSWD | sudo -S yum install devtoolset-11-\* -y
	source /opt/rh/devtoolset-11/enable
	gcc --version
	echo $PASSWD | sudo -S yum install epel-release -y
	echo $PASSWD | sudo -S yum install dnf -y
	echo $PASSWD | sudo -S dnf install epel-release -y
	echo $PASSWD | sudo -S dnf install dnf -y
	echo $PASSWD | sudo -S dnf -y update
	echo $PASSWD | sudo -S dnf -y upgrade
	echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig-devel fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk ksh libX11-devel libX11-devel libXaw libXaw-devel libXext-devel libXext-devel libXmu-devel libXrender-devel libXrender-devel libstdc++ libstdc++-devel libxml2 libxml2-devel m4 nfs-utils perl "perl(XML::LibXML)" pkgconfig pixman-devel python3 python3-devel tcsh time unzip wget
	echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
	echo $PASSWD | sudo -S dnf -y update
	echo $PASSWD | sudo -S dnf -y upgrade
	echo " "
	##############################Directory Listing############################
	export HOME=$(
		cd
		pwd
	)
	mkdir $HOME/WRFCHEM
	export WRF_FOLDER=$HOME/WRFCHEM
	cd "${WRF_FOLDER}"/
	mkdir Downloads
	mkdir WRFPLUS
	mkdir WRFDA
	mkdir Libs
	export DIR="${WRF_FOLDER}"/Libs
	mkdir Libs/grib2
	mkdir Libs/NETCDF
	mkdir Libs/MPICH
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility
	echo " "
	#############################Core Management####################################
	export CPU_CORE=$(nproc) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4))   #quarter of availble cores on system
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) #Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.

	if [ $CPU_CORE -le $CPU_6CORE ];
	# then
	# If statement for low core systems
	# Forces computers to only use 1 core if there are 4 cores or less on the system
	then
	export CPU_QUARTER_EVEN="2"
	else
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi
	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"
	echo " "
	##############################Downloading Libraries############################
	#Force use of ipv4 with -4
	cd Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
	wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
	echo " "
	####################################Compilers#####################################
	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -O3"
	#IF statement for GNU compiler issue
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	export fallow_argument=-fallow-argument-mismatch
	export boz_argument=-fallow-invalid-boz
	else
	export fallow_argument=
	export boz_argument=
	fi
	export FFLAGS="$fallow_argument -m64"
	export FCFLAGS="$fallow_argument -m64"
	echo "##########################################"
	echo "FFLAGS = $FFLAGS"
	echo "FCFLAGS = $FCFLAGS"
	echo "CFLAGS = $CFLAGS"
	echo "##########################################"
	echo " "
	#############################zlib############################
	#Uncalling compilers due to comfigure issue with zlib$Zlib_Version
	#With CC & CXX definied ./configure uses different compiler Flags
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	##############################MPICH############################
	#F90= due to compiler issues with mpich install
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf mpich-$Mpich_Version.tar.gz
	cd mpich-$Mpich_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	# make check
	export PATH=$DIR/MPICH/bin:$PATH
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	echo " "
	#############################libpng############################
	cd "${WRF_FOLDER}"/Downloads
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#############################JasPer############################
	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include
	echo " "
	#############################hdf5 library for netcdf4 functionality############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export HDF5=$DIR/grib2
	export PHDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	echo " "
	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PNETCDF=$DIR/grib2
	echo " "
	##############################Install NETCDF C Library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "
	##############################NetCDF fortran library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#################################### System Environment Tests ##############
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
	export one="1"
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Environment
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 1 Passed"
	else
	echo "Environment Compiler Test 1 Failed"
	# exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."

	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 2 Passed"
	else
	echo "Environment Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 3 Passed"
	else
	echo "Environment Compiler Test 3 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 4 Passed"
	else
	echo "Environment Compiler Test 4 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Compatibility
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf	./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 1 Passed"
	else
	echo "Compatibility Compiler Test 1 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
	$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 2 Passed"
	else
	echo "Compatibility Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo " All tests completed and passed"
	echo " "
	###############################NCEPlibs#####################################
	# The libraries are built and installed with
	# ./make_ncep_libs.sh -s MACHINE -c COMPILER -d NCEPLIBS_DIR -o OPENMP [-m mpi] [-a APPLICATION]
	# It is recommended to install the NCEPlibs into their own directory, which must be created before running the installer.
	# Further information on the command line arguments can be obtained with
	# ./make_ncep_libs.sh -h
	# If iand error occurs go to https://github.com/NCAR/NCEPlibs/pull/16/files make adjustment and re-run ./make_ncep_libs.sh
	############################################################################
	cd "${WRF_FOLDER}"/Downloads
	git clone https://github.com/NCAR/NCEPlibs.git
	cd NCEPlibs
	mkdir $DIR/nceplibs
	export JASPER_INC=$DIR/grib2/include
	export PNG_INC=$DIR/grib2/include
	export NETCDF=$DIR/NETCDF
	#for loop to edit linux.gnu for nceplibs to install
	#make if statement for gcc-9 or older
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	sed -i "24s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "28s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "32s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "36s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "40s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "45s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "49s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "53s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "56s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "60s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "64s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "68s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "69s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "73s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "74s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "79s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	fi
	if [ ${auto_config} -eq 1 ];
	then
	echo yes | ./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
	else
	./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
	fi
	export PATH=$DIR/nceplibs:$PATH
	echo " "
	######################## ARWpost V3.1  ############################
	## ARWpost
	##Configure #3
	###################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
	tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/ARWpost
	./clean -a
	sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
	else
	./configure #Option 3 gfortran compiler with distributed memory
	fi
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	sed -i '32s/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4 ${fallow_argument} /g' configure.arwp
	fi
	sed -i -e 's/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	./compile
	#IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/ARWpost
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH
	echo " "
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]]; then
		cd "${WRF_FOLDER}"/Downloads
		wget -c ftp://cola.gmu.edu/grads/2.2/grads-2.2.1-bin-RHL7.4-x86_64.tar.gz
		tar -xzvf grads-2.2.1-bin-RHL7.4-x86_64.tar.gz -C "${WRF_FOLDER}"
		cd "${WRF_FOLDER}"/grads-2.2.1/bin
		chmod 775 *
	fi
	##################### NCAR COMMAND LANGUAGE           ##################
	########### NCL compiled via Conda                    ##################
	########### This is the preferred method by NCAR      ##################
	########### https://www.ncl.ucar.edu/index.shtml      ##################
	echo " "
	#Installing Miniconda3 to WRF directory and updating libraries
	echo $PASSWD | sudo -S dnf -y install python3-zstandard python3-zstd
	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
	mkdir -p $Miniconda_Install_DIR
	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
	rm -rf $Miniconda_Install_DIR/miniconda.sh
	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell
	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y
	echo " "
	echo " "
	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	############################OBSGRID###############################
	## OBSGRID
	## Downloaded from git tagged releases
	## Option #2
	########################################################################
	cd "${WRF_FOLDER}"/
	git clone https://github.com/wrf-model/OBSGRID.git
	cd "${WRF_FOLDER}"/OBSGRID
	./clean -a
	export DIR="${WRF_FOLDER}"/Libs
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 2 | ./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	else
	./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	fi
	sed -i '27s/-lnetcdf -lnetcdff/ -lnetcdff -lnetcdf/g' configure.oa
	sed -i '31s/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo -lfontconfig -lpixman-1 -lfreetype -lhdf5 -lhdf5_hl /g' configure.oa
	sed -i '39s/-frecord-marker=4/-frecord-marker=4 ${fallow_argument} /g' configure.oa
	sed -i '44s/=	/=	${fallow_argument} /g' configure.oa
	sed -i '45s/-C -P -traditional/-P -traditional/g' configure.oa
	echo " "
	./compile 2>&1 | tee compile.obsgrid.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/OBSGRID
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing OBSGRID. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml
	############################WRFDA 3DVAR###############################
	## WRFDA v${WPS_VERSION} 3DVAR
	## Downloaded from git tagged releases
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 34 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	mkdir -p "${WRF_FOLDER}"/WRFDA
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	cd "${WRF_FOLDER}"/WRFDA
	ulimit -s unlimited
	export WRF_CHEM=1
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	./clean -a
	# SED statements to fix configure error
	sed -i '186s/==/=/g' "${WRF_FOLDER}"/WRFDA/configure
	sed -i '318s/==/=/g' "${WRF_FOLDER}"/WRFDA/configure
	sed -i '919s/==/=/g' "${WRF_FOLDER}"/WRFDA/configure
	if [ ${auto_config} -eq 1 ];
	then
	echo 34 | ./configure wrfda 2>&1 | tee configure.log #Option 34 for gfortran/gcc and distribunted memory
	else
	./configure wrfda 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFDA
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################ WRFCHEM ${WPS_VERSION} #################################
	## WRF CHEM v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 34, option 1 for gfortran and distributed memory w/basic nesting
	# If the script comes back asking to locate a file (libfl.a)
	# Use locate command to find file. in a new terminal and then copy that location
	#locate *name of file*
	#Optimization set to 0 due to buffer overflow dump
	#sed -i -e 's/="-O"/="-O0/' configure_kpp
	# io_form_boundary
	# io_form_history
	# io_form_auxinput2
	# io_form_auxhist2
	# Note that you need set nocolons = .true. in the section &time_control of namelist.input
	########################################################################
	#Setting up WRF-CHEM/KPP
	cd "${WRF_FOLDER}"/Downloads
	ulimit -s unlimited
	export WRF_EM_CORE=1
	export WRF_NMM_CORE=0
	export WRF_CHEM=1
	export WRF_KPP=1
	export YACC='/usr/bin/yacc -d'
	export FLEX=/usr/bin/flex
	export FLEX_LIB_DIR=/usr/lib64
	export KPP_HOME="${WRF_FOLDER}"/WRFV${WRF_VERSION}/chem/KPP/kpp/kpp-2.1
	export WRF_SRC_ROOT_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	export PATH=$KPP_HOME/bin:$PATH
	export SED=/usr/bin/sed
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	#Downloading WRF code
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	cd chem/KPP
	sed -i -e 's/="-O"/="-O0"/' configure_kpp
	cd -
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	sed -i '443s/.*/  $response = "34 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
	sed -i '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
	./configure 2>&1 | tee configure.log
	else
	./configure 2>&1 | tee configure.log #Option 34 gfortran compiler with distributed memory option 1 for basic nesting
	fi
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
	./compile -j $CPU_QUARTER_EVEN emi_conv 2>&1 | tee compile.emis.log
	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
	else
	./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
	fi
	./compile
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	./compile 2>&1 | tee compile.wps2.log
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
	if [ ${WPS_Specific_Applications} -eq 1 ];
	then
	echo " "
	echo " WPS Geographical Input Data Mandatory for Specific Applications"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
	tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
	tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
	tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG/irrigation
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG/fao "${WRF_FOLDER}"/GEOG/WPS_GEOG/irrigation
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
	tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
	tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
	tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
	tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
	tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
	tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
	tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	if [ ${Optional_GEOG} -eq 1 ];
	then
	echo " "
	echo "Optional WPS Geographical Input Data"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
	tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
	tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
	tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
	tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
	tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
	tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	fi

	########################### WRF  ##########################
	## WRF installation with parallel process.
	# Download and install required library and data files for WRF, WRFPLUS, WRFDA 4DVAR, WPS.
	# Tested in Ubuntu 20.0${WPS_VERSION} LTS & Ubuntu 22.04, Rocky Linux 9 & MacOS Ventura 64bit
	# Built in 64-bit system
	# Built with Intel or GNU compilers
	# Tested with current available libraries on 10/10/2023
	# If newer libraries exist edit script paths for changes
	# Estimated Run Time ~ 90 - 150 Minutes with 10mb/s downloadspeed.
	# Special thanks to:
	# Youtube's meteoadriatic, GitHub user jamal919.
	# University of Manchester's  Doug L
	# University of Tunis El Manar's Hosni
	# GSL's Jordan S.
	# NCAR's Mary B., Christine W., & Carl D.
	# DTC's Julie P., Tara J., George M., & John H.
	# UCAR's Katelyn F., Jim B., Jordan P., Kevin M.,
	##############################################################
	if [ "$Ubuntu_64bit_GNU" = "1" ] && [ "$WRF_PICK" = "1" ];
	then
	#############################basic package managment############################
	echo $PASSWD | sudo -S apt -y update
	echo $PASSWD | sudo -S apt -y upgrade
	release_version=$(lsb_release -r -s)
	# Compare the release version
	if [ "$release_version" = "24.04" ];
	then
	# Install Emacs without recommended packages
	echo $PASSWD | sudo -S apt install emacs --no-install-recommends -y
	else
	# Attempt to install Emacs if the release version is not 24.04
	echo "The release version is not 24.04, attempting to install Emacs."
	echo $PASSWD | sudo -S apt install emacs -y
	fi
	echo $PASSWD | sudo -S apt -y install autoconf automake autotools-dev bison build-essential byacc cmake csh curl default-jdk default-jre flex libfl-dev g++ gawk gcc gfortran git ksh libcurl4-openssl-dev libjpeg-dev libncurses6 libpixman-1-dev libpng-dev libtool libxml2 libxml2-dev libxml-libxml-perl m4 make ncview okular openbox pipenv pkg-config python3 python3-dev python3-pip python3-dateutil tcsh unzip xauth xorg time
	echo " "
	##############################Directory Listing############################
	export HOME=$(
	cd
	pwd
	)
	mkdir $HOME/WRF
	export WRF_FOLDER=$HOME/WRF
	cd "${WRF_FOLDER}"/
	mkdir Downloads
	mkdir WRFPLUS
	mkdir WRFDA
	mkdir Libs
	export DIR="${WRF_FOLDER}"/Libs
	mkdir Libs/grib2
	mkdir Libs/NETCDF
	mkdir Libs/MPICH
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility
	echo " "
	#############################Core Management####################################
	export CPU_CORE=$(nproc) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4)) #quarter of availble cores on system
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) #Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
	if [ $CPU_CORE -le $CPU_6CORE ];
	# then
	# If statement for low core systems
	# Forces computers to only use 1 core if there are 4 cores or less on the system
	then
	export CPU_QUARTER_EVEN="2"
	else
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi
	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"
	echo " "
	##############################Downloading Libraries############################
	#Force use of ipv4 with -4
	cd Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
	wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
	echo " "
	####################################Compilers#####################################
	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -O3"
	#IF statement for GNU compiler issue
	export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	export fallow_argument=-fallow-argument-mismatch
	export boz_argument=-fallow-invalid-boz
	else
	export fallow_argument=
	export boz_argument=
	fi
	export FFLAGS="$fallow_argument -m64"
	export FCFLAGS="$fallow_argument -m64"
	echo "##########################################"
	echo "FFLAGS = $FFLAGS"
	echo "FCFLAGS = $FCFLAGS"
	echo "CFLAGS = $CFLAGS"
	echo "##########################################"
	echo " "
	#############################zlib############################
	#Uncalling compilers due to comfigure issue with zlib$Zlib_Version
	#With CC & CXX definied ./configure uses different compiler Flags
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	##############################MPICH############################
	#F90= due to compiler issues with mpich install
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf mpich-$Mpich_Version.tar.gz
	cd mpich-$Mpich_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	# make check
	export PATH=$DIR/MPICH/bin:$PATH
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	echo " "
	#############################libpng############################
	cd "${WRF_FOLDER}"/Downloads
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#############################JasPer############################
	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include
	echo " "
	#############################hdf5 library for netcdf4 functionality############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export HDF5=$DIR/grib2
	export PHDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	echo " "
	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PNETCDF=$DIR/grib2
	echo " "
	##############################Install NETCDF C Library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "
	##############################NetCDF fortran library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#################################### System Environment Tests ##############
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
	export one="1"
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Environment
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 1 Passed"
	else
	echo "Environment Compiler Test 1 Failed"
	# exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 2 Passed"
	else
	echo "Environment Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 3 Passed"
	else
	echo "Environment Compiler Test 3 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 4 Passed"
	else
	echo "Environment Compiler Test 4 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Compatibility
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 1 Passed"
	else
	echo "Compatibility Compiler Test 1 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
	$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 2 Passed"
	else
	echo "Compatibility Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo " All tests completed and passed"
	echo " "
	###############################NCEPlibs#####################################
	# The libraries are built and installed with
	# ./make_ncep_libs.sh -s MACHINE -c COMPILER -d NCEPLIBS_DIR -o OPENMP [-m mpi] [-a APPLICATION]
	# It is recommended to install the NCEPlibs into their own directory, which must be created before running the installer.
	# Further information on the command line arguments can be obtained with ./make_ncep_libs.sh -h
	# If iand error occurs go to https://github.com/NCAR/NCEPlibs/pull/16/files make adjustment and re-run ./make_ncep_libs.sh
	############################################################################
	cd "${WRF_FOLDER}"/Downloads
	git clone https://github.com/NCAR/NCEPlibs.git
	cd NCEPlibs
	mkdir $DIR/nceplibs
	export JASPER_INC=$DIR/grib2/include
	export PNG_INC=$DIR/grib2/include
	export NETCDF=$DIR/NETCDF
	#for loop to edit linux.gnu for nceplibs to install
	#make if statement for gcc-9 or older
	export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	sed -i "24s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "28s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "32s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "36s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "40s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "45s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "49s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "53s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "56s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "60s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "64s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "68s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "69s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "73s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "74s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "79s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	fi
	if [ ${auto_config} -eq 1 ];
	then
	echo yes | ./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp
	else
	./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp
	fi
	export PATH=$DIR/nceplibs:$PATH
	echo " "
	######################## ARWpost V3.1  ############################
	## ARWpost
	##Configure #3
	###################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
	tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/ARWpost
	./clean -a
	sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
	else
	./configure #Option 3 gfortran compiler with distributed memory
	fi
	export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	sed -i '32s/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4 ${fallow_argument} /g' configure.arwp
	fi
	sed -i -e 's/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	./compile
	#IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/ARWpost
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH
	echo " "
	################################ OpenGrADS ##################################
	#Verison 2.2.1 32bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]];
	then
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/
	mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
	cd GrADS/Contents
	wget -c https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
	chmod +x g2ctl.pl
	wget -c https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	tar -xzvf wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	cd wgrib2-v0.1.9.4/bin
	mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
	cd "${WRF_FOLDER}"/GrADS/Contents
	rm wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	rm -r wgrib2-v0.1.9.4
	export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH
	echo " "
	fi
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]];
	then
	echo $PASSWD | sudo -S apt -y install grads
	fi
	##################### NCAR COMMAND LANGUAGE           ##################
	########### NCL compiled via Conda                    ##################
	########### This is the preferred method by NCAR      ##################
	########### https://www.ncl.ucar.edu/index.shtml      ##################
	#Installing Miniconda3 to WRF-Hydro directory and updating libraries
	echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
	mkdir -p $Miniconda_Install_DIR
	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
	rm -rf $Miniconda_Install_DIR/miniconda.sh
	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell
	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y
	echo " "
	echo " "
	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	############################OBSGRID###############################
	## OBSGRID
	## Downloaded from git tagged releases
	## Option #2
	########################################################################
	cd "${WRF_FOLDER}"/
	git clone https://github.com/wrf-model/OBSGRID.git
	cd "${WRF_FOLDER}"/OBSGRID
	./clean -a
	export DIR="${WRF_FOLDER}"/Libs
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 2 | ./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	else
	./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	fi
	sed -i '27s/-lnetcdf -lnetcdff/ -lnetcdff -lnetcdf/g' configure.oa
	sed -i '31s/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo -lfontconfig -lpixman-1 -lfreetype -lhdf5 -lhdf5_hl /g' configure.oa
	sed -i '39s/-frecord-marker=4/-frecord-marker=4 ${fallow_argument} /g' configure.oa
	sed -i '44s/=	/=	${fallow_argument} /g' configure.oa
	sed -i '45s/-C -P -traditional/-P -traditional/g' configure.oa
	echo " "
	./compile 2>&1 | tee compile.obsgrid.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/OBSGRID
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing OBSGRID. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml
	######################### Climate Data Operators ############
	######################### CDO compiled via Conda ###########
	####################### This is the preferred method #######
	################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create --name cdo_stable -y
	conda activate cdo_stable
	conda install -c conda-forge cdo -y
	conda update --all -y
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	############################ WRF #################################
	## WRF v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 34, option 1 for gfortran and distributed memory w/basic nesting
	# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
	# In the namelist.input, the following settings support pNetCDF by setting value to 11:
	# io_form_boundary
	# io_form_history
	# io_form_auxinput2
	# io_form_auxhist2
	# Note that you need set nocolons = .true. in the section &time_control of namelist.input
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	sed -i '443s/.*/  $response = "34 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
	sed -i '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
	./configure 2>&1 | tee configure.log
	else
	./configure 2>&1 | tee configure.log #Option 34 gfortran compiler with distributed memory option 1 for basic nesting
	fi
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
	else
	./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
	fi
	./compile 2>&1 | tee compile.wps.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	./compile 2>&1 | tee compile.wps2.log
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFPLUS 4DVAR###############################
	## WRFPLUS v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFPLUS is built within the WRF git folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 18 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFPLUS
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFPLUS/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFPLUS/WRF "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFPLUS
	cd "${WRF_FOLDER}"/WRFPLUS
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 18 | ./configure wrfplus 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	else
	./configure wrfplus 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile -j $CPU_QUARTER_EVEN wrfplus 2>&1 | tee compile.wrfplus.log
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFPLUS/
	./compile -j $CPU_QUARTER_EVEN wrfplus 2>&1 | tee compile.wrfplus.log
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFDA 4DVAR###############################
	## WRFDA v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFDA is built within the WRFPLUS folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 18 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/WRFDA
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 18 | ./configure 4dvar 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	else
	./configure 4dvar 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile all_wrfvar 2>&1 | tee compile.wrf4dvar.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFDA
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
	if [ ${WPS_Specific_Applications} -eq 1 ];
	then
	echo " "
	echo " WPS Geographical Input Data Mandatory for Specific Applications"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
	tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
	tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
	tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
	tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
	tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
	tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
	tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
	tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
	tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
	tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	if [ ${Optional_GEOG} -eq 1 ];
	then
	echo " "
	echo "Optional WPS Geographical Input Data"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
	tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
	tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
	tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
	tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
	tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
	tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	fi
	if [ "$Ubuntu_64bit_Intel" = "1" ] && [ "$WRF_PICK" = "1" ];
	then
	############################# Basic package managment ############################
	echo $PASSWD | sudo -S apt -y update
	echo $PASSWD | sudo -S apt -y upgrade
	# download the key to system keyring; this and the following echo command are
	# needed in order to install the Intel compilers
	wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB |
		gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg >/dev/null
	# add signed entry to apt sources and configure the APT client to use Intel repository:
	echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
	# this update should get the Intel package info from the Intel repository
	echo $PASSWD | sudo -S apt -y update
	release_version=$(lsb_release -r -s)
	# Compare the release version
	if [ "$release_version" = "24.04" ];
	then
	# Install Emacs without recommended packages
	echo $PASSWD | sudo -S apt install emacs --no-install-recommends -y
	else
	# Attempt to install Emacs if the release version is not 24.04
	echo "The release version is not 24.04, attempting to install Emacs."
	echo $PASSWD | sudo -S apt install emacs -y
	fi
	echo $PASSWD | sudo -S apt -y install autoconf automake autotools-dev bison build-essential byacc cmake csh curl default-jdk default-jre flex libfl-dev g++ gawk gcc gfortran git ksh libcurl4-openssl-dev libjpeg-dev libncurses6 libpixman-1-dev libpng-dev libtool libxml2 libxml2-dev libxml-libxml-perl m4 make ncview okular openbox pipenv pkg-config python3 python3-dev python3-pip python3-dateutil tcsh unzip xauth xorg time
	# install the Intel compilers
	echo $PASSWD | sudo -S apt -y install intel-basekit
	echo $PASSWD | sudo -S apt -y install intel-hpckit
	echo $PASSWD | sudo -S apt -y install intel-oneapi-python
	echo $PASSWD | sudo -S apt -y update
	#Fix any broken installations
	echo $PASSWD | sudo -S apt --fix-broken install
	# make sure some critical packages have been installed
	which cmake pkg-config make gcc g++ gfortran
	# add the Intel compiler file paths to various environment variables
	source /opt/intel/oneapi/setvars.sh --force
	# some of the libraries we install below need one or more of these variables
	export CC=icx
	export CXX=icpx
	export FC=ifx
	export F77=ifx
	export F90=ifx
	export MPIFC=mpiifx
	export MPIF77=mpiifx
	export MPIF90=mpiifx
	export MPICC=mpiicx
	export MPICXX=mpiicpc
	export CFLAGS="-fPIC -fPIE -O3 -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types -Wno-unused-command-line-argument"
	export FFLAGS="-m64"
	export FCFLAGS="-m64"
	############################# CPU Core Management ####################################
	export CPU_CORE=$(nproc) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4)) # quarter of availble cores on system
	# Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	# If statement for low core systems 
	# Forces computers to only use 1 core if there are 4 cores or less on the system
	if [ $CPU_CORE -le $CPU_6CORE ];
	then
	export CPU_QUARTER_EVEN="2"
	else
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi
	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"
	############################## Directory Listing ############################
	# makes necessary directories
	#
	############################################################################
	export HOME=$(
	cd
	pwd
	)
	export WRF_FOLDER=$HOME/WRF_Intel
	export DIR="${WRF_FOLDER}"/Libs
	mkdir "${WRF_FOLDER}"
	cd "${WRF_FOLDER}"
	mkdir Downloads
	mkdir WRFPLUS
	mkdir WRFDA
	mkdir Libs
	mkdir Libs/grib2
	mkdir Libs/NETCDF
	mkdir Libs/MPICH
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility
	echo " "
	############################## Downloading Libraries ############################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
	wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
	echo " "
	############################# ZLib ############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	echo " "
	############################# LibPNG ############################
	cd "${WRF_FOLDER}"/Downloads
	# other libraries below need these variables to be set
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	echo " "
	############################# JasPer ############################
	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	# other libraries below need these variables to be set
	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include
	echo " "
	############################# HDF5 library for NetCDF4 & parallel functionality ############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	# other libraries below need these variables to be set
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	export PATH=$HDF5/bin:$PATH
	export PHDF5=$DIR/grib2
	echo " "
	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PNETCDF=$DIR/grib2
	echo " "
	############################## Install NETCDF-C Library ############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	# these variables need to be set for the NetCDF-C install to work
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	# other libraries below need these variables to be set
	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "
	############################## NetCDF-Fortran library ############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	# these variables need to be set for the NetCDF-Fortran install to work
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	echo " "
	#################################### System Environment Tests ##############
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
	export one="1"
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Environment
	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 1 Passed"
	else
	echo "Environment Compiler Test 1 Failed"
	# exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 2 Passed"
	else
	echo "Environment Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 3 Passed"
	else
	echo "Environment Compiler Test 3 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 4 Passed"
	else
	echo "Environment Compiler Test 4 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Compatibility
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 1 Passed"
	else
	echo "Compatibility Compiler Test 1 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
	mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 2 Passed"
	else
	echo "Compatibility Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo " All tests completed and passed"
	echo " "

	######################## ARWpost V3.1  ############################
	## ARWpost
	##Configure #3
	###################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
	tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"
	cd "${WRF_FOLDER}"/ARWpost
	./clean -a
	sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 2 | ./configure #Option 2 intel compiler with distributed memory
	else
	./configure #Option 2 intel compiler with distributed memory
	fi
	sed -i -e '31s/ifort/ifx/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	sed -i -e '36s/gcc/icx/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	sed -i -e '38s/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	./compile
	#IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/ARWpost
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH
	echo " "
	################################OpenGrADS######################################
	#Verison 2.2.1 64bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]];
	then
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/
	mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
	cd GrADS/Contents
	wget -c https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
	chmod +x g2ctl.pl
	wget -c https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
	tar -xzvf wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
	cd wgrib2-v0.1.9.4/bin
	mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
	cd "${WRF_FOLDER}"/GrADS/Contents
	rm wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
	rm -r wgrib2-v0.1.9.4
	export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH
	fi
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]];
	then
	echo $PASSWD | sudo -S apt -y install grads
	fi
	##################### NCAR COMMAND LANGUAGE           ##################
	########### NCL compiled via Conda                    ##################
	########### This is the preferred method by NCAR      ##################
	########### https://www.ncl.ucar.edu/index.shtml      ##################
	echo " "
	echo " "
	#Installing Miniconda3 to WRF directory and updating libraries
	echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
	mkdir -p $Miniconda_Install_DIR
	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
	rm -rf $Miniconda_Install_DIR/miniconda.sh
	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell
	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y
	#Special Thanks to @_WaylonWalker for code development
	echo " "
	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml
	######################### Climate Data Operators ############
	######################### CDO compiled via Conda ###########
	####################### This is the preferred method #######
	################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create --name cdo_stable -y
	conda activate cdo_stable
	conda install -c conda-forge cdo -y
	conda update --all -y
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	############################ WRF #################################
	## WRF v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 78, option 1 for intel and distributed memory w/basic nesting
	# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
	########################################################################
	source /opt/intel/oneapi/setvars.sh --force
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	sed -i '443s/.*/  $response = "78 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
	sed -i '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
	./configure 2>&1 | tee configure.log
	else
	./configure 2>&1 | tee configure.log #option 78 intel compiler with distributed memory option 1 for basic nesting
	fi
	#Need to remove mpich/GNU config calls to Intel config calls
	sed -i '136s|mpif90 -f90=$(SFC)|mpiifx|g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/configure.wrf
	sed -i '137s|mpicc -cc=$(SCC)|mpiicx|g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/configure.wrf
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 19 for gfortran and distributed memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 19 | ./configure 2>&1 | tee configure.log #Option 19 for intel and distributed memory
	else
	./configure 2>&1 | tee configure.log #Option 19 intel compiler with distributed memory
	fi
	sed -i '67s|mpif90|mpiifx|g' "${WRF_FOLDER}"/WPS-${WPS_VERSION}/configure.wps
	sed -i '68s|mpicc|mpiicx|g' "${WRF_FOLDER}"/WPS-${WPS_VERSION}/configure.wps
	./compile 2>&1 | tee compile.wps.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	./compile 2>&1 | tee compile.wps2.log
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3)); then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFPLUS 4DVAR###############################
	## WRFPLUS v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFPLUS is built within the WRF git folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 40 for intel and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/WRFPLUS
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFPLUS
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFPLUS/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFPLUS/WRF "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFPLUS
	cd "${WRF_FOLDER}"/WRFPLUS
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 40 | ./configure wrfplus 2>&1 | tee configure.log #Option 40 for intel and distribunted memory
	else
	./configure wrfplus 2>&1 | tee configure.log #Option 40 for intel and distribunted memory
	fi
	echo " "
	sed -i '136s|mpif90 -f90=$(SFC)|mpiifx|g' "${WRF_FOLDER}"/WRFPLUS/configure.wrf
	sed -i '137s|mpicc -cc=$(SCC)|mpiicx|g' "${WRF_FOLDER}"/WRFPLUS/configure.wrf
	./compile -j $CPU_QUARTER_EVEN wrfplus 2>&1 | tee wrfplus1.compile.log
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFPLUS/
	./compile -j $CPU_QUARTER_EVEN wrfplus 2>&1 | tee compile.wrfplus2.log
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFDA 4DVAR###############################
	## WRFDA v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFDA is built within the WRFPLUS folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 40 for intel and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 40 | ./configure 4dvar 2>&1 | tee configure.log #Option 40 for intel and distribunted memory
	else
	./configure 4dvar 2>&1 | tee configure.log #Option 40 for intel and distribunted memory
	fi
	echo " "
	sed -i '136s|mpif90 -f90=$(SFC)|mpiifx|g' "${WRF_FOLDER}"/WRFDA/configure.wrf
	sed -i '137s|mpicc -cc=$(SCC)|mpiicx|g' "${WRF_FOLDER}"/WRFDA/configure.wrf
	./compile all_wrfvar 2>&1 | tee wrfda.compile.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA-4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFDA
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
	if [ ${WPS_Specific_Applications} -eq 1 ];
	then
	echo " "
	echo " WPS Geographical Input Data Mandatory for Specific Applications"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
	tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
	tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
	tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
	tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
	tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
	tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
	tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
	tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
	tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
	tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	if [ ${Optional_GEOG} -eq 1 ];
	then
	echo " "
	echo "Optional WPS Geographical Input Data"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
	tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
	tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
	tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
	tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
	tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
	tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	fi
	if [ "$macos_64bit_GNU" = "1" ] && [ "$WRF_PICK" = "1" ] && [ "$MAC_CHIP" = "Intel" ];
	then
	#############################basic package managment############################
	brew update
	outdated_packages=$(brew outdated --quiet)
	# List of packages to check/install
	packages=(
	"autoconf" "automake" "bison" "byacc" "cmake" "curl" "flex" "gcc"
	"gdal" "gedit" "git" "gnu-sed" "grads" "imagemagick" "java" "ksh"
	"libtool" "libxml2" "m4" "make" "python@3.12" "snapcraft" "tcsh" "wget"
	"xauth" "xorgproto" "xorgrgb" "xquartz"
	)
	for pkg in "${packages[@]}"; do
	if brew list "$pkg" &>/dev/null;
	then
	echo "$pkg is already installed."
	if [[ $outdated_packages == *"$pkg"* ]];
	then
	echo "$pkg has a newer version available. Upgrading..."
	brew upgrade "$pkg"
	fi
	else
	echo "$pkg is not installed. Installing..."
	brew install "$pkg"
	fi
	sleep 1
	done
	export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
	export PATH=/usr/local/bin:$PATH
	##############################Directory Listing############################
	export HOME=$(
	cd
	pwd
	)
	mkdir $HOME/WRF
	export WRF_FOLDER=$HOME/WRF
	cd "${WRF_FOLDER}"/
	mkdir Downloads
	mkdir WRFPLUS
	mkdir WRFDA
	mkdir Libs
	export DIR="${WRF_FOLDER}"/Libs
	mkdir -p Libs/grib2
	mkdir -p Libs/NETCDF
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility
	#############################Core Management####################################
	export CPU_CORE=$(sysctl -n hw.ncpu) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4))
	#1/2 of availble cores on system
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	#Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
	if [ $CPU_CORE -le $CPU_6CORE ];
	# then
	# If statement for low core systems
	# Forces computers to only use 1 core if there are 4 cores or less on the system
	then
	export CPU_QUARTER_EVEN="2"
	else
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi
	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"
	echo " "
	##############################Downloading Libraries############################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
	echo " "
	#############################Compilers############################
	#Symlink to avoid clang conflicts with compilers
	#default gcc path /usr/bin/gcc
	#default homebrew path /usr/local/bin
	# Find the highest version of GCC in /usr/local/bin
	latest_gcc=$(ls /usr/local/bin/gcc-* 2>/dev/null | grep -o 'gcc-[0-9]*' | sort -V | tail -n 1)
	latest_gpp=$(ls /usr/local/bin/g++-* 2>/dev/null | grep -o 'g++-[0-9]*' | sort -V | tail -n 1)
	latest_gfortran=$(ls /usr/local/bin/gfortran-* 2>/dev/null | grep -o 'gfortran-[0-9]*' | sort -V | tail -n 1)
	# Display the chosen versions
	echo "Selected gcc version: $latest_gcc"
	echo "Selected g++ version: $latest_gpp"
	echo "Selected gfortran version: $latest_gfortran"
	# Check if GCC, G++, and GFortran were found
	if [ -z "$latest_gcc" ];
	then
	echo "No GCC version found in /usr/local/bin."
	exit 1
	fi
	# Create or update the symbolic links for GCC, G++, and GFortran
	echo "Linking the latest GCC version: $latest_gcc"
	echo $PASSWD | sudo -S ln -sf /usr/local/bin/$latest_gcc /usr/local/bin/gcc
	if [ ! -z "$latest_gpp" ];
	then
	echo "Linking the latest G++ version: $latest_gpp"
	echo $PASSWD | sudo -S ln -sf /usr/local/bin/$latest_gpp /usr/local/bin/g++
	fi
	if [ ! -z "$latest_gfortran" ];
	then
	echo "Linking the latest GFortran version: $latest_gfortran"
	echo $PASSWD | sudo -S ln -sf /usr/local/bin/$latest_gfortran /usr/local/bin/gfortran
	fi
	echo "Updated symbolic links for GCC, G++, and GFortran."
	echo $PASSWD | sudo -S ln -sf /usr/local/bin/python3.12 /usr/local/bin/python3
	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wall"
	echo " "
	#IF statement for GNU compiler issue
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	export fallow_argument=-fallow-argument-mismatch
	export boz_argument=-fallow-invalid-boz
	else
	export fallow_argument=
	export boz_argument=
	fi
	export FFLAGS="$fallow_argument -m64"
	export FCFLAGS="$fallow_argument -m64"
	echo "##########################################"
	echo "FFLAGS = $FFLAGS"
	echo "FCFLAGS = $FCFLAGS"
	echo "CFLAGS = $CFLAGS"
	echo "##########################################"
	echo " "
	#############################zlib############################
	#Uncalling compilers due to comfigure issue with zlib1.2.12
	#With CC & CXX definied ./configure uses different compiler Flags
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	##############################MPICH############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf mpich-$Mpich_Version.tar.gz
	cd mpich-$Mpich_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS="$fallow_argument -m64" FCFLAGS="$fallow_argument -m64" 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee install.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PATH=$DIR/MPICH/bin:$PATH
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	echo " "
	#############################libpng############################
	cd "${WRF_FOLDER}"/Downloads
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#############################JasPer############################
	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include
	echo " "
	#############################hdf5 library for netcdf4 functionality############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export HDF5=$DIR/grib2
	export PHDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	echo " "
	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PNETCDF=$DIR/grib2
	echo " "
	##############################Install NETCDF C Library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "
	##############################NetCDF fortran library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#################################### System Environment Tests ##############
	mkdir -p "${WRF_FOLDER}"/Tests/Environment
	mkdir -p "${WRF_FOLDER}"/Tests/Compatibility
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
	export one="1"
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Environment
	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 1 Passed"
	else
	echo "Environment Compiler Test 1 Failed"
	# exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 2 Passed"
	else
	echo "Environment Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 3 Passed"
	else
	echo "Environment Compiler Test 3 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 4 Passed"
	else
	echo "Environment Compiler Test 4 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Compatibility
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 1 Passed"
	else
	echo "Compatibility Compiler Test 1 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
	$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 2 Passed"
	else
	echo "Compatibility Compiler Test 2 Failed"
	exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo " All tests completed and passed"
	echo " "
	################################OpenGrADS######################################
	#Verison 2.2.1 64bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]];
	then
	cd "${WRF_FOLDER}"/Downloads
	wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/macOS/opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg
	sudo -S installer -pkg opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg -target /Applications/OpenGrads <<<"$PASSWD"
	fi
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]];
	then
	brew install grads
	fi
	####################################################################
	#Installing Miniconda3 to WRF directory and updating libraries
	####################################################################
	echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
	mkdir -p $Miniconda_Install_DIR
	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
	rm -rf $Miniconda_Install_DIR/miniconda.sh
	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell
	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y
	echo " "
	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml
	######################### Climate Data Operators ############
	######################### CDO compiled via Conda ###########
	####################### This is the preferred method #######
	################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create --name cdo_stable -y
	conda activate cdo_stable
	conda install -c conda-forge cdo -y
	conda update --all -y
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	############################ WRF #################################
	## WRF v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 17, option 1 for gfortran and distributed memory w/basic nesting
	# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
	########################################################################
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	./clean
	if [ ${auto_config} -eq 1 ];
	then
	sed -i'' -e '443s/.*/  $response = "17 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
	sed -i'' -e '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
	./configure 2>&1 | tee configure.log
	else
	./configure 2>&1 | tee configure.log #Option 17 gfortran compiler with distributed memory option 1 for basic nesting
	fi
	./compile em_real 2>&1 | tee compile.wrf.log
	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3)); then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 19 | ./configure 2>&1 | tee configure.log #Option 19 for gfortran and distributed memory
	else
	./configure 2>&1 | tee configure.log #Option 19 gfortran compiler with distributed memory
	fi
	./compile 2>&1 | tee compile.wrf.log
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	./compile 2>&1 | tee compile.wps2.log
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFPLUS 4DVAR###############################
	## WRFPLUS v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFPLUS is built within the WRF git folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 10 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFPLUS
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFPLUS/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFPLUS/WRF "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFPLUS
	cd "${WRF_FOLDER}"/WRFPLUS
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	if [ ${auto_config} -eq 1 ];
	then
	echo 10 | ./configure wrfplus 2>&1 | tee configure.log #Option 10 for gfortran/gcc and distribunted memory
	else
	./configure wrfplus 2>&1 | tee configure.log #Option 10 for gfortran/gcc and distribunted memory
	fi
	./compile wrfplus 2>&1 | tee compile.wrfplus.log
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFPLUS/
	./compile -j $CPU_QUARTER_EVEN wrfplus 2>&1 | tee compile.wrfplus2.log
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFDA 4DVAR###############################
	## WRFDA v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFDA is built within the WRFPLUS folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 10 for gfortran/clang and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	if [ ${auto_config} -eq 1 ];
	then
	echo 10 | ./configure 4dvar 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	else
	./configure 4dvar 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	./compile all_wrfvar 2>&1 | tee compile.wrf4dvar.log
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFDA
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
	if [ ${WPS_Specific_Applications} -eq 1 ];
	then
	echo " "
	echo " WPS Geographical Input Data Mandatory for Specific Applications"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
	tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
	tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
	tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
	tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
	tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
	tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
	tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
	tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
	tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
	tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	if [ ${Optional_GEOG} -eq 1 ];
	then
	echo " "
	echo "Optional WPS Geographical Input Data"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
	tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
	tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
	tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
	tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
	tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
	tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	fi
	if [ "$macos_64bit_GNU" = "1" ] && [ "$WRF_PICK" = "1" ] && [ "$MAC_CHIP" = "ARM" ];
	then
	#############################basic package managment############################
	brew update
	outdated_packages=$(brew outdated --quiet)
	# List of packages to check/install
	packages=(
	"autoconf" "automake" "bison" "byacc" "cmake" "curl" "flex" "gcc"
	"gdal" "gedit" "git" "gnu-sed" "grads" "imagemagick" "java" "ksh"
	"libtool" "libxml2" "m4" "make" "python@3.12" "snapcraft" "tcsh" "wget"
	"xauth" "xorgproto" "xorgrgb" "xquartz"
	)
	for pkg in "${packages[@]}"; do
	if brew list "$pkg" &>/dev/null;
	then
	echo "$pkg is already installed."
	if [[ $outdated_packages == *"$pkg"* ]];
	then
	echo "$pkg has a newer version available. Upgrading..."
	brew upgrade "$pkg"
	fi
	else
	echo "$pkg is not installed. Installing..."
	brew install "$pkg"
	fi
	sleep 1
	done
	export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
	export PATH=/usr/local/bin:$PATH
	##############################Directory Listing############################
	export HOME=$(
	cd
	pwd
	)
	mkdir $HOME/WRF
	export WRF_FOLDER=$HOME/WRF
	cd "${WRF_FOLDER}"/
	mkdir Downloads
	mkdir WRFPLUS
	mkdir WRFDA
	mkdir Libs
	export DIR="${WRF_FOLDER}"/Libs
	mkdir -p Libs/grib2
	mkdir -p Libs/NETCDF
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility
	#############################Core Management####################################
	export CPU_CORE=$(sysctl -n hw.ncpu) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4))
	#1/2 of availble cores on system
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	#Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
	if [ $CPU_CORE -le $CPU_6CORE ];
	# then
	# If statement for low core systems
	# Forces computers to only use 1 core if there are 4 cores or less on the system
	then
	export CPU_QUARTER_EVEN="2"
	else
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi
	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"
	echo " "
	##############################Downloading Libraries############################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
	echo " "
	#############################Compilers############################
	echo $PASSWD | sudo -S unlink /opt/homebrew/bin/gfortran
	echo $PASSWD | sudo -S unlink /opt/homebrew/bin/gcc
	echo $PASSWD | sudo -S unlink /opt/homebrew/bin/g++
	# Source the bashrc to ensure environment variables are loaded
	source ~/.bashrc
	# Check current versions of gcc, g++, and gfortran (this should show no version if unlinked)
	gcc --version
	g++ --version
	gfortran --version
	# Navigate to the Homebrew binaries directory
	cd /opt/homebrew/bin
	# Find the latest version of GCC, G++, and GFortran
	latest_gcc=$(ls gcc-* 2>/dev/null | grep -o 'gcc-[0-9]*' | sort -V | tail -n 1)
	latest_gpp=$(ls g++-* 2>/dev/null | grep -o 'g++-[0-9]*' | sort -V | tail -n 1)
	latest_gfortran=$(ls gfortran-* 2>/dev/null | grep -o 'gfortran-[0-9]*' | sort -V | tail -n 1)
	# Check if the latest versions were found, and link them
	if [ -n "$latest_gcc" ];
	then
	echo "Linking the latest GCC version: $latest_gcc"
	echo $PASSWD | sudo -S ln -sf $latest_gcc gcc
	else
	echo "No GCC version found."
	fi
	if [ -n "$latest_gpp" ];
	then
	echo "Linking the latest G++ version: $latest_gpp"
	echo $PASSWD | sudo -S ln -sf $latest_gpp g++
	else
	echo "No G++ version found."
	fi
	if [ -n "$latest_gfortran" ];
	then
	echo "Linking the latest GFortran version: $latest_gfortran"
	echo $PASSWD | sudo -S ln -sf $latest_gfortran gfortran
	else
	echo "No GFortran version found."
	fi
	# Return to the home directory
	cd
	# Source bashrc and bash_profile to reload the environment settings
	source ~/.bashrc
	source ~/.bash_profile
	# Check if the versions were successfully updated
	gcc --version
	g++ --version
	gfortran --version
	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wall"
	echo " "
	#IF statement for GNU compiler issue
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	export fallow_argument=-fallow-argument-mismatch
	export boz_argument=-fallow-invalid-boz
	else
	export fallow_argument=
	export boz_argument=
	fi
	export FFLAGS="$fallow_argument -m64"
	export FCFLAGS="$fallow_argument -m64"
	echo "##########################################"
	echo "FFLAGS = $FFLAGS"
	echo "FCFLAGS = $FCFLAGS"
	echo "CFLAGS = $CFLAGS"
	echo "##########################################"
	echo " "
	#############################zlib############################
	#Uncalling compilers due to comfigure issue with zlib1.2.12
	#With CC & CXX definied ./configure uses different compiler Flags
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	##############################MPICH############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf mpich-$Mpich_Version.tar.gz
	cd mpich-$Mpich_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS="$fallow_argument -m64" FCFLAGS="$fallow_argument -m64" 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PATH=$DIR/MPICH/bin:$PATH
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	echo " "
	#############################libpng############################
	cd "${WRF_FOLDER}"/Downloads
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#############################JasPer############################
	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include
	echo " "
	#############################hdf5 library for netcdf4 functionality############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export HDF5=$DIR/grib2
	export PHDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	echo " "
	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PNETCDF=$DIR/grib2
	echo " "
	##############################Install NETCDF C Library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "
	##############################NetCDF fortran library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#################################### System Environment Tests ##############
	mkdir -p "${WRF_FOLDER}"/Tests/Environment
	mkdir -p "${WRF_FOLDER}"/Tests/Compatibility
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
	export one="1"
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Environment
	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f
	./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 1 Passed"
	else
	echo "Environment Compiler Test 1 Failed"
	# exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 2 Passed"
	else
	echo "Environment Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 3 Passed"
	else
	echo "Environment Compiler Test 3 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 4 Passed"
	else
	echo "Environment Compiler Test 4 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Compatibility
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 1 Passed"
	else
	echo "Compatibility Compiler Test 1 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
	$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 2 Passed"
	else
	echo "Compatibility Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo " All tests completed and passed"
	echo " "
	################################OpenGrADS######################################
	#Verison 2.2.1 64bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]];
	then
	cd "${WRF_FOLDER}"/Downloads
	wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/macOS/opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg
	sudo -S installer -pkg opengrads-2.2.1.oga.1-bundle-x86_64-apple-darwin20.5.0.pkg -target /Applications/OpenGrads <<<"$PASSWD"
	fi
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]];
	then
	brew install grads
	fi
	####################################################################
	#Installing Miniconda3 to WRF directory and updating libraries
	####################################################################
	echo $PASSWD | sudo -S apt -y install python3-zstandard python3-zstd
	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
	mkdir -p $Miniconda_Install_DIR
	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
	rm -rf $Miniconda_Install_DIR/miniconda.sh
	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell
	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y
	echo " "
	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable
	conda update -n ncl_stable --all -y
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml
	######################### Climate Data Operators ############
	######################### CDO compiled via Conda ###########
	####################### This is the preferred method #######
	################### https://bairdlangenbrunner.github.io/python-for-climate-scientists/conda/setting-up-conda-environments.html #######################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create --name cdo_stable -y
	conda activate cdo_stable
	conda install -c conda-forge cdo -y
	conda update --all -y
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	############################ WRF #################################
	## WRF v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 17, option 1 for gfortran and distributed memory w/basic nesting
	# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
	########################################################################
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	./clean
	if [ ${auto_config} -eq 1 ];
	then
	sed -i'' -e '443s/.*/  $response = "17 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
	sed -i'' -e '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
	./configure 2>&1 | tee configure.log
	else
	./configure 2>&1 | tee configure.log #Option 17 gfortran compiler with distributed memory option 1 for basic nesting
	fi
	./compile em_real 2>&1 | tee compile.wrf.log
	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 19 | ./configure 2>&1 | tee configure.log #Option 19 for gfortran and distributed memory
	else
	./configure 2>&1 | tee configure.log #Option 19 gfortran compiler with distributed memory
	fi
	./compile | tee 2>&1 compile.wrf.log
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	./compile 2>&1 | tee compile.wps2.log
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFPLUS 4DVAR###############################
	## WRFPLUS v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFPLUS is built within the WRF git folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 10 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFPLUS
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFPLUS/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFPLUS/WRF "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFPLUS
	cd "${WRF_FOLDER}"/WRFPLUS
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	if [ ${auto_config} -eq 1 ];
	then
	echo 10 | ./configure wrfplus 2>&1 | tee configure.log #Option 10 for gfortran/gcc and distribunted memory
	else
	./configure wrfplus 2>&1 | tee configure.log #Option 10 for gfortran/gcc and distribunted memory
	fi
	./compile wrfplus 2>&1 | tee compile.wrfplus.log
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFPLUS/
	./compile -j $CPU_QUARTER_EVEN wrfplus 2>&1 | tee compile.wrfplus2.log
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFDA 4DVAR###############################
	## WRFDA v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFDA is built within the WRFPLUS folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 10 for gfortran/clang and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	if [ ${auto_config} -eq 1 ];
	then
	echo 10 | ./configure 4dvar 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	else
	./configure 4dvar 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	./compile all_wrfvar 2>&1 | tee compile.wrf4dvar.log
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFDA
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
	if [ ${WPS_Specific_Applications} -eq 1 ];
	then
	echo " "
	echo " WPS Geographical Input Data Mandatory for Specific Applications"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
	tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
	tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
	tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
	tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
	tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
	tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
	tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
	tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
	tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
	tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	if [ ${Optional_GEOG} -eq 1 ];
	then
	echo " "
	echo "Optional WPS Geographical Input Data"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
	tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
	tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
	tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
	tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
	tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
	tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	fi
	if [ "$RHL_64bit_GNU" = "1" ] && [ "$WRF_PICK" = "1" ];
	then
	#############################basic package managment############################
	echo $PASSWD | sudo -S yum install epel-release -y
	echo $PASSWD | sudo -S yum install dnf -y
	echo $PASSWD | sudo -S dnf install epel-release -y
	echo $PASSWD | sudo -S dnf install dnf -y
	echo $PASSWD | sudo -S dnf -y update
	echo $PASSWD | sudo -S dnf -y upgrade
	echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig-devel fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk ksh libX11-devel libX11-devel libXaw libXaw-devel libXext-devel libXext-devel libXmu-devel libXrender-devel libXrender-devel libstdc++ libstdc++-devel libxml2 libxml2-devel m4 nfs-utils perl "perl(XML::LibXML)" pkgconfig pixman-devel python3 python3-devel tcsh time unzip wget
	echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
	echo $PASSWD | sudo -S dnf -y update
	echo $PASSWD | sudo -S dnf -y upgrade
	echo " "
	##############################Directory Listing############################
	export HOME=$(
	cd
	pwd
	)
	mkdir $HOME/WRF
	export WRF_FOLDER=$HOME/WRF
	cd "${WRF_FOLDER}"/
	mkdir Downloads
	mkdir WRFPLUS
	mkdir WRFDA
	mkdir Libs
	export DIR="${WRF_FOLDER}"/Libs
	mkdir Libs/grib2
	mkdir Libs/NETCDF
	mkdir Libs/MPICH
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility
	echo " "
	#############################Core Management####################################
	export CPU_CORE=$(nproc) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4)) #quarter of availble cores on system
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) #Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
	if [ $CPU_CORE -le $CPU_6CORE ];
	# then
	# If statement for low core systems 
	# Forces computers to only use 1 core if there are 4 cores or less on the system
	then
	export CPU_QUARTER_EVEN="2"
	else
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi
	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"

	echo " "
	##############################Downloading Libraries############################
	#Force use of ipv4 with -4
	cd Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
	wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
	echo " "
	####################################Compilers#####################################
	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -O3"
	#IF statement for GNU compiler issue
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	export fallow_argument=-fallow-argument-mismatch
	export boz_argument=-fallow-invalid-boz
	else
	export fallow_argument=
	export boz_argument=
	fi
	export FFLAGS="$fallow_argument -m64"
	export FCFLAGS="$fallow_argument -m64"
	echo "##########################################"
	echo "FFLAGS = $FFLAGS"
	echo "FCFLAGS = $FCFLAGS"
	echo "CFLAGS = $CFLAGS"
	echo "##########################################"
	echo " "
	#############################zlib############################
	#Uncalling compilers due to comfigure issue with zlib$Zlib_Version
	#With CC & CXX definied ./configure uses different compiler Flags
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	##############################MPICH############################
	#F90= due to compiler issues with mpich install
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf mpich-$Mpich_Version.tar.gz
	cd mpich-$Mpich_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	# make check
	export PATH=$DIR/MPICH/bin:$PATH
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	echo " "
	#############################libpng############################
	cd "${WRF_FOLDER}"/Downloads
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#############################JasPer############################
	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include
	echo " "
	#############################hdf5 library for netcdf4 functionality############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export HDF5=$DIR/grib2
	export PHDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	echo " "
	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PNETCDF=$DIR/grib2
	echo " "
	##############################Install NETCDF C Library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "
	##############################NetCDF fortran library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#################################### System Environment Tests ##############
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
	export one="1"
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Environment
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 1 Passed"
	else
	echo "Environment Compiler Test 1 Failed"
	# exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 2 Passed"
	else
	echo "Environment Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 3 Passed"
	else
	echo "Environment Compiler Test 3 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 4 Passed"
	else
	echo "Environment Compiler Test 4 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Compatibility
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 1 Passed"
	else
	echo "Compatibility Compiler Test 1 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
	$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 2 Passed"
	else
	echo "Compatibility Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo " All tests completed and passed"
	echo " "
	###############################NCEPlibs#####################################
	# The libraries are built and installed with
	# ./make_ncep_libs.sh -s MACHINE -c COMPILER -d NCEPLIBS_DIR -o OPENMP [-m mpi] [-a APPLICATION]
	# It is recommended to install the NCEPlibs into their own directory, which must be created before running the installer.
	# Further information on the command line arguments can be obtained with ./make_ncep_libs.sh -h
	# If iand error occurs go to https://github.com/NCAR/NCEPlibs/pull/16/files make adjustment and re-run ./make_ncep_libs.sh
	############################################################################
	cd "${WRF_FOLDER}"/Downloads
	git clone https://github.com/NCAR/NCEPlibs.git
	cd NCEPlibs
	mkdir $DIR/nceplibs
	export JASPER_INC=$DIR/grib2/include
	export PNG_INC=$DIR/grib2/include
	export NETCDF=$DIR/NETCDF
	#for loop to edit linux.gnu for nceplibs to install
	#make if statement for gcc-9 or older
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	sed -i "24s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "28s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "32s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "36s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "40s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "45s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "49s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "53s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "56s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "60s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "64s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "68s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "69s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "73s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "74s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "79s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	fi
	if [ ${auto_config} -eq 1 ];
	then
	echo yes | ./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
	else
	./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
	fi
	export PATH=$DIR/nceplibs:$PATH
	echo " "
	######################## ARWpost V3.1  ############################
	## ARWpost
	##Configure #3
	###################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
	tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/ARWpost
	./clean -a
	sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
	else
	./configure #Option 3 gfortran compiler with distributed memory
	fi
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	sed -i '32s/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4 ${fallow_argument} /g' configure.arwp
	fi
	sed -i -e 's/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	./compile
	#IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/ARWpost
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH
	echo " "
	################################ OpenGrADS ##################################
	#Verison 2.2.1 32bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]];
	then
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/
	mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
	cd GrADS/Contents
	wget -c https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
	chmod +x g2ctl.pl
	wget -c https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	tar -xzvf wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	cd wgrib2-v0.1.9.4/bin
	mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
	cd "${WRF_FOLDER}"/GrADS/Contents
	rm wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	rm -r wgrib2-v0.1.9.4
	export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH
	echo " "
	fi
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]];
	then
	cd "${WRF_FOLDER}"/Downloads
	wget -c ftp://cola.gmu.edu/grads/2.2/grads-2.2.1-bin-RHL7.4-x86_64.tar.gz
	tar -xzvf grads-2.2.1-bin-RHL7.4-x86_64.tar.gz -C "${WRF_FOLDER}"
	cd "${WRF_FOLDER}"/grads-2.2.1/bin
	chmod 775 *
	fi
	##################### NCAR COMMAND LANGUAGE           ##################
	########### NCL compiled via Conda                    ##################
	########### This is the preferred method by NCAR      ##################
	########### https://www.ncl.ucar.edu/index.shtml      ##################
	#Installing Miniconda3 to WRF-Hydro directory and updating libraries
	echo $PASSWD | sudo -S dnf -y install python3-zstandard python3-zstd
	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
	mkdir -p $Miniconda_Install_DIR
	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
	rm -rf $Miniconda_Install_DIR/miniconda.sh
	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell
	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y
	echo " "
	echo " "
	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	echo " "
	############################OBSGRID###############################
	## OBSGRID
	## Downloaded from git tagged releases
	## Option #2
	########################################################################
	cd "${WRF_FOLDER}"/
	git clone https://github.com/wrf-model/OBSGRID.git
	cd "${WRF_FOLDER}"/OBSGRID
	./clean -a

	export DIR="${WRF_FOLDER}"/Libs
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 2 | ./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	else
	./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	fi
	sed -i '27s/-lnetcdf -lnetcdff/ -lnetcdff -lnetcdf/g' configure.oa
	sed -i '31s/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo -lfontconfig -lpixman-1 -lfreetype -lhdf5 -lhdf5_hl /g' configure.oa
	sed -i '39s/-frecord-marker=4/-frecord-marker=4 ${fallow_argument} /g' configure.oa
	sed -i '44s/=	/=	${fallow_argument} /g' configure.oa
	sed -i '45s/-C -P -traditional/-P -traditional/g' configure.oa
	echo " "
	./compile 2>&1 | tee compile.obsgrid.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/OBSGRID
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing OBSGRID. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml
	echo " "
	############################ WRF #################################
	## WRF v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 34, option 1 for gfortran and distributed memory w/basic nesting
	# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
	# In the namelist.input, the following settings support pNetCDF by setting value to 11:
	# io_form_boundary
	# io_form_history
	# io_form_auxinput2
	# io_form_auxhist2
	# Note that you need set nocolons = .true. in the section &time_control of namelist.input
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	sed -i '443s/.*/  $response = "34 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
	sed -i '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
	./configure 2>&1 | tee configure.log
	else
	./configure 2>&1 | tee configure.log #Option 34 gfortran compiler with distributed memory option 1 for basic nesting
	fi
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}

	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
	else
	./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
	fi
	./compile 2>&1 | tee compile.wps.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	./compile 2>&1 | tee compile.wps2.log
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFPLUS 4DVAR###############################
	## WRFPLUS v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFPLUS is built within the WRF git folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 18 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFPLUS
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFPLUS/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFPLUS/WRF "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFPLUS
	cd "${WRF_FOLDER}"/WRFPLUS
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 18 | ./configure wrfplus 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	else
	./configure wrfplus 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile -j $CPU_QUARTER_EVEN wrfplus 2>&1 | tee compile.wrfplus.log
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFPLUS/
	./compile -j $CPU_QUARTER_EVEN wrfplus 2>&1 | tee compile.wrfplus2.log
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFDA 4DVAR###############################
	## WRFDA v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFDA is built within the WRFPLUS folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 18 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/WRFDA
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 18 | ./configure 4dvar 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	else
	./configure 4dvar 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile all_wrfvar 2>&1 | tee compile.wrf4dvar.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFDA
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	echo " "
	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
	if [ ${WPS_Specific_Applications} -eq 1 ];
	then
	echo " "
	echo " WPS Geographical Input Data Mandatory for Specific Applications"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
	tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
	tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
	tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG/irrigation
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG/fao "${WRF_FOLDER}"/GEOG/WPS_GEOG/irrigation
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
	tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
	tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
	tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
	tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
	tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
	tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
	tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	if [ ${Optional_GEOG} -eq 1 ];
	then
	echo " "
	echo "Optional WPS Geographical Input Data"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
	tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
	tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
	tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
	tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
	tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
	tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	fi
	if [ "$RHL_64bit_GNU" = "2" ] && [ "$WRF_PICK" = "1" ];
	then
	#############################basic package managment############################
	echo "old version of GNU detected"
	echo $PASSWD | sudo -S yum install RHL-release-scl -y
	echo $PASSWD | sudo -S yum clean all
	echo $PASSWD | sudo -S yum remove devtoolset-11*
	echo $PASSWD | sudo -S yum install devtoolset-11
	echo $PASSWD | sudo -S yum install devtoolset-11-\* -y
	source /opt/rh/devtoolset-11/enable
	gcc --version
	echo $PASSWD | sudo -S yum install epel-release -y
	echo $PASSWD | sudo -S yum install dnf -y
	echo $PASSWD | sudo -S dnf install epel-release -y
	echo $PASSWD | sudo -S dnf install dnf -y
	echo $PASSWD | sudo -S dnf -y update
	echo $PASSWD | sudo -S dnf -y upgrade
	echo $PASSWD | sudo -S dnf -y install autoconf automake bzip2 bzip2-devel byacc cairo-devel cmake cpp curl curl-devel flex fontconfig-devel fontconfig-devel gcc gcc-c++ gcc-gfortran git java java-devel java-openjdk ksh libX11-devel libX11-devel libXaw libXaw-devel libXext-devel libXext-devel libXmu-devel libXrender-devel libXrender-devel libstdc++ libstdc++-devel libxml2 libxml2-devel m4 nfs-utils perl "perl(XML::LibXML)" pkgconfig pixman-devel python3 python3-devel tcsh time unzip wget
	echo $PASSWD | sudo -S dnf -y groupinstall "Development Tools"
	echo $PASSWD | sudo -S dnf -y update
	echo $PASSWD | sudo -S dnf -y upgrade
	echo " "
	##############################Directory Listing############################
	export HOME=$(
	cd
	pwd
	)
	mkdir $HOME/WRF
	export WRF_FOLDER=$HOME/WRF
	cd "${WRF_FOLDER}"/
	mkdir Downloads
	mkdir WRFPLUS
	mkdir WRFDA
	mkdir Libs
	export DIR="${WRF_FOLDER}"/Libs
	mkdir Libs/grib2
	mkdir Libs/NETCDF
	mkdir Libs/MPICH
	mkdir -p Tests/Environment
	mkdir -p Tests/Compatibility
	echo " "
	#############################Core Management####################################
	export CPU_CORE=$(nproc) # number of available threads on system
	export CPU_6CORE="6"
	export CPU_QUARTER=$(($CPU_CORE / 4)) #quarter of availble cores on system
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2))) #Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.
	if [ $CPU_CORE -le $CPU_6CORE ];
	# then
	# If statement for low core systems 
	# Forces computers to only use 1 core if there are 4 cores or less on the system
	then
	export CPU_QUARTER_EVEN="2"
	else
	export CPU_QUARTER_EVEN=$(($CPU_QUARTER - ($CPU_QUARTER % 2)))
	fi
	echo "##########################################"
	echo "Number of Threads being used $CPU_QUARTER_EVEN"
	echo "##########################################"

	echo " "
	##############################Downloading Libraries############################
	#Force use of ipv4 with -4
	cd Downloads
	wget -c https://github.com/madler/zlib/releases/download/v$Zlib_Version/zlib-$Zlib_Version.tar.gz
	wget -c https://github.com/HDFGroup/hdf5/releases/download/hdf5_$HDF5_Version.$HDF5_Sub_Version/hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v$Netcdf_C_Version.tar.gz
	wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v$Netcdf_Fortran_Version.tar.gz
	wget -c https://github.com/pmodels/mpich/releases/download/v$Mpich_Version/mpich-$Mpich_Version.tar.gz
	wget -c https://download.sourceforge.net/libpng/libpng-$Libpng_Version.tar.gz
	wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-$Jasper_Version.zip
	wget -c https://parallel-netcdf.github.io/Release/pnetcdf-$Pnetcdf_Version.tar.gz
	wget -c https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
	echo " "
	####################################Compilers#####################################
	export CC=gcc
	export CXX=g++
	export FC=gfortran
	export F77=gfortran
	export CFLAGS="-fPIC -fPIE -O3"
	#IF statement for GNU compiler issue
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	export fallow_argument=-fallow-argument-mismatch
	export boz_argument=-fallow-invalid-boz
	else
	export fallow_argument=
	export boz_argument=
	fi
	export FFLAGS="$fallow_argument -m64"
	export FCFLAGS="$fallow_argument -m64"
	echo "##########################################"
	echo "FFLAGS = $FFLAGS"
	echo "FCFLAGS = $FCFLAGS"
	echo "CFLAGS = $CFLAGS"
	echo "##########################################"
	echo " "
	#############################zlib############################
	#Uncalling compilers due to comfigure issue with zlib$Zlib_Version
	#With CC & CXX definied ./configure uses different compiler Flags
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf zlib-$Zlib_Version.tar.gz
	cd zlib-$Zlib_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	##############################MPICH############################
	#F90= due to compiler issues with mpich install
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf mpich-$Mpich_Version.tar.gz
	cd mpich-$Mpich_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	# make check
	export PATH=$DIR/MPICH/bin:$PATH
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	echo " "
	#############################libpng############################
	cd "${WRF_FOLDER}"/Downloads
	export LDFLAGS=-L$DIR/grib2/lib
	export CPPFLAGS=-I$DIR/grib2/include
	tar -xvzf libpng-$Libpng_Version.tar.gz
	cd libpng-$Libpng_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#############################JasPer############################
	cd "${WRF_FOLDER}"/Downloads
	unzip jasper-$Jasper_Version.zip
	cd jasper-$Jasper_Version/
	autoreconf -i -f 2>&1 | tee autoreconf.log
	./configure --prefix=$DIR/grib2
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export JASPERLIB=$DIR/grib2/lib
	export JASPERINC=$DIR/grib2/include
	echo " "
	#############################hdf5 library for netcdf4 functionality############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf hdf5-$HDF5_Version-$HDF5_Sub_Version.tar.gz
	cd hdf5-$HDF5_Version-$HDF5_Sub_Version
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export HDF5=$DIR/grib2
	export PHDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	echo " "
	#############################Install Parallel-netCDF##############################
	#Make file created with half of available cpu cores
	#Hard path for MPI added
	##################################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf pnetcdf-$Pnetcdf_Version.tar.gz
	cd pnetcdf-$Pnetcdf_Version
	export MPIFC=$DIR/MPICH/bin/mpifort
	export MPIF77=$DIR/MPICH/bin/mpifort
	export MPIF90=$DIR/MPICH/bin/mpifort
	export MPICC=$DIR/MPICH/bin/mpicc
	export MPICXX=$DIR/MPICH/bin/mpicxx
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/grib2 --enable-shared --enable-static 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PNETCDF=$DIR/grib2
	echo " "
	##############################Install NETCDF C Library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf v$Netcdf_C_Version.tar.gz
	cd netcdf-c-$Netcdf_C_Version/
	export CPPFLAGS=-I$DIR/grib2/include
	export LDFLAGS=-L$DIR/grib2/lib
	export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl -lpnetcdf"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-pnetcdf --enable-cdf5 --enable-parallel-tests 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	export PATH=$DIR/NETCDF/bin:$PATH
	export NETCDF=$DIR/NETCDF
	echo " "
	##############################NetCDF fortran library############################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf v$Netcdf_Fortran_Version.tar.gz
	cd netcdf-fortran-$Netcdf_Fortran_Version/
	export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
	export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
	export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
	export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5 -lz -lm -ldl -lgcc -lgfortran"
	autoreconf -i -f 2>&1 | tee autoreconf.log
	CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX CFLAGS=$CFLAGS FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared --enable-static --enable-parallel-tests --enable-hdf5 2>&1 | tee configure.log
	automake -a -f 2>&1 | tee automake.log
	make -j $CPU_QUARTER_EVEN 2>&1 | tee make.log
	make -j $CPU_QUARTER_EVEN check 2>&1 | tee make.check.log
	make -j $CPU_QUARTER_EVEN install 2>&1 | tee make.install.log
	#make check
	echo " "
	#################################### System Environment Tests ##############
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
	wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
	tar -xvf Fortran_C_tests.tar -C "${WRF_FOLDER}"/Tests/Environment
	tar -xvf Fortran_C_NETCDF_MPI_tests.tar -C "${WRF_FOLDER}"/Tests/Compatibility
	export one="1"
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Environment
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Environment Testing "
	echo "Test 1"
	$FC TEST_1_fortran_only_fixed.f ./a.out | tee env_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 1 Passed"
	else
	echo "Environment Compiler Test 1 Failed"
	# exit
	fi
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$FC TEST_2_fortran_only_free.f90 ./a.out | tee env_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 2 Passed"
	else
	echo "Environment Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 3"
	$CC TEST_3_c_only.c ./a.out | tee env_test3.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test3.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 3 Passed"
	else
	echo "Environment Compiler Test 3 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 4"
	$CC -c -m64 TEST_4_fortran+c_c.c
	$FC -c -m64 TEST_4_fortran+c_f.f90
	$FC -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o ./a.out | tee env_test4.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" env_test4.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Enviroment Test 4 Passed"
	else
	echo "Environment Compiler Test 4 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	############## Testing Environment #####
	cd "${WRF_FOLDER}"/Tests/Compatibility
	cp ${NETCDF}/include/netcdf.inc .
	echo " "
	echo " "
	echo "Library Compatibility Tests "
	echo "Test 1"
	$FC -c 01_fortran+c+netcdf_f.f
	$CC -c 01_fortran+c+netcdf_c.c
	$FC 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf ./a.out | tee comp_test1.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test1.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 1 Passed"
	else
	echo "Compatibility Compiler Test 1 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo "Test 2"
	$MPIFC -c 02_fortran+c+netcdf+mpi_f.f
	$MPICC -c 02_fortran+c+netcdf+mpi_c.c
	$MPIFC 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
	$DIR/MPICH/bin/mpirun ./a.out | tee comp_test2.txt
	export TEST_PASS=$(grep -w -o -c "SUCCESS" comp_test2.txt | awk '{print$1}')
	if [ $TEST_PASS -ge 1 ];
	then
	echo "Compatibility Test 2 Passed"
	else
	echo "Compatibility Compiler Test 2 Failed"
	# exit
	fi
	echo " "
	read -r -t 3 -p "I am going to wait for 3 seconds only ..."
	echo " "
	echo " All tests completed and passed"
	echo " "
	###############################NCEPlibs#####################################
	# The libraries are built and installed with
	# ./make_ncep_libs.sh -s MACHINE -c COMPILER -d NCEPLIBS_DIR -o OPENMP [-m mpi] [-a APPLICATION]
	# It is recommended to install the NCEPlibs into their own directory, which must be created before running the installer.
	# Further information on the command line arguments can be obtained with ./make_ncep_libs.sh -h
	# If iand error occurs go to https://github.com/NCAR/NCEPlibs/pull/16/files make adjustment and re-run ./make_ncep_libs.sh
	############################################################################
	cd "${WRF_FOLDER}"/Downloads
	git clone https://github.com/NCAR/NCEPlibs.git
	cd NCEPlibs
	mkdir $DIR/nceplibs
	export JASPER_INC=$DIR/grib2/include
	export PNG_INC=$DIR/grib2/include
	export NETCDF=$DIR/NETCDF
	#for loop to edit linux.gnu for nceplibs to install
	#make if statement for gcc-9 or older
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	sed -i "24s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "28s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "32s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "36s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "40s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "45s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "49s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "53s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "56s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "60s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "64s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "68s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "69s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "73s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "74s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	sed -i "79s/= /= $fallow_argument $boz_argument /g" "${WRF_FOLDER}/Downloads/NCEPlibs/macros.make.linux.gnu"
	fi
	if [ ${auto_config} -eq 1 ];
	then
	echo yes | ./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
	else
	./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp | tee make.install.log
	fi
	export PATH=$DIR/nceplibs:$PATH
	echo " "
	######################## ARWpost V3.1  ############################
	## ARWpost
	##Configure #3
	###################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
	tar -xvzf ARWpost_V3.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/ARWpost
	./clean -a
	sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' "${WRF_FOLDER}"/ARWpost/src/Makefile
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 3 | ./configure #Option 3 gfortran compiler with distributed memory
	else
	./configure #Option 3 gfortran compiler with distributed memory
	fi
	export GCC_VERSION=$(gcc -dumpfullversion | awk '{print$1}')
	export GFORTRAN_VERSION=$(gfortran -dumpfullversion | awk '{print$1}')
	export GPLUSPLUS_VERSION=$(g++ -dumpfullversion | awk '{print$1}')
	export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
	export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
	export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')
	export version_10="10"
	if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ];
	then
	sed -i '32s/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4 ${fallow_argument} /g' configure.arwp
	fi
	sed -i -e 's/-C -P -traditional/-P -traditional/g' "${WRF_FOLDER}"/ARWpost/configure.arwp
	./compile
	#IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/ARWpost
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing ARWpost. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	export PATH="${WRF_FOLDER}"/ARWpost/ARWpost.exe:$PATH
	echo " "
	################################ OpenGrADS ##################################
	#Verison 2.2.1 32bit of Linux
	#############################################################################
	if [[ $GRADS_PICK -eq 1 ]];
	then
	cd "${WRF_FOLDER}"/Downloads
	tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/
	mv "${WRF_FOLDER}"/opengrads-2.2.1.oga.1 "${WRF_FOLDER}"/GrADS
	cd GrADS/Contents
	wget -c https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
	chmod +x g2ctl.pl
	wget -c https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	tar -xzvf wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	cd wgrib2-v0.1.9.4/bin
	mv wgrib2 "${WRF_FOLDER}"/GrADS/Contents
	cd "${WRF_FOLDER}"/GrADS/Contents
	rm wgrib2-v0.1.9.4-bin-i686-glib2.5-linux-gnu.tar.gz
	rm -r wgrib2-v0.1.9.4
	export PATH="${WRF_FOLDER}"/GrADS/Contents:$PATH
	echo " "
	fi
	################################## GrADS ###############################
	# Version  2.2.1
	# Sublibs library instructions: http://cola.gmu.edu/grads/gadoc/supplibs2.html
	# GrADS instructions: http://cola.gmu.edu/grads/downloads.php
	########################################################################
	if [[ $GRADS_PICK -eq 2 ]];
	then
	cd "${WRF_FOLDER}"/Downloads
	wget -c ftp://cola.gmu.edu/grads/2.2/grads-2.2.1-bin-RHL7.4-x86_64.tar.gz
	tar -xzvf grads-2.2.1-bin-RHL7.4-x86_64.tar.gz -C "${WRF_FOLDER}"
	cd "${WRF_FOLDER}"/grads-2.2.1/bin
	chmod 775 *
	fi
	##################### NCAR COMMAND LANGUAGE           ##################
	########### NCL compiled via Conda                    ##################
	########### This is the preferred method by NCAR      ##################
	########### https://www.ncl.ucar.edu/index.shtml      ##################
	#Installing Miniconda3 to WRF-Hydro directory and updating libraries
	echo $PASSWD | sudo -S dnf -y install python3-zstandard python3-zstd
	export Miniconda_Install_DIR="${WRF_FOLDER}"/miniconda3
	mkdir -p $Miniconda_Install_DIR
	wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $Miniconda_Install_DIR/miniconda.sh
	bash $Miniconda_Install_DIR/miniconda.sh -b -u -p $Miniconda_Install_DIR
	rm -rf $Miniconda_Install_DIR/miniconda.sh
	export PATH="${WRF_FOLDER}"/miniconda3/bin:$PATH
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	$Miniconda_Install_DIR/bin/conda init bash
	$Miniconda_Install_DIR/bin/conda init zsh
	$Miniconda_Install_DIR/bin/conda init tcsh
	$Miniconda_Install_DIR/bin/conda init xonsh
	$Miniconda_Install_DIR/bin/conda init powershell
	conda config --add channels conda-forge
	conda config --set auto_activate_base false
	conda update -n root --all -y
	echo " "
	echo " "
	#Installing NCL via Conda
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda init bash
	conda activate base
	conda create -n ncl_stable -c conda-forge ncl -y
	conda activate ncl_stable
	conda deactivate
	conda deactivate
	conda deactivate
	echo " "
	############################OBSGRID###############################
	## OBSGRID
	## Downloaded from git tagged releases
	## Option #2
	########################################################################
	cd "${WRF_FOLDER}"/
	git clone https://github.com/wrf-model/OBSGRID.git
	cd "${WRF_FOLDER}"/OBSGRID
	./clean -a

	export DIR="${WRF_FOLDER}"/Libs
	export NETCDF=$DIR/NETCDF
	if [ ${auto_config} -eq 1 ];
	then
	echo 2 | ./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	else
	./configure 2>&1 | tee configure.log #Option 2 for gfortran/gcc and distribunted memory
	fi
	sed -i '27s/-lnetcdf -lnetcdff/ -lnetcdff -lnetcdf/g' configure.oa
	sed -i '31s/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo -lfontconfig -lpixman-1 -lfreetype -lhdf5 -lhdf5_hl /g' configure.oa
	sed -i '39s/-frecord-marker=4/-frecord-marker=4 ${fallow_argument} /g' configure.oa
	sed -i '44s/=	/=	${fallow_argument} /g' configure.oa
	sed -i '45s/-C -P -traditional/-P -traditional/g' configure.oa
	echo " "
	./compile 2>&1 | tee compile.obsgrid.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/OBSGRID
	n=$(ls ./*.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing OBSGRID. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files. Exiting the script."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	echo " "
	##################### WRF Python           ##################
	########### WRf-Python compiled via Conda  ##################
	########### This is the preferred method by NCAR      ##################
	##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
	source $Miniconda_Install_DIR/etc/profile.d/conda.sh
	conda env create -f $HOME/weather-ai/wrf-python-stable.yml
	echo " "
	############################ WRF #################################
	## WRF v${WPS_VERSION}
	## Downloaded from git tagged releases
	# option 34, option 1 for gfortran and distributed memory w/basic nesting
	# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
	# In the namelist.input, the following settings support pNetCDF by setting value to 11:
	# io_form_boundary
	# io_form_history
	# io_form_auxinput2
	# io_form_auxhist2
	# Note that you need set nocolons = .true. in the section &time_control of namelist.input
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WRF/releases/download/v${WRF_VERSION}/v${WRF_VERSION}.tar.gz -O WRF-${WRF_VERSION}.tar.gz
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRF "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	export WRFIO_NCD_LARGE_FILE_SUPPORT=1
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	sed -i '443s/.*/  $response = "34 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl # Answer for compiler choice
	sed -i '909s/.*/  $response = "1 \\n";/g' "${WRF_FOLDER}"/WRFV${WRF_VERSION}/arch/Config.pl  #Answer for basic nesting
	./configure 2>&1 | tee configure.log
	else
	./configure 2>&1 | tee configure.log #Option 34 gfortran compiler with distributed memory option 1 for basic nesting
	fi
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf1.log
	export WRF_DIR="${WRF_FOLDER}"/WRFV${WRF_VERSION}
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}
	./compile -j $CPU_QUARTER_EVEN em_real 2>&1 | tee compile.wrf2.log
	cd "${WRF_FOLDER}"/WRFV${WRF_VERSION}/main
	n=$(ls ./*.exe | wc -l)
	if (($n >= 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WPS#####################################
	## WPS v${WPS_VERSION}
	## Downloaded from git tagged releases
	#Option 3 for gfortran and distributed memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v${WPS_VERSION}.tar.gz -O WPS-${WPS_VERSION}.tar.gz
	tar -xvzf WPS-${WPS_VERSION}.tar.gz -C "${WRF_FOLDER}"/
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 3 | ./configure 2>&1 | tee configure.log #Option 3 for gfortran and distributed memory
	else
	./configure 2>&1 | tee configure.log #Option 3 gfortran compiler with distributed memory
	fi
	./compile 2>&1 | tee compile.wps.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	./compile 2>&1 | tee compile.wps2.log
	cd "${WRF_FOLDER}"/WPS-${WPS_VERSION}
	n=$(ls ./*.exe | wc -l)
	if (($n == 3));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WPS. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFPLUS 4DVAR###############################
	## WRFPLUS v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFPLUS is built within the WRF git folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 18 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFPLUS
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFPLUS/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFPLUS/WRF "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFPLUS/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFPLUS
	cd "${WRF_FOLDER}"/WRFPLUS
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 18 | ./configure wrfplus 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	else
	./configure wrfplus 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile -j $CPU_QUARTER_EVEN wrfplus 2>&1 | tee compile.wrfplus.log
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFPLUS/
	./compile -j $CPU_QUARTER_EVEN wrfplus 2>&1 | tee compile.wrfplus2.log
	cd "${WRF_FOLDER}"/WRFPLUS/main
	n=$(ls ./wrfplus.exe | wc -l)
	if (($n == 1));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRF Plus 4DVAR. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	# exit
	fi
	fi
	echo " "
	############################WRFDA 4DVAR###############################
	## WRFDA v${WPS_VERSION} 4DVAR
	## Downloaded from git tagged releases
	## WRFDA is built within the WRFPLUS folder
	## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
	##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice.
	#Option 18 for gfortran/gcc and distribunted memory
	########################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/WRFDA
	tar -xvzf WRF-${WRF_VERSION}.tar.gz -C "${WRF_FOLDER}"/WRFDA
	# If statment for changing folder name
	if [ -d ""${WRF_FOLDER}"/WRFDA/WRF" ];
	then
	mv -f "${WRF_FOLDER}"/WRFDA/WRF "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	fi
	cd "${WRF_FOLDER}"/WRFDA/WRFV${WRF_VERSION}
	mv * "${WRF_FOLDER}"/WRFDA
	cd "${WRF_FOLDER}"/WRFDA
	rm -rf WRFV${WRF_VERSION}/
	export NETCDF=$DIR/NETCDF
	export HDF5=$DIR/grib2
	export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
	export WRFPLUS_DIR="${WRF_FOLDER}"/WRFPLUS
	./clean -a
	if [ ${auto_config} -eq 1 ];
	then
	echo 18 | ./configure 4dvar 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	else
	./configure 4dvar 2>&1 | tee configure.log #Option 18 for gfortran/gcc and distribunted memory
	fi
	echo " "
	./compile all_wrfvar 2>&1 | tee compile.wrf4dvar.log
	echo " "
	# IF statement to check that all files were created.
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	echo "Missing one or more expected files."
	echo "Running compiler again"
	cd "${WRF_FOLDER}"/WRFDA
	./compile -j $CPU_QUARTER_EVEN all_wrfvar 2>&1 | tee compile.chem.wrfvar2.log
	cd "${WRF_FOLDER}"/WRFDA/var/da
	n=$(ls ./*.exe | wc -l)
	cd "${WRF_FOLDER}"/WRFDA/var/obsproc/src
	m=$(ls ./*.exe | wc -l)
	if ((($n == 43) && ($m == 1)));
	then
	echo "All expected files created."
	read -r -t 5 -p "Finished installing WRFDA. I am going to wait for 5 seconds only ..."
	else
	read -r -p "Please contact script authors for assistance, press 'Enter' to exit script."
	#exit
	fi
	fi
	echo " "
	echo " "
	######################## Static Geography Data inc/ Optional ####################
	# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	# These files are large so if you only need certain ones comment the others off
	# All files downloaded and untarred is 200GB
	# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
	#################################################################################
	cd "${WRF_FOLDER}"/Downloads
	mkdir "${WRF_FOLDER}"/GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG
	echo " "
	echo "Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
	tar -xvzf geog_high_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
	tar -xvzf geog_low_res_mandatory.tar.gz -C "${WRF_FOLDER}"/GEOG/
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG_LOW_RES/ "${WRF_FOLDER}"/GEOG/WPS_GEOG
	if [ ${WPS_Specific_Applications} -eq 1 ];
	then
	echo " "
	echo " WPS Geographical Input Data Mandatory for Specific Applications"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
	tar -xvzf geog_thompson28_chem.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
	tar -xvzf geog_noahmp.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
	tar -xvzf irrigation.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	mkdir "${WRF_FOLDER}"/GEOG/WPS_GEOG/irrigation
	mv "${WRF_FOLDER}"/GEOG/WPS_GEOG/fao "${WRF_FOLDER}"/GEOG/WPS_GEOG/irrigation
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
	tar -xvzf geog_px.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
	tar -xvzf geog_urban.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
	tar -xvzf geog_ssib.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
	tar -xvf lake_depth.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2
	tar -xvf topobath_30s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
	tar -xvf gsl_gwd.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/cglc_modis_lcz_global.tar.gz
	tar -xvf cglc_modis_lcz_global.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	if [ ${Optional_GEOG} -eq 1 ];
	then
	echo " "
	echo "Optional WPS Geographical Input Data"
	echo " "
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
	tar -xvzf geog_older_than_2000.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
	tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
	tar -xvzf geog_alt_lsm.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
	tar -xvf nlcd2006_ll_9s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
	tar -xvf updated_Iceland_LU.tar.gz -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
	tar -xvf modis_landuse_20class_15s.tar.bz2 -C "${WRF_FOLDER}"/GEOG/WPS_GEOG
	fi
	fi
# This script installs the WRFCHEM Tools with gnu or intel compilers.
####################################################################################################
	if [ "$WRFCHEM_TOOLS" = "1" ]; 
	then
	if [ "$Ubuntu_64bit_GNU" = "1" ] && [ "$WRFCHEM_PICK" = "1" ];
	then
	echo $PASSWD | sudo -S sudo apt install git
	cd $HOME
	cd weather-ai
	chmod 775 *.sh
	./weather-ai-tools.sh $PASSWD $Ubuntu_64bit_GNU
	cd $HOME
	fi
	if [ "$Ubuntu_64bit_Intel" = "1" ] && [ "$WRFCHEM_PICK" = "1" ];
	then
	echo $PASSWD | sudo -S sudo apt install git
	cd $HOME
	cd weather-ai
	chmod 775 *.sh
	./weather-ai-tools.sh $PASSWD $Ubuntu_64bit_Intel
	cd $HOME
	fi
	if [ "$macos_64bit_GNU" = "1" ] && [ "$WRFCHEM_PICK" = "1" ];
	then
	brew install git
	cd $HOME
	cd weather-ai
	chmod 775 *.sh
	./weather-ai-tools.sh $PASSWD $macos_64bit_GNU
	cd $HOME
	fi
	if [ "$RHL_64bit_GNU" = "1" ] && [ "$WRFCHEM_PICK" = "1" ];
	then
	echo $PASSWD | sudo -S sudo dnf install git
	cd $HOME
	cd weather-ai
	chmod 775 *.sh
	./weather-ai-tools.sh $PASSWD $RHL_64bit_GNU
	cd $HOME
	fi
	if [ "$RHL_64bit_GNU" = "2" ] && [ "$WRFCHEM_PICK" = "1" ];
	then
	echo $PASSWD | sudo -S sudo dnf install git
	cd $HOME
	cd weather-ai
	chmod 775 *.sh
	./weather-ai-tools.sh $PASSWD $RHL_64bit_GNU
	cd $HOME
	fi
	fi
##########################  Export PATH and LD_LIBRARY_PATH ################################
cd $HOME
#####################################BASH Script Finished##############################
end=$(date)
END=$(date +"%s")
DIFF=$(($END - $START))
echo "Install Start Time: ${start}"
echo "Install End Time: ${end}"
echo "Install Duration: $(($DIFF / 3600)) hours $((($DIFF % 3600) / 60)) minutes $(($DIFF % 60)) seconds"
