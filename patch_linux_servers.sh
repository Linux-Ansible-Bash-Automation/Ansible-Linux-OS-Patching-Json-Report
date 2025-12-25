#!/bin/bash
set -o nounset 
set -o pipefail

# Define ANSI color codes using tput for portability
if command -v tput >/dev/null 2>&1; then
   GREEN=$(tput setaf 2)
   NC=$(tput sgr0)   # No Color
else
   GREEN='\033[0;32m'
   NC='\033[0m'
fi

#--- Configuration Variables ---
INVENTORY_FILE="hosts"
PLAYBOOK_FILE="patch_linux_servers_Json.yml"

# Initialize variables to avoid 'nounset' errors before they are assigned in functions
ANSIBLE_REMOTE_USER=""
BECOME_METHOD=""         # Used as extra-var 'play become method' (remote)
LOCAL_PREFIX_METHOD=""   # Used as the command prefix 'sudo or dzdo (Local)
REPORT_FILENAME=""

# --- Dynamically Generate User List ---
options_user=()
for i in {1..5}; do
    user_name=$(printf "aduser%02d" "$i")
    options_user+=("$user_name")
done 
options_user+=("sandeep")
options_user+=("ansible")
options_user+=("other")

# --- Interactive Menu Functions ---

# Function to choose the LOCAL command prefix
#choose_local_prefix() {
#    echo "--- Select Local Command Prefix (to run ansible-playbook) ---" 
#    options_prefix=("sudo" "dzdo")
#    PS3="Select the local command prefix (enter number): "

#    select opt_prefix in "${options_prefix[@]}"; do
#        case $opt_prefix in
#            "sudo"|"dzdo")
#                LOCAL_PREFIX_METHOD=$opt_prefix
#                break
#                ;;
#            *)
#                echo "Invalid option $REPLY. Try again."
#                ;;
#        esac
#    done
#}

# Function to choose the REMOTE become method (passed as an extra var)
choose_become_method() {
    echo "--- Select Remote Become Method (for tasks on target hosts) ---"
    options_become=("sudo" "dzdo")
    PS3="Select the remote become method (enter number):"
    
    select opt_become in "${options_become[@]}"; do
        case $opt_become in
            sudo|dzdo)
                BECOME_METHOD=$opt_become 
                break
                ;;
            *)
                echo "Invalid option $REPLY. Try again."
                ;;
        esac
    done
}

# Function to choose user (remains the same)
choose_user() {
    echo "--- Select Remote Ansible User ---"
    PS3="Select the remote Ansible user (enter number): "
    
    select opt_user in "${options_user[@]}"; do
    if [ "$opt_user" = "other" ]; then
        read -r -p "Enter custom username: " CUSTOM_USER
        if [ -n "$CUSTOM_USER" ]; then
            ANSIBLE REMOTEL USER=$CUSTOM_USER
            break
        else
            echo "Custom username cannot be empty."
        fi
        elif [ -n "$opt_user" ]; then
            ANSIBLE_REMOTE_USER=$opt_user 
            break
        else
            echo "Invalid option $REPLY. Try again."
        fi
    done
}

# 1. Call the functions to get inputs in desired order
choose_local_prefix #ASK For local first
choose_user
choose_become_method # Ask for remote second

# 3. Prompt for the Report Filename
read -r -p "Enter the full path for the consolidated report file (e.g., /tmp/patch_test.txt): " REPORT_FILENAME
if [ -z "$REPORT_FILENAME" ]; then 
     echo "Error: Report filename cannot be empty."
    exit 1
fi

# --- Construct the full Ansible command as an array --
# This command is run locally, prefixed by $LOCAL_PREFIX_METHOD
CMD=(
#  "$LOCAL_PREFIX_METHOD"
   ansible-playbook
  -i "$INVENTORY_FILE"
  -u "$ANSIBLE_REMOTE_USER"
  --ask-pass
  --become
  --become-method "$BECOME_METHOD"
  --ask-become-pass
  "$PLAYBOOK_FILE"
  --extra-vars "consolidated_report_path=$REPORT_FILENAME" 
)

echo "-----------------------------------------------------"
echo "Running Ansible Playbook with selected options:" 
echo "Local Prefix: ${GREEN}$LOCAL_PREFIX_METHOD${NC}"
echo "Remote User: ${GREEN}$ANSIBLE_REMOTE_USER${NC}"
echo "Remote Become Method: ${GREEN}$BECOME_METHOD${NC}"
echo "Report Path: ${GREEN}$REPORT_FILENAME${NC}"
echo "-----------------------------------------------------"

# --- Execute the command ---
if "${CMD[@]}"; then
    echo "Playbook finished successfully."
else
    echo "Playbook failed. Check the output above for errors."
    exit 1
fi
