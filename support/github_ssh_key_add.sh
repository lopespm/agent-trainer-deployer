# Add GitHub to the list of authorized hosts:
ssh-keyscan github.com > ~/.ssh/known_hosts

# Add SSH key for accessing private repositories
eval "$(ssh-agent -s)"; ssh-add ~/.ssh/${GITHUB_SSH_KEY_NAME}
