#!/bin/bash

# Function to display messages
msg() {
    echo -e "\n==================================="
    echo -e " $1"
    echo -e "===================================\n"
}

# Function to check if a package is installed
package_installed() {
    dpkg -l "$1" &> /dev/null
}

# Function to add a user with home directory and ssh keys
add_user() {
    username=$1
    pubkey_rsa="$2"
    pubkey_ed25519="$3"

    if ! id "$username" &> /dev/null; then
        useradd -m -s /bin/bash "$username"
        msg "User $username created."
    fi

    mkdir -p "/home/$username/.ssh"
    cat "/root/$pubkey_rsa" >> "/home/$username/.ssh/authorized_keys"
    cat "/root/$pubkey_ed25519" >> "/home/$username/.ssh/authorized_keys"
    chown -R "$username:$username" "/home/$username/.ssh"
    chmod 600 "/home/$username/.ssh/authorized_keys"
    msg "SSH keys added for user $username."
}

# Function to configure network interface
configure_network() {
    cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    ens3:
      addresses:
        - 192.168.16.21
EOF
    netplan apply
    msg "Network interface configured."
}

# Function to configure hosts file
configure_hosts() {
    sed -i '/192.168.16.21/s/^#//g' /etc/hosts
    sed -i '/192.168.16.20/d' /etc/hosts
    msg "Hosts file configured."
}

# Function to install required software
install_software() {
    if ! package_installed "apache2"; then
        apt update
        apt install -y apache2
        msg "Apache2 web server installed."
    fi

    if ! package_installed "squid"; then
        apt update
        apt install -y squid
        msg "Squid web proxy installed."
    fi
}

# Function to configure ufw firewall
configure_firewall() {
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow from 192.168.16.0/24 to any port 22
    ufw allow from 192.168.16.0/24 to any port 80
    ufw allow from 192.168.16.0/24 to any port 3128
    ufw --force enable
    msg "Firewall configured."
}

# Main script
msg "Starting assignment2.sh script..."

configure_network
configure_hosts
install_software
configure_firewall

# Add users
add_user "dennis" "dennis_rsa.pub" "dennis_ed25519.pub"
add_user "aubrey" "aubrey_rsa.pub" "aubrey_ed25519.pub"
add_user "captain" "captain_rsa.pub" "captain_ed25519.pub"
add_user "snibbles" "snibbles_rsa.pub" "snibbles_ed25519.pub"
add_user "brownie" "brownie_rsa.pub" "brownie_ed25519.pub"
add_user "scooter" "scooter_rsa.pub" "scooter_ed25519.pub"
add_user "sandy" "sandy_rsa.pub" "sandy_ed25519.pub"
add_user "perrier" "perrier_rsa.pub" "perrier_ed25519.pub"
add_user "cindy" "cindy_rsa.pub" "cindy_ed25519.pub"
add_user "tiger" "tiger_rsa.pub" "tiger_ed25519.pub"
add_user "yoda" "yoda_rsa.pub" "yoda_ed25519.pub"

# Configure sudo access for dennis
echo "dennis ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dennis
msg "sudo access configured for user dennis."

msg "Script execution completed."
