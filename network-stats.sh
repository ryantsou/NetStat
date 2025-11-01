#!/bin/bash

################################################################################
# Script: network-stats.sh
# Description: Bash script for monitoring and analyzing network statistics
# Author: Riantsoa RAJHONSON
# Version: 1.0
# Date: November 2025
################################################################################

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script version
VERSION="1.0"

# Function to display help message
show_help() {
    echo -e "${BLUE}NetStat - Network Statistics Monitor${NC}"
    echo -e "${YELLOW}Author: Riantsoa RAJHONSON${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i, --interface <name>    Specify network interface (e.g., eth0, wlan0)"
    echo "  -s, --stats               Display detailed packet statistics"
    echo "  -c, --connections         Show active network connections"
    echo "  -b, --bandwidth           Monitor bandwidth usage"
    echo "  -a, --all                 Display all available information"
    echo "  -h, --help                Show this help message"
    echo "  -v, --version             Display version information"
    echo ""
    echo "Examples:"
    echo "  $0 -i eth0                # Show stats for eth0"
    echo "  $0 --connections          # Display active connections"
    echo "  $0 --all                  # Show all information"
    echo ""
}

# Function to display version
show_version() {
    echo -e "${BLUE}NetStat version ${VERSION}${NC}"
    echo -e "${YELLOW}Author: Riantsoa RAJHONSON${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to display interface statistics
show_interface_stats() {
    local interface=$1
    
    echo -e "${GREEN}=== Network Interface Statistics ===${NC}"
    
    if command_exists ip; then
        if [ -n "$interface" ]; then
            echo -e "\n${BLUE}Interface: $interface${NC}"
            ip -s link show "$interface" 2>/dev/null || echo -e "${RED}Interface $interface not found${NC}"
        else
            echo -e "\n${BLUE}All Interfaces:${NC}"
            ip -s link show
        fi
    elif command_exists ifconfig; then
        if [ -n "$interface" ]; then
            echo -e "\n${BLUE}Interface: $interface${NC}"
            ifconfig "$interface" 2>/dev/null || echo -e "${RED}Interface $interface not found${NC}"
        else
            echo -e "\n${BLUE}All Interfaces:${NC}"
            ifconfig -a
        fi
    else
        echo -e "${RED}Error: Neither 'ip' nor 'ifconfig' command found${NC}"
        return 1
    fi
}

# Function to display packet statistics
show_packet_stats() {
    local interface=$1
    
    echo -e "${GREEN}=== Packet Statistics ===${NC}"
    
    if command_exists netstat; then
        echo -e "\n${BLUE}Interface Statistics:${NC}"
        if [ -n "$interface" ]; then
            netstat -i | grep -E "(Iface|$interface)"
        else
            netstat -i
        fi
    elif command_exists ss; then
        echo -e "\n${BLUE}Socket Statistics:${NC}"
        ss -s
    else
        echo -e "${RED}Error: Neither 'netstat' nor 'ss' command found${NC}"
        return 1
    fi
    
    # Display packet errors and drops
    if [ -n "$interface" ] && [ -f "/sys/class/net/$interface/statistics/rx_errors" ]; then
        echo -e "\n${BLUE}Error Statistics for $interface:${NC}"
        echo -e "RX Errors:  $(cat /sys/class/net/$interface/statistics/rx_errors)"
        echo -e "TX Errors:  $(cat /sys/class/net/$interface/statistics/tx_errors)"
        echo -e "RX Dropped: $(cat /sys/class/net/$interface/statistics/rx_dropped)"
        echo -e "TX Dropped: $(cat /sys/class/net/$interface/statistics/tx_dropped)"
    fi
}

# Function to display active connections
show_connections() {
    echo -e "${GREEN}=== Active Network Connections ===${NC}"
    
    if command_exists ss; then
        echo -e "\n${BLUE}Established Connections:${NC}"
        ss -tunapl state established 2>/dev/null || ss -tuna state established
        
        echo -e "\n${BLUE}Listening Ports:${NC}"
        ss -tunapl state listening 2>/dev/null || ss -tuna state listening
    elif command_exists netstat; then
        echo -e "\n${BLUE}Established Connections:${NC}"
        netstat -tunapl 2>/dev/null | grep ESTABLISHED || netstat -tuna | grep ESTABLISHED
        
        echo -e "\n${BLUE}Listening Ports:${NC}"
        netstat -tunapl 2>/dev/null | grep LISTEN || netstat -tuna | grep LISTEN
    else
        echo -e "${RED}Error: Neither 'ss' nor 'netstat' command found${NC}"
        return 1
    fi
}

# Function to monitor bandwidth
show_bandwidth() {
    local interface=$1
    
    echo -e "${GREEN}=== Bandwidth Usage ===${NC}"
    
    if [ -n "$interface" ]; then
        if [ -f "/sys/class/net/$interface/statistics/rx_bytes" ]; then
            local rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
            local tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
            
            echo -e "\n${BLUE}Interface: $interface${NC}"
            echo -e "Received:    $(numfmt --to=iec-i --suffix=B $rx_bytes 2>/dev/null || echo "$rx_bytes bytes")"
            echo -e "Transmitted: $(numfmt --to=iec-i --suffix=B $tx_bytes 2>/dev/null || echo "$tx_bytes bytes")"
        else
            echo -e "${RED}Error: Interface $interface not found${NC}"
            return 1
        fi
    else
        echo -e "\n${BLUE}All Interfaces:${NC}"
        for iface in /sys/class/net/*; do
            if [ -f "$iface/statistics/rx_bytes" ]; then
                local name=$(basename "$iface")
                local rx=$(cat "$iface/statistics/rx_bytes")
                local tx=$(cat "$iface/statistics/tx_bytes")
                
                echo -e "\n${YELLOW}$name:${NC}"
                echo -e "  RX: $(numfmt --to=iec-i --suffix=B $rx 2>/dev/null || echo "$rx bytes")"
                echo -e "  TX: $(numfmt --to=iec-i --suffix=B $tx 2>/dev/null || echo "$tx bytes")"
            fi
        done
    fi
}

# Function to display all information
show_all() {
    local interface=$1
    
    show_interface_stats "$interface"
    echo ""
    show_packet_stats "$interface"
    echo ""
    show_connections
    echo ""
    show_bandwidth "$interface"
}

# Main script logic
main() {
    local interface=""
    local show_stats=0
    local show_conn=0
    local show_bw=0
    local show_all_flag=0
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--interface)
                interface="$2"
                shift 2
                ;;
            -s|--stats)
                show_stats=1
                shift
                ;;
            -c|--connections)
                show_conn=1
                shift
                ;;
            -b|--bandwidth)
                show_bw=1
                shift
                ;;
            -a|--all)
                show_all_flag=1
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            *)
                echo -e "${RED}Error: Unknown option: $1${NC}"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Display header
    echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     NetStat - Network Statistics Tool     ║${NC}"
    echo -e "${BLUE}║   Author: Riantsoa RAJHONSON              ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
    echo ""
    
    # Execute based on options
    if [ $show_all_flag -eq 1 ]; then
        show_all "$interface"
    else
        # If no options specified, show basic interface stats
        if [ $show_stats -eq 0 ] && [ $show_conn -eq 0 ] && [ $show_bw -eq 0 ]; then
            show_interface_stats "$interface"
        else
            [ $show_stats -eq 1 ] && show_packet_stats "$interface" && echo ""
            [ $show_conn -eq 1 ] && show_connections && echo ""
            [ $show_bw -eq 1 ] && show_bandwidth "$interface" && echo ""
        fi
    fi
    
    echo -e "\n${GREEN}Statistics collection completed.${NC}"
}

# Run main function
main "$@"
