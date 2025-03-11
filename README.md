# Striim Installation
  
## Steps to install and configure Striim 5.x with Java (11).


### Linux OS Installation
[Windows Instructions](#windows-installation)

**Virtual Machine Configuration:** Please set up your VM with the subsequent specifications: 16 cores/CPU, 32 GB of RAM, and 100 GB of storage. Additionally, ensure that ports 9080 and 9081 are open in your VM.

1) Connect to your VM and install Git by running this command:
    - CentOS, Amazon Linux 2, and RedHat: 
        - `sudo yum update -y`
        - `sudo yum install git -y`
    - Ubuntu, and Debian: 
        - `sudo apt-get update -y`
        - `sudo apt-get install git-all -y`

2) Change to root user by running this command: `sudo su -`

3) Export your license key, product key, company name, total memory, and cluster name as environment variables to configure Striim.
    - For example:
      - `export company_name=Striim`
      - `export license_key=12345676`
      - `export product_key=12345566`
      - `export total_memory=16`
      - `export cluster_name=Striim_cluster`
      - `export striim_version=5.0.6` Note: This must match the version of Striim you have downloaded during step 6
      
4) Clone this repository in the home directory: `git clone https://github.com/striimer-bkennady/install-striim.git`

5) Change directory to `striim-installs/install/`.
   ```commandline
      cd install-striim/install/
   ```

6) Download the Striim packages from the Downloads page on the [Striim Support Site](https://support.striim.com/hc/). 
    Copy these files into the install-striim/install/ directory.
   - Ubuntu & Debian
     - Download the striim-dbms and striim-node .deb packages
   - Centos, Redhat, Amazon, Suse
     - Download the striim-dbms and striim-node .rpm packages
   - Windows
     - See installation instructions below

7) Execute striim-install.sh script: 
   ```commandline
      ./striim-install.sh
   ```

8) After the script installs Java and Striim, it will show a prompt for you to set your KeyStore, sys and admin user password. 
    - Note: You will login to Striim console with the admin credentials you enter in this step.
   
9) Select '1' or 'Derby' when it asks you to enter the MDR Types.
            
10) Wait until you get an output message like the following:
Please go to http://10.1.2.3.4:9080 or https://10.1.2.3.4:9081 to administer, or use console

11) Grab your instance public IP and type the following to your browser: <public-ip>:9080

If you don't see striim console up and running in your browser, make sure your instance has port 9080 open and your network is configured correctly.

### Windows Installation
1) **Register** on this page and download the latest TGZ file and Windows Service Package file: [https://support.striim.com/hc/en-us/articles/229277848-Download-of-Latest-Version-of-Striim](https://support.striim.com/hc/en-us/articles/229277848-Download-of-Latest-Version-of-Striim)
2) Unzip Striim TGZ file into your chosen installation directory
3) Navigate to https://striim-downloads.striim.com/Releases/<striim_latest_version>/Striim_windowsService_<striim_latest_version>.zip to download the Window server package
4) Unzip the Windows server package into the `striim/conf` directory from prior step
5) Follow this document to finish the Striim installation: [https://www.striim.com/docs/platform/en/running-striim-in-microsoft-windows.html](https://www.striim.com/docs/platform/en/running-striim-in-microsoft-windows.html)
    
# Troubleshoot
To troubleshoot any data pipeline/application errors and/or view detailed error messages from your Striim app/components, please follow these steps to parse and generate the logs:
    
1) Access your Striim server terminal
    
2) Go to install-striim/log_finder/. **For example:** cd ./install-striim/log_finder/
    
3) Execute the striim_error_log_finder.sh shell script with the appropriate arguments.
**Format:** ./striim_error_log_finder <striim.server.log dir path and filename> <application name/application component name>
    
   **For example:**
   - To get ALL errors from your striim.server.log file: `sudo ./striim_error_log_finder.sh /opt/striim/logs/striim.server.log`
   - To get errors from an application: `sudo ./striim_error_log_finder.sh /opt/striim/logs/striim.server.log admin.test_app_striim`
   - To get errors from a source/target application component: `sudo ./striim_error_log_finder.sh /opt/striim/logs/striim.server.log admin.source_or_target_component`
    
 
4) The shell script will generate a custom log file. Once we get a confirmation that it was been created, please open the custom log file and analyze the error.
5) Find more details about logging in Striim [here](https://www.striim.com/docs/platform/en/logging.html)
