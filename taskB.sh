#!/bin/bash

function ListRunningProcesses () {
    echo "The list of Running Processes are :"
    ps aux
    
}

function ProcessInformation () {
# Prompt user for PID input
echo "Enter the PID of the process:"
read pid

# Check if the provided PID exists
if ! ps -p $pid > /dev/null; then
    echo "Process with PID $pid does not exist."
    return 1
fi

# Get information about the process
echo "Process Information for PID $pid:"

echo -n "PID: "
ps -o pid= -p $pid

echo -n "Parent PID (PPID): "
ps -o ppid= -p $pid

echo -n "User: "
ps -o user= -p $pid

echo -n "CPU Usage (%): "
ps -o %cpu= -p $pid

echo -n "Memory Usage : "
ps -o rss= -p $pid

# Command used to start the process
echo -n "Command: "
ps -o cmd= -p $pid
 InteractiveMode
}
function KillProcess () {
    # Prompt user for PID input
echo "Enter the PID of the process:"
read pid

# Check if the provided PID exists
if ! ps -p $pid > /dev/null; then
    echo "Process with PID $pid does not exist."
    return 1
fi
   sudo kill -9 $pid
   echo "Process with PID $pid has been successfully terminated"
}
function ProcessStatistics () {
    echo "Process Statistics:"
   
    total_processes=$(ps -e | wc -l)
    echo "Total Number of Processes: $((total_processes - 1))"  # subtract 1 to exclude the header

    memory_usage=$(free -m | awk 'NR==2{print $3}')
    echo "Memory Usage: ${memory_usage}MB )"

    cpu_load=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "CPU Load: ${cpu_load}%"

     InteractiveMode
}

function SearchAndFilter() {
    echo "Search and Filter Processes:"
    echo "Enter the criteria number:"
    echo "1. Search by Name"
    echo "2. Search by User"
    echo "3. Search by Memory Usage"
    echo "4. Search by CPU Usage"
    read criteria_number

    case $criteria_number in
        1)
            echo "Enter the process name"
            read name
            echo "Searching for processes with name: $name"
            ps aux | grep  "$name"
            ;;
        2)
            echo "Enter the username:"
            read username
            echo "Filtering processes owned by user: $username"
             ps aux | grep  "$username"
           
            ;;
        3)
            echo "Enter the resource usage to filter processes:"
            read threshold
            echo "Filtering processes with memory usage greater than $threshold MB"
            ps aux --sort -rss | awk -v threshold="$threshold" '$6 > threshold {print}'
            ;;
        4)
            echo "Enter the CPU usage threshold (in %) to filter processes:"
            read threshold
            echo "Filtering processes with CPU usage greater than $threshold%"
            ps aux --sort -%cpu | awk -v threshold="$threshold" '$3 > threshold {print}'
            ;;
        *)
            echo "Invalid criteria number."
            ;;
    esac
    InteractiveMode
}
function InteractiveMode  () {
   echo "The menu of operations"
    echo "Enter the operation number:"
    echo "1.List Running Processes"
    echo "2.Process Information"
    echo "3. Kill a Process"
    echo "4. Process Statistics"
    echo "5. Search and Filter"
    echo "6. Resource Usage Alerts"
    read operation_number
    case "${operation_number}" in
        1)
            ListRunningProcesses
        ;;
        2)
            ProcessInformation
        ;;
        3)
            KillProcess
        ;;
        4)
           ProcessStatistics
        ;;
        5)
           SearchAndFilter
        ;;
         6)
            ResourceUsageAlerts
        ;;
        
        *)
            echo "Invalid operation number"
        ;;
    esac
}
function ResourceUsageAlerts() {
    declare threshold_cpu=5  # CPU threshold in percentage
    declare threshold_mem=70 # Memory threshold in percentage

     #Check for processes exceeding memory threshold
    memory_usage=$(ps aux --sort -%mem | awk -v threshold="$threshold_mem" '$4 > threshold {print}')

    if [[ -n "$memory_usage" ]]; then
        echo "Alert: High Memory Usage"
        notify-send "Alert: High Memory Usage"
    fi

    # Check for processes exceeding CPU threshold
    cpu_usage=$(ps aux --sort -%cpu | awk -v threshold="$threshold_cpu" '$3 > threshold {print}')
    if [[ -n "$cpu_usage" ]]; then
        echo "Alert: High CPU Usage"
        notify-send "Alert: High CPU Usage"
    fi
    InteractiveMode
    }

InteractiveMode



