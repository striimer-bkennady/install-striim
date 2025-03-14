#!/bin/bash
################################################################################################
# DESCRIPTION: This bash script does the following:                                   	       #	 
# 1) Installs Java JDK (11).                                                                  #
# 2) Installs Striim.                                                                          # 
# 3) Sets up Striim configuration (startup.properties and runs sksConfig file).                #
# 4) Creates a single or multiple Initial Load application(s). (Optional)		       #
# 5) Enables/Starts Striim dbms and node.                                                      #
#                                                                                              # 
# PRE-REQUISITE:                                                                               #
# 1) This script is only for Ubuntu, CentOS, Amazon Linux, Debian, Suse and RedHat operating   #
#    system. 										       #
# 2) Need to export your license information (example shown below) as environment variables    # 
#    before executing this script.                                                             # 
#                                                                                              #
# For example:                                                                                 #
# export license_key=<value>                                                                   #
# export product_key=<value>                                                                   #
# export cluster_name=<value>                                                                  #
# export company_name=<value>                                                                  #
# export total_memory=<value>                                                                  #
# (Optional) export striim_version=<value> Note: You only need to set this env var if you      #
#                                                want to install a previous version of Striim  #
################################################################################################
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

if [ -d "/opt/striim/" ]; then
    echo "${RED}ERROR: The /opt/striim/ directory already exists. Script cannot be run again.${NC}" 1>&2
    echo "${RED} If you intend to reinstall Striim or upgrade to a new version, please execute the 'striim-uninstall.sh' script before running 'striim-install.sh'. ${NC}" 1>&2
    exit 1
fi

# Function to display error message and exit
exit_with_error() {
    echo -e "${RED}ERROR: $1${NC}" 1>&2
    exit 1
}

# Check to see if environment variables are set to configure startup.properties file
if [[ -z "$company_name" ]]; then
    exit_with_error "Must provide company_name in environment"
elif [[ -z "$cluster_name" ]]; then
    exit_with_error "Must provide cluster_name in environment"
elif [[ -z "$license_key" ]]; then
    exit_with_error "Must provide license_key in environment"
elif [[ -z "$product_key" ]]; then
    exit_with_error "Must provide product_key in environment"
elif [[ -z "$total_memory" ]]; then
    exit_with_error "Must provide total_memory in environment"
elif [[ -z "$striim_version" ]]; then
    exit_with_error "Must provide $striim_version in environment"
fi

echo "Download Striim version $striim_version"

startup_config=/opt/striim/conf/startUp.properties
echo "######################"
echo "# Welcome to Striim! #"
echo "######################"

echo "Please answer the following to get started with the installation process."
echo "Which operating system are you using? (amazon, centos, redhat, ubuntu, suse or debian)"
read os

if [ $os == 'ubuntu' ] || [ $os == 'debian' ];
then	
	# Install Striim
    echo "${GREEN} Checking Striim Version ${striim_version} ${NC}"

    if [ ! -f "striim-dbms-$striim_version-Linux.deb" ]; then
        exit_with_error "Missing striim-dbms-$striim_version-Linux.deb package in the current directory"
    fi
    if [ ! -f "striim-node-$striim_version-Linux.deb" ]; then
        exit_with_error "Missing striim-node-$striim_version-Linux.deb package in the current directory"
    fi

	sudo dpkg -i striim-dbms-$striim_version-Linux.deb ||
        exit_with_error "Failed to install striim-dbms package"
	sudo dpkg -i striim-node-$striim_version-Linux.deb ||
        exit_with_error "Failed to install striim-node package"
	sudo apt-get install bc -y ||
        exit_with_error "Failed to install bc package"

