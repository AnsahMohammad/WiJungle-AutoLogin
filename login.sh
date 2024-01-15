#!/bin/bash

# Login to SVNIT network

# initializing the configurations
if [ ! -f login.config ]; then
    echo "Enter your username: "
    read  USERNAME
    echo "Enter the Password: "
    read -s PASSWORD

    # Save USERNAME and PASSWORD in login.config
    echo "USERNAME=$USERNAME" > login.config
    echo "PASSWORD=$PASSWORD" >> login.config
fi

# Fetching the data from config file
source login.config

# keepalive the connection
keepalive() {
    userid=$1
    kl=$2
    while true; do
        sleep 50
        response=$(curl -s -k -X POST "https://172.16.1.1:8090/index.php?pageto=ka&ms=ds78asdasd444b6rasda3&mes=ds78asdasd444b6rasda3&u=$userid&k1=$kl&username=$USERNAME" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -H "Origin: https://172.16.1.1:8090" \
            -H "Referer: https://172.16.1.1:8090/" \
            -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
            -H "sec-ch-ua: \"Not_A Brand\";v=\"8\", \"Chromium\";v=\"120\", \"Google Chrome\";v=\"120\"" \
            -H "sec-ch-ua-mobile: ?0" \
            -H "sec-ch-ua-platform: \"Linux\"")

        status=$(echo $response | jq -r '.status')
        if [ "$status" = "fail" ]; then
            echo "Error occured while connecting to the network"
        fi

    done
}

login_to_network() {
    # Checking for the SVNIT connection
    if ping -c 1 "172.16.1.1" &> /dev/null; then
        echo "Connecting to SVNIT network"

        response=$(curl -s -k -X POST "https://172.16.1.1:8090/index.php?pageto=c&ms=ds78asdasd444b6rasda3&mes=ds78asdasd444b6rasda3" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -H "Origin: https://172.16.1.1:8090" \
            -H "Referer: https://172.16.1.1:8090/" \
            -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
            -H "sec-ch-ua: \"Not_A Brand\";v=\"8\", \"Chromium\";v=\"120\", \"Google Chrome\";v=\"120\"" \
            --data-urlencode "fixeduserid=$USERNAME" \
            --data-urlencode "loginMethod=6" \
            --data-urlencode "password=$PASSWORD" \
            --data-urlencode "portal=1" \
            --data-urlencode "stage=9")

        status=$(echo $response | jq -r '.status')
        if [ "$status" = "fail" ]; then
            echo "Error occured while connecting to the network"
        fi
        userid=$(echo $response | jq -r '.data.userid')
        k1=$(echo $response | jq -r '.data.k1')

        keepalive $userid $k1 &
        KEEPALIVE_PID=$!
    else
        echo "Couldn't find the SVNIT network"
        exit 1
    fi
}

logout(){
    curl -s -k -X POST "https://172.16.1.1:8090/index.php?pageto=fbo&operation=4&ms=ds78asdasd444b6rasda3&mes=ds78asdasd444b6rasda3" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Origin: https://172.16.1.1:8090" \
        -H "Referer: https://172.16.1.1:8090/" \
        -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        -H "sec-ch-ua: \"Not_A Brand\";v=\"8\", \"Chromium\";v=\"120\", \"Google Chrome\";v=\"120\""

}

# main execution begins here

login_to_network

# Wait for user input
while true; do
    read -p "Enter command: " cmd
    if [ "$cmd" = "logout" ]; then
        # Kill the keepalive process
        kill "$KEEPALIVE_PID"
        logout
        echo "Logged out"
        exit 0
    elif [ "$cmd" = "login" ]; then
        login_to_network
    elif [ "$cmd" = "help" ]; then
        echo "enter command 'login' to login to SVNIT network"
        echo "enter command 'logout' to logout from SVNIT network"
    else
        echo "Invalid command"
    fi
done

