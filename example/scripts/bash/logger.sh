#!/bin/bash

ERROR='\e[0;31m'
SUCCESS="\e[0;32m"
WARNING="\e[0;33m"
INFO="\e[0;34m"
NONE="\e[0m"

log_info() {
    echo -e "${INFO}${1}${NONE}"
}

log_warn() {
    echo -e "${WARNING}${1}${NONE}"
}

log_err() {
    echo -e "${ERROR}${1}${NONE}"
}

log_success() {
    echo -e "${SUCCESS}${1}${NONE}"
}

log_none() {
    echo -e "${NONE}${1}${NONE}"
}