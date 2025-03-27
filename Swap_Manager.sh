#!/bin/bash

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Help
usage() {
    echo -e "${GREEN}Swap_Mnager${NC}"
    echo "Usage:"
    echo "  $0 [option] [parameter]"
    echo ""
    echo "option:"
    echo "  create <(MB)>      create new swap"
    echo "  modify <(MB)>      modify exist swap"
    echo "  delete            	delete all swap"
    echo "  status            	show swap status"
    exit 1
}

# check root permission
check_root() {
    if [[ $EUID -ne 0 ]]; then
       echo -e "${RED}error: please switch to root permission${NC}" 
       exit 1
    fi
}

# show swap status
show_swap_status() {
    echo -e "${GREEN}Swap Status:${NC}"
    free -h | grep Swap
    swapon --show
}

# create new swap
create_swap() {
    local swap_size=$1

    # check parameter
    if [[ -z "$swap_size" ]]; then
        echo -e "${RED}error: please input swap size(MB)${NC}"
        exit 1
    fi

    # create swap file
    fallocate -l "${swap_size}M" /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    # activate
    echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

    echo -e "${GREEN}Successfully created ${swap_size}MB swap${NC}"
}

# Modify swap size
modify_swap() {
    local new_size=$1

    # check parameter
    if [[ -z "$new_size" ]]; then
        echo -e "${RED}error: please input swap size(MB)${NC}"
        exit 1
    fi

    # delete swap
    swapoff -a
    sed -i '/swap/d' /etc/fstab
    rm /swapfile

    # create swap
    create_swap "$new_size"
}

# delete swap
delete_swap() {
    swapoff -a
    sed -i '/swap/d' /etc/fstab
    rm /swapfile

    echo -e "${GREEN}Successfully deleted all swap${NC}"
}

# Main
check_root

case "$1" in
    create)
        create_swap "$2"
        ;;
    modify)
        modify_swap "$2"
        ;;
    delete)
        delete_swap
        ;;
    status)
        show_swap_status
        ;;
    *)
        usage
        ;;
esac

exit 0
