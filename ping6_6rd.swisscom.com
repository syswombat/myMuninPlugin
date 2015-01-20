#!/bin/sh
#
# Description  : Plugin to monitor 6rd.swisscom.com .
# Author       : Vincent Kocher
# Author URL   : http://www.wombat.ch/munin
# Usage        : 
# Explaination : 
# Requirements :
# * ping6
##############################
# Modification by: Vincent Kocher / www.wombat.ch/munin
# Modification date/reason: 20.01.2015 / Ping 6RD Tunnel der Swisscom (Switzerland)
# ping -c 5 6rd.swisscom.com | sed '$!d;s|.*/\([0-9.]*\)/.*|\1|'
# ping -c 5 www.heise.de | tail -1| awk -F '/' '{print $5}'
##############################

target=`basename $0 | sed 's/^ping6_//g'`
item=`echo $target | sed -e 's/\.//g'`

#
# Config
#

if [ "$1" = "config" ]; then
  echo "graph_title ${target} availability"
  echo "graph_args --base 1000 -r -l 0 -u 100"
  echo "graph_vlabel Availability in %"
  echo "graph_category WAN"
  echo "graph_info Displays Network Availability"
  # Failure
  echo "failure.label Unreachable"
  echo "failure.draw AREA"
  echo "failure.colour ff0000"
  # Success
  echo "success.label Reachable"
  echo "success.draw STACK"
  echo "success.colour 00CC00CC"
  exit 0
fi

#
# Let's go!
#

fping -q $target
status=$?

if [ $status -eq 0 ]; then
    # Success
    echo "success.value 100"
    echo "failure.value 0"
else
    # Failure
    echo "success.value 0"
    echo "failure.value 100" 
fi
