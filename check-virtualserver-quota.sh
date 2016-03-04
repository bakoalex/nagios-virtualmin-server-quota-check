#!/bin/bash

usage ()
{
    echo 'Virtualmin virtual server quota check plugin for Nagios'
    echo 'Version v1.0.0'
    echo 'Arguments :  -d <domain> -t <type:server|user> -c <critical_threshold> -w <warning_threshold>'
    echo '	-d	domain: domain of the virtual serer to query (required)'
    echo '	-t	type (server|user): type of quoat to check, defaults to "server"'
    echo '	-c	critical threshold level: quota usage threshold for critical alert, in percent defaults to 95'
    echo '	-w	warning threshold level: quota usage threshold for warning alert, in percent defaults to 90'
    echo ''
    exit 3
}

while getopts ":d:t:c:w:" opt; do
  case $opt in
    d) DOMAIN="$OPTARG"
    ;;
    t) TYPE="$OPTARG"
    ;;
    c) LEVEL_CRITICAL="$OPTARG"
    ;;
    w) LEVEL_WARNING="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    usage
    ;;
  esac
done

if [ "$DOMAIN" == "" ]
then
    echo "Error: missing domain argument"
    usage
    exit 0;
fi

if [ "$TYPE" != "server" -a "$TYPE" != "user" ] 
then 
    TYPE="server" 
fi

if [ "$LEVEL_CRITICAL" == "" ] 
then 
    LEVEL_CRITICAL=95
fi

if [ "$LEVEL_WARNING" == "" ] 
then 
    LEVEL_WARNING=90
fi

serverinfoPattern=$( echo "$TYPE quota\|$TYPE quota used" | awk '{print tolower($0)}' )
totalPattern=$( echo "$TYPE quota: (\w*).*" | awk '{print tolower($0)}' )
usedPattern=$( echo "$TYPE quota used: (\w*).*" | awk '{print tolower($0)}' )
serverinfo=$( sudo virtualmin list-domains --domain "$DOMAIN" --multiline | grep -i "$serverinfoPattern" )

if [ "$serverinfo" == "" -o -z "${serverinfo// }" ]
then
    echo "UNKNOWN- Could not fetch virtual server data"
    exit 3;
fi

total=$( echo "$serverinfo" | grep -ioP "$totalPattern" | cut -d: -f2 | xargs )
used=$( echo "$serverinfo" | grep -ioP "$usedPattern" | cut -d: -f2 | xargs )
usedBytes=$( echo $used | sed -e 's/t/kg/i;s/g/km/i;s/m/kk/i;s/k/*1024/ig;s/b//i' | bc )
if [ "$total" != "Unlimited" ]
then 
    totalBytes=$( echo $total | sed -e 's/t/kg/i;s/g/km/i;s/m/kk/i;s/k/*1024/ig;s/b//i' | bc )
    usageRatio=$( bc -q -l <<< $usedBytes/$totalBytes | awk '{printf "%.4lf", $0}' )
    usagePercent=$( bc -q -l <<< $usageRatio*100 | awk '{printf "%.2lf", $0}')
else
    totalBytes=0
    usageRatio=0
    usagePercent=0
fi

output="$TYPE quota: $total, quota used: $used, usage ratio: $usagePercent% | "$TYPE"QuotaTotal=$totalBytes, "$TYPE"QutaUsed=$usedBytes, "$TYPE"QuotaUsageRatio=$usageRatio"

if [ "$total" == "Unlimited" ]
then
    echo "OK- $output"
elif [ $( bc -l <<< "$usagePercent>$LEVEL_CRITICAL" ) -eq 1 ]
then
    echo "CRITICAL- $output"
    exit 2
elif [ $( bc -l <<< "$usagePercent>$LEVEL_WARNING" ) -eq 1 ]
then
    echo "WARNING- $output"
    exit 1
else
    echo "OK- $output"
    exit 0
fi
