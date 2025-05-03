#!/usr/bin/env bash
cd /root/flashprint/
screen_name=$"flashprint"
presence=`screen -ls 2> /dev/null |grep flashprint |wc -l`
if [ $presence -eq 0 ]; then
 echo create screen $screen_name;
 screen -dmS $screen_name 2>/dev/null;
 cmd=$"python3 manage.py runserver 127.0.0.1:9088";
 screen -x -dmS $screen_name -p 0 -X stuff "$cmd"
 screen -x -dmS $screen_name -p 0 -X stuff $'\n'
else
 echo $screen_name exist.
fi
