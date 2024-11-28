#!/bin/bash

# Function to get RAM usage
get_ram_usage() {
    total=$(free -m | awk '/^Mem:/ {print $2}')
    used=$(free -m | awk '/^Mem:/ {print $3}')
    percent=$(echo "scale=2; $used * 100 / $total" | bc)  # Floating-point division
    echo "$percent"
}

# Function to get CPU usage
get_cpu_usage() {
    usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "$usage"
}

# Function to generate a bar
generate_bar() {
    percent=$1
    bar=""
    i=1
    while [ $(echo "$i <= $percent / 10" | bc) -eq 1 ]; do  # Use bc for floating-point comparison
        bar="${bar}█"
        i=$((i + 1))
    done
    while [ $(echo "$i <= 10" | bc) -eq 1 ]; do
        bar="${bar}░"
        i=$((i + 1))
    done
    echo "$bar"
}

# Function to display usage with color
display_usage() {
    usage=$1
    bar=$2
    type=$3

    # Determine color based on usage
    if [ $(echo "$usage < 50" | bc) -eq 1 ]; then
        color="\033[1;32m"  # Green
    elif [ $(echo "$usage < 80" | bc) -eq 1 ]; then
        color="\033[1;33m"  # Yellow
    else
        color="\033[1;31m"  # Red
    fi

    # Reset color
    reset="\033[0m"

    # Display the usage indicator
    echo -e "$type Usage: ${color}${usage}% [${bar}]${reset}"
}

# Get the current RAM and CPU usage
ram_usage=$(get_ram_usage)
cpu_usage=$(get_cpu_usage)

# Generate the bar for RAM and CPU
ram_bar=$(generate_bar "$ram_usage")
cpu_bar=$(generate_bar "$cpu_usage")

# Display the RAM and CPU usage
display_usage "$ram_usage" "$ram_bar" "RAM"
display_usage "$cpu_usage" "$cpu_bar" "CPU"

