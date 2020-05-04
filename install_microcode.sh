#!/bin/bash
: '
Access to this file is granted under the SCONE COMMERCIAL LICENSE V1.0 

Any use of this product using this file requires a commercial license from scontain UG, www.scontain.com.

Permission is also granted  to use the Program for a reasonably limited period of time  (but no longer than 1 month) 
for the purpose of evaluating its usefulness for a particular purpose.

THERE IS NO WARRANTY FOR THIS PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING 
THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. 

THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, 
YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED ON IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY
MODIFY AND/OR REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, 
INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM INCLUDING BUT NOT LIMITED TO LOSS 
OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE 
WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

Copyright (C) 2020 scontain.com
'

set -e


function msg_color {
    priority=$1
    if [[ $priority == "fatal" ]] ; then
        echo -e "\033[31m"
    elif [[ $priority == "error" ]] ; then
        echo -e "\033[34m"
    elif [[ $priority == "warning" ]] ; then
        echo -e "\033[35m"
    elif [[ $priority == "info" ]] ; then
        echo -e "\033[36m"
    elif [[ $priority == "debug" ]] ; then
        echo -e "\033[37m"
    elif [[ $priority == "default" ]] ; then
        echo -e "\033[00m"
    else
        echo -e "\033[32m";
    fi
}

function no_error_message {
    exit $? 
}

function issue_error_exit_message {
    errcode=$?
    trap no_error_message EXIT
    if [[ $errcode != 0 ]] ; then
        msg_color "fatal"
        echo -e "ERROR: installation of microcode update failed (script=install_microcode.sh, Line: ${BASH_LINENO[0]})"
        msg_color "default"
    else
        msg_color "OK"
        echo "OK"
        msg_color "default"
    fi
    exit $errcode
}

OLDVER=$(dmesg | grep "microcode: microcode")

TMPDIR=$(mktemp -d)
cd $TMPDIR
git clone https://github.com/intel/Intel-Linux-Processor-Microcode-Data-Files.git
cd Intel-Linux-Processor-Microcode-Data-Files
sudo apt-get update
sudo apt-get install -y intel-microcode
if [ -f /sys/devices/system/cpu/microcode/reload ] ; then
    if [ -d /lib/firmware ] ; then
        mkdir -p OLD
        cp -rf /lib/firmware/intel-ucode OLD
        echo "Created a copy of current microcode (/lib/firmware/intel-ucode) in directory $TMPDIR/OLD"
        sudo cp -rf intel-ucode /lib/firmware
        echo "1" | sudo tee /sys/devices/system/cpu/microcode/reload
    else
        echo "Error: microcode directory does not exist"
    fi
else
    echo "Error: is intel-microcode package really installed?"
fi

NEWVER=$(dmesg | grep "microcode: microcode")

if [ "$OLDVER" == "$NEWVER" ] ; then
    msg_color "OK"
    echo "Already newest version of microcode installed: " $NEWVER
    msg_color "default"
else
    msg_color "info"
    echo "Updated microcode from version: " $OLDVER
    echo "                    to version: " $NEWVER
    msg_color "default"
fi
                         