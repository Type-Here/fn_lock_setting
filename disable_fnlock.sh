#!/bin/bash

# Fix the Asus dysfunctional FN key on Linux. 2023-10-13;
# Original from Mint Forum: https://forums.linuxmint.com/viewtopic.php?t=368164
# Mod by type-here

# It NEEDS SUDO permission!

FNLOCK="";
MNFCTR="";
CGFILEP="";
MNF="";
E="\n** $MNFCTR $FNLOCK";
F=" **\n"
VALUE=N

set_variables(){
    #Find if Linux or Mac Machines with uname. Others not supported
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     MACHINE=Linux;;
        Darwin*)    MACHINE=Mac;;
        CYGWIN*)    MACHINE=Cygwin;;
        MINGW*)     MACHINE=MinGw;;
        MSYS_NT*)   MACHINE=Git;;
        *)          MACHINE="UNKNOWN:${unameOut}"
    esac

    # Set MNF Var = Manufacturer
    case "$MACHINE" in
        Linux*) MNF=$(sudo dmidecode -s system-manufacturer);;
        Darwin*) MNF=Apple;;
        *) echo " Script not supported on your machine. Exiting... "; exit 1;;
    esac
    
    # Set Variable Based on Manufacturer
    case "$MNF" in
        *"ASUS"*)
        MNFCTR=asus_wmi;
        CGFILEP=/etc/modprobe.d/set_fn_lock.conf;
        FNLOCK=fnlock_default;
        E="\n** $MNFCTR $FNLOCK";
        ;;

        *"Apple"*)
        MNFCTR=hid_apple;
        CGFILEP=/etc/modprobe.d/hid_apple.conf;
        FNLOCK=fnmode;
        E="\n** $MNFCTR $FNLOCK";
        ;;
    esac
}

# Show Help Menu
show_help(){
    echo "-h | --help : see this help"
    echo "-d | --disable : disable fn_lock (permanent)"
    echo "-e | --enable : enable fn_lock (permanent)"
    echo "-t : temporary disable fn_lock (Not reccomended, still buggy)"
}

# Set Temporary changes. Only OFF. You should manually update module
temporary_change(){
    case $MNF in 
        *"Apple"*) VALUE=0;;
        *) VALUE=N;;
    esac   
    echo "${VALUE}" | sudo tee /sys/module/"${MNFCTR}"/parameters/"${FNLOCK}"
    echo "Temporary change made. You have to reload module manually."
}

# Core Function
change_fn(){
    #Set Paths and Variables based on Manufacturer
    set_variables;

    
    if [ $# -ge 0 ] && [ "$1" == "Y" ]; then
        case $MNF in 
        *"Apple"*) VALUE=1;;
        *) VALUE=Y;;
        esac
    else
        case $MNF in 
        *"Apple"*) VALUE=0;;
        *) VALUE=N;;
        esac    
    fi

    if [ -f /sys/module/$MNFCTR/parameters/$FNLOCK ]; then
        echo "Module Found. Checking for conf files..."
        
        #Option Setting to export
        OPT="options $MNFCTR ${FNLOCK}"
        
        # Update if Config File Already Exists
        if [ -f "$CGFILEP" ]; then
            echo "Configuration File Found. Overriding..."

            # Alternative solution (doesn't work yet, but should)
            #sudo sed "/^${OPT}=/{h;s/=.*/=${VALUE}/};\${x;/^$/{s//${OPT}=${VALUE}/;H};x}" "${CGFILEP}"

            # Partially works but it doesn't substitute value.
            #sudo awk -i inplace -v opt="$OPT" -v value="$VALUE" 'gsub("^" opt "=", opt "=" value)' "$CGFILEP"

            #WORKS
            sudo sed -i -e "/^${OPT}=/s/.*/${OPT}=${VALUE}/" "$CGFILEP"

            echo -e "\nPlease WAIT ...\n"

            # Not supported by all linux distros, better reboot
            #sudo update-initramfs -u -k all

            echo -e "$E UPDATED NOW $F"
            echo " PLEASE REBOOT. "
            exit 0;
        else
        # Creating a New Conf File
            echo "Configuration File NOT Found. Creating and Setting..."
            sudo touch "$CGFILEP" 
            echo -e "#Toggle $FNLOCK at boot (Y/N)\n${OPT}=${VALUE}\n" | sudo tee -a "$CGFILEP"
            echo -e "\nPlease WAIT ...\n"

            # Not supported by all linux distros, better reboot
            #sudo update-initramfs -u -k all

            echo -e "$E INSTALLED NOW $F"
            echo " PLEASE REBOOT. "
            exit 0;
        fi
    fi
    
    # If param is not found in /sys/module we can't do anything yet. Exits
    echo -e "Module Param: $E NOT FOUND$F"
    echo "Unable to Proceed. Exiting..."

    exit 1
}


#MAIN 

# Read Parameters 

if [ $# -eq 0 ]; then
    read -r -p "No parameters used. Default choice is to DISABLE Fn_Lock. Continue (Y/n)?" response
    case "$response" in
        [nN][oO]|[nN])
            exit 0;
            ;;
        *)
            change_fn N;
            ;;
    esac
elif [ "$1" == "-d" ] || [ "$1" == "--disable" ]; then
    change_fn N;
elif [ "$1" == "-e" ] || [ "$1" == "--enable" ]; then
    change_fn Y;
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help;
elif [ "$1" == "-t" ]; then
    temporary_change;
else
    echo "Non valid Option.";
    show_help;
fi

exit 0
#