elif [ $os == 'centos' ] || [ $os == 'redhat' ] || [ $os == 'amazon' ] || [ $os == 'suse' ];
then
	echo "${GREEN} Checking Striim Version $striim_version ${NC}"

    if [ ! -f "striim-dbms-$striim_version-Linux.rpm" ]; then
        exit_with_error "Missing striim-dbms-$striim_version-Linux.rpm package in the current directory."
    fi
    if [ ! -f "striim-node-$striim_version-Linux.rpm" ]; then
        exit_with_error "Missing striim-node-$striim_version-Linux.rpm package in the current directory"
    fi

  # Install dbms package
  sudo rpm -ivh striim-dbms-$striim_version-Linux.rpm ||
        exit_with_error "Failed to install striim-dbms package"
	
	# Installing bc package 
	if [ $os == 'suse' ];
	then
	    sudo zypper install -y bc ||
            exit_with_error "Failed to install bc package"
	else
	    sudo yum install bc -y ||
            exit_with_error "Failed to install bc package"
	fi
	
	sudo rpm -ivh striim-node-$striim_version-Linux.rpm ||
        exit_with_error "Failed to install striim-node package \n Storage Space Size: $(df -h /opt | awk 'NR==2 {print $2}') \n Used Space: $(df -h /opt | awk 'NR==2 {print $3}') \n Preferred Storage Size for Striim: 100.0G"
else
	exit_with_error "Wrong selection. Please enter either amazon, debian, ubuntu, centos or redhat."
fi

# Install Java JDK (11)
echo "${GREEN} Install Java JDK 11 ${NC}"
curl -0 -L https://striim-download.s3.us-west-1.amazonaws.com/jdk-11.0.24_linux-x64_bin.tar.gz --output jdk-11.0.24_linux-x64_bin.tar.gz ||
    exit_with_error "Failed to download Java JDK package"
mkdir -p /usr/lib/jvm
tar zxvf jdk-11.0.24_linux-x64_bin.tar.gz -C /usr/lib/jvm
chmod -R 755 /usr/lib/jvm
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk-11.0.24/bin/java" 1
update-alternatives --set java /usr/lib/jvm/jdk-11.0.24/bin/java

if [ -d "/opt/striim/lib" ]
then
   # Installing MySQL/MariaDB Driver
   curl -0 https://srdanbucket.s3.amazonaws.com/Jars/mysql-connector-java-8.0.28.jar --output /opt/striim/lib/mysql-connector-java-8.0.28.jar
fi

if [ -d "/opt/striim/bin" ]
then
    # Setup Striim's credentials
    echo "${GREEN} Setup Striim Credentials ${NC}"
    sudo su - striim /opt/striim/bin/sksConfig.sh

    sed -i 's/WAClusterName=/'"WAClusterName=$cluster_name"'/' $startup_config
    sed -i 's/CompanyName=/'"CompanyName=$company_name"'/' $startup_config
    sed -i 's/# ProductKey=/'"ProductKey=$product_key"'/' $startup_config
    sed -i 's/# LicenceKey=/'"LicenceKey=$license_key"'/' $startup_config

    echo "${GREEN} Successfully updated startup.properties file ${NC}"
    
    # Allocate memory to Striim server

    gb_mem_max=$(echo "scale=1; 70/100 * $total_memory " | bc -l | xargs printf "%.0f")
    mb_mem_max=$(echo "scale=1; 1024 * $gb_mem_max " | bc -l )
    sed -i 's/# MEM_MIN=1024m/'"MEM_MIN=1024m"'/' $startup_config
    sed -i 's/# MEM_MAX=4096m/'"MEM_MAX=${mb_mem_max}m"'/' $startup_config
    sed -i 's/# MaxHeapUsage=95/'"MaxHeapUsage=95"'/' $startup_config

   
    # Start and enable Striim dbms and node

    sudo systemctl enable striim-dbms
    sudo systemctl start striim-dbms
    sleep 5
    sudo systemctl enable striim-node
    sudo systemctl start striim-node
    echo "${GREEN} Successfully started Striim node and dbms ${NC}"
    
    # Verify instance is running
    sudo tail -F /opt/striim/logs/striim/striim-node.log
else
    exit_with_error "Striim installation failed. Please check logs."
fi
