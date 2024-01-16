#!/bin/bash

sub_help()
{
  echo "Usage: $0 --enable|-e -> this will enable maintenance mode on all hyperscale nodes"
  echo "       $0 --disable|-d -> this will disable maintenance mode on all hyperscale nodes"
  echo "       $0 --help|-h"
}

checkcommvault()
{
#*************************************
#get commvault base
#*************************************
cvltbase=`commvault status | grep -i "home direc" | cut -d ' ' -f5`
if [ $? -ne 0 ]
then
  echo "CommVault Agent is not installed"
  exit
fi
qlogin=$cvltbase/qlogin
qlogout=$cvltbase/qlogout
qoperation=$cvltbase/qoperation
qlist=$cvltbase/qlist

}

commvaultlogin() {
#*******************************
#qlogin
#*******************************
cvuser="*********"
cvhost="*********"
hsnodes=` cat /root/hyperscalenodes.txt `

$qlogin -cs $cvhost
if [ $? -ne 0 ]
then
        echo "CommVault Login failed."
       exit
fi
}

set_maint_mode() {
        for i in $hsnodes
                do
                        if [ $1 = 0 ]
                        then
                                $qoperation execscript -sn setMediaAgentProperty -si $i -si 8 -si 0
                        elif [ $1 = 1 ]
                        then
                                $qoperation execscript -sn setMediaAgentProperty -si $i -si 8 -si 1
                        fi
        done
}

enablemode=0
disablemode=0
checkmode=0

while [ $1 ]
  do
    case $1 in
      -h|--help)
        sub_help
        exit 0
        ;;
      -e|--enable)
      shift
      enablemode=1
      ;;
      -d|--disable)
      shift
      disablemode=1
      ;;
      -c|--check)
      shift
      checkmode=1
      ;;
    esac
    shift
done

checkcommvault
commvaultlogin
if [ $enablemode = 1 ]
then
        set_maint_mode 1
elif [ $disablemode = 1 ]
then
        set_maint_mode 0
elif [ $checkmode = 1 ]
then
        echo "check mode"
else
        echo "failed to run"
        set_maint_mode
fi

$qlogout
