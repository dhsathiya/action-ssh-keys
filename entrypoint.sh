#!/bin/bash

# Install dependencies.
apt update && apt install git curl rsync -y

cd $GITHUB_WORKSPACE

# Create temp directory
SSH_TEMP=/SSH_TEMP
mkdir $SSH_TEMP

# SSH Keys setup.
function ssh_key_setup() {
    SSH_DIR="$HOME/.ssh"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    if [[ -n "$DEPLOY_KEY" ]]; then
        echo "$DEPLOY_KEY" | tr -d '\r' > "$SSH_DIR/id_rsa"
        chmod 600 "$SSH_DIR/id_rsa"
        eval "$(ssh-agent)"
        ssh-add "$SSH_DIR/id_rsa"
    else
        exit 1
    fi

    cat > /etc/ssh/ssh_config <<EOL
Host *
UserKnownHostsFile ${SSH_DIR}/known_hosts
IdentityFile ${SSH_DIR}/id_rsa
EOL
}

# SSH setup for known hosts
function add_known_hosts() {
    ssh-keyscan "${1##*@}" >> ${SSH_DIR}/known_hosts
}

ssh_key_setup

while IFS=, read -r host auth_path users; do
    mkdir $SSH_TEMP/$host

    add_known_hosts $host

    cat "$GITHUB_WORKSPACE/default.key" >> $SSH_TEMP/$host/authorized_keys

    IFS=',' read -r -a array <<< "$users"
    for user in ${array[@]}; do

        # Add the key in a temp file to check if it is a valid SSH key
        echo $user > /temp.ssh
        if $(ssh-keygen -l -f /temp.ssh ); then
            echo $user >> $SSH_TEMP/$host/authorized_keys
        else
            key=$(curl https://github.com/$user.keys)
            if [ "$key" != "" ] && [ "$key" != "Not Found" ]; then
                echo "$(curl https://github.com/$user.keys) $user" >> $SSH_TEMP/$host/authorized_keys
            fi
        fi
    done

    rsync -avzhP $SSH_TEMP/$host/authorized_keys $host:$auth_path
    rm -rf $SSH_TEMP/$host

done <<< $( tail -n +2 keys.csv )
