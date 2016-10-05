. ./support/github_ssh_key_constants.sh

#
# Copies and adds the SSH key (for GitHub authentication) to the remote server. Useful when cloning your private repositories
#

# Copies your GitHub SSH key the remote server
scp -i ${SSH_KEY_PATH} ${LOCAL_FOLDER_SSH_KEY}/${GITHUB_SSH_KEY_NAME} ${HOST_USERNAME}@${ip_address}:.ssh/${GITHUB_SSH_KEY_NAME}

