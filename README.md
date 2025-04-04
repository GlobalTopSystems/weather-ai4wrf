### Citation:
---
### Global Top Systems (2025) Weather-AI software (Version 2.0.2.5) by B. Vasiliu:
"It is important to note that any usage or publication that incorporates or references this software, must include a proper citation to acknowledge the work of the author. This is not only a matter of respect and academic integrity, but also a requirement set by the author. Please ensure to adhere to this guideline when using this software.

CEO of Global Top Systems Company (Global Top Systems).
### Weather-AI: a HyperConvergent Infrastructure Appliance (HCIApp).
Modular and cross-platform tool for configuring and installing any OpenSource Meteorological Software (Computer software).

---
### Getting Started
Clone the repository
git clone https://github.com/GlobalTopSystems/weather-ai
 
---
### System Requirements
- 64-bit system
    - Darwin (MacOS)
    - Various Linux Distros (Ubuntu, Mint, CentOS, etc.)
    - WSL (CentOS 7,8 and 8,9 and 10 Streams , etc.) currently being tested
    - RHEL Systems (AlmaLinux, Fedora, RedHat, CentOS, etc.)
- <20 Gigabyte (GB) of free storage space

---
### CentOS 7, 8 Stream 
Installation (Make sure to download folder into your Home Directory):
> cd $HOME

> sudo (yum or dnf) install git -y

> git clone https://github.com/GlobalTopSystems/weather-ai.git

> cd $HOME/weather-ai

> chmod 775 *.sh

> ./weather-ai.sh 2>&1 | tee weather-ai.log
---
### Libraries Installed (Latest libraries as of 11/01/2023)
- Libraries are manually installed in sub-folders utilizing either Intel or GNU Compilers.
    - Libraries installed with GNU compilers
        - zlib (1.3.1)
        - MPICH (4.2.2)
        - libpng (1.6.39)
        - JasPer (1.900.1)
        - HDF5 (1.14.4.3)
        - PHDF5 (1.14.4.3)
        - Parallel-NetCDF (1.13.0)
        - NetCDF-C (4.9.2)
        - NetCDF-Fortran (4.6.1)
        - Miniconda
    - Libraries installed with Intel compilers
        - zlib (1.3.1)
        - libpng (1.6.39)
        - JasPer (1.900.1)
        - HDF5 (1.14.4.3)
        - PHDF5 (1.14.4.3)
        - Parallel-NetCDF (1.13.0)
        - NetCDF-C (4.9.2)
        - NetCDF-Fortran (4.6.1)
        - Miniconda
        - Intel-Basekit
        - Intel-HPCKIT
        - Intel-AIKIT

---
### Software Packages

### Run the Services
---
docker compose -f weather-ai.yaml up
docker compose -f weather-ai.yaml ps

---
