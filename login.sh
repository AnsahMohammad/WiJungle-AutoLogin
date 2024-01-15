#!/bin/bash

# Login to SVNIT network

# Fetching the data from config file
source login.config

# Checking for the SVNIT connection
if ping -c 1 "172.16.1.1" &> /dev/null; then
    echo "Connecting to SVNIT network"

    curl -k -X POST "https://172.16.1.1:8090/index.php?pageto=c&ms=ds78asdasd444b6rasda3&mes=ds78asdasd444b6rasda3" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Origin: https://172.16.1.1:8090" \
        -H "Referer: https://172.16.1.1:8090/" \
        -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        -H "sec-ch-ua: \"Not_A Brand\";v=\"8\", \"Chromium\";v=\"120\", \"Google Chrome\";v=\"120\"" \
        --data-urlencode "fixeduserid=$USERNAME" \
        --data-urlencode "loginMethod=6" \
        --data-urlencode "password=$PASSWORD" \
        --data-urlencode "portal=1" \
        --data-urlencode "stage=9"
    
    echo "Connected to SVNIT network"
else
    echo "Couldn't find the SVNIT network"
fi


