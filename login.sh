#!/bin/bash

VERSION="1.4"

# verification of login.config
verify() {
    if grep -q "USERNAME" login.config && grep -q "PASSWORD" login.config; then
        return 0
    else
        return 1
    fi
}

# keepalive the connection
keepalive() {
    retry_count=0
    userid=$1
    kl=$2
    MAX_RETRIES=3

    while [ $retry_count -lt $MAX_RETRIES ]; do
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
            retry_count=$((retry_count+1))
            print "Error occured while"
            sleep 1
            continue
        else
            retry_count=0
        fi
        sleep 50
    done

    # Kill the bg process if can't connect after MAX_RETRIES
    if [ $retry_count -eq $MAX_RETRIES ]; then
        print "Process killed"
        exit 1
    fi

    exit 0
}

register() {
    echo "Enter your username: "
    read  USERNAME
    echo "Enter the Password: "
    read -s PASSWORD

    # Save USERNAME and PASSWORD in login.config
    echo "USERNAME=$USERNAME" > login.config
    echo "PASSWORD=$PASSWORD" >> login.config
    echo "EXIT_IF_NOT_CONNECTED=0" >> login.config

    print "User registered $USERNAME"
}

login_to_network() {
    # Checking for the SVNIT connection
    if ping -c 4 "172.16.1.1" &> /dev/null; then
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
        else
            echo "Connected to SVNIT network as $USERNAME"
        fi
        userid=$(echo $response | jq -r '.data.userid')
        k1=$(echo $response | jq -r '.data.k1')

        keepalive $userid $k1 &
        KEEPALIVE_PID=$!

        print "Keepalive process started with PID: $KEEPALIVE_PID"

    else
        if [ "$EXIT_IF_NOT_CONNECTED" = 1 ]; then
            exit 1
        fi
        echo "Couldn't find the SVNIT network"
    fi
}

logout(){
    curl -s -k -X POST "https://172.16.1.1:8090/index.php?pageto=fbo&operation=4&ms=ds78asdasd444b6rasda3&mes=ds78asdasd444b6rasda3" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Origin: https://172.16.1.1:8090" \
        -H "Referer: https://172.16.1.1:8090/" \
        -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        -H "sec-ch-ua: \"Not_A Brand\";v=\"8\", \"Chromium\";v=\"120\", \"Google Chrome\";v=\"120\""

    print "Logged out"
}

print(){
    local debug_value=${DEBUG:-0}
    if [ $debug_value -eq 1 ]; then
        echo "Debug: $1"
    fi
}

help(){
    echo "########################################################################"
    echo "                WI-JUNGLE LOGIN"
    echo "login: Log in to your account."
    echo "logout: Log out of your current session."
    echo "register: Register a new account. You will be prompted for a username and password"
    echo "whoami: Display the username of the currently logged in user."
    echo "restart: Restart the Network Manager."
    echo "version: Display the current version"
    echo "help: Display this help message."
    echo "clear: Clear the console screen."
    echo "exit: Exit the application."
    echo "########################################################################"
}

# main execution begins here

# initializing the configurations
if [ ! -f login.config ] || ! verify; then
    echo "Welcome to Wi_Jungle AutoLogin"
    echo "Please configure"
    register
    echo "Type help for list of commands"
fi

# Fetching the data from config file
source login.config

login_to_network

# Wait for user input
while true; do
    read -p "Enter command: " cmd
    if [ "$cmd" = "logout" ]; then
        # Kill the keepalive process
        kill "$KEEPALIVE_PID"
        logout
        echo "Logged out"

    elif [ "$cmd" = "login" ]; then
        login_to_network

    elif [ "$cmd" = "whoami" ]; then
        echo "You are logged in as $USERNAME"

    elif [ "$cmd" = "register" ]; then
        register
        echo "Successfully registered as $USERNAME"
        logout
        login_to_network

    elif [ "$cmd" = "restart" ]; then
        echo "Restarting the Network Manager"
        sudo systemctl restart NetworkManager

    elif [ "$cmd" = "status" ]; then
        echo "Pinging google.com"
        ping -c 4 "www.google.com" | grep 'packets transmitted' | awk -F', ' '{print "Transmitted: " $1 "\nReceived: " $2 "\nLost: " $3}'

    elif [ "$cmd" = "version" ]; then
        echo "Wi_Jungle AutoLogin $VERSION"

    elif [ "$cmd" = "help" ]; then
        help

    elif [ "$cmd" = "clear" ]; then
        clear
    
    elif [ "$cmd" = "exit" ]; then
        echo "Thank you"
        kill "$KEEPALIVE_PID"
        logout
        sleep 1
        clear
        exit 0

    else
        echo "Invalid command Type 'help' for list of commands"
    fi
done

