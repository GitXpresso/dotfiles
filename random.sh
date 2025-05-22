#!/bin/bash

# Script to GUIDE you in setting a permanent static IP on Arch Linux
# This script DOES NOT make changes itself. It provides instructions and
# configuration snippets based on your input and detected network manager.

echo "--------------------------------------------------------------------"
echo " Arch Linux Static IP Configuration Assistant"
echo "--------------------------------------------------------------------"
echo "This script will help you generate configurations for a static IP."
echo "You will need to manually apply these configurations."
echo "Ensure you have a way to revert changes if something goes wrong"
echo "(e.g., physical access to the machine, bootable USB)."
echo ""
echo "MAKE SURE TO BACK UP ANY EXISTING CONFIGURATION FILES BEFORE MODIFYING THEM."
echo ""

# Check for root privileges (not strictly necessary for just displaying info, but good practice)
if [ "$EUID" -ne 0 ]; then
  echo "Note: You don't need root to run this helper script, but you will need root"
  echo "      privileges to modify system configuration files and restart services."
  echo ""
fi

# --- Get User Input ---
echo "Available network interfaces (excluding loopback 'lo'):"
ip -br link show | awk '$1 != "lo" {print $1}'
echo ""

read -p "Enter the network interface name (e.g., eth0, enp2s0): " INTERFACE
if [ -z "$INTERFACE" ]; then echo "Error: Interface name cannot be empty."; exit 1; fi
if ! ip link show "$INTERFACE" &> /dev/null && [ "$INTERFACE" != "lo" ]; then # Allow proceeding even if not up
    echo "Warning: Interface '$INTERFACE' does not appear to be currently active or might not exist."
    echo "Proceeding, but ensure this is the correct name for your configuration."
fi

read -p "Enter the new static IP address (e.g., 192.168.1.100): " NEW_IP
if [ -z "$NEW_IP" ]; then echo "Error: New IP address cannot be empty."; exit 1; fi

read -p "Enter the netmask in CIDR notation (e.g., 24 for 255.255.255.0): " NETMASK_CIDR
if [ -z "$NETMASK_CIDR" ]; then echo "Error: Netmask (CIDR) cannot be empty."; exit 1; fi

read -p "Enter the gateway IP address (e.g., 192.168.1.1, leave blank if none): " GATEWAY_IP

read -p "Enter DNS server(s) (space-separated, e.g., 8.8.8.8 1.1.1.1, leave blank for none): " DNS_SERVERS_INPUT
read -r -a DNS_SERVERS_ARRAY <<< "$DNS_SERVERS_INPUT" # Convert to array

echo ""
echo "-------------------------------------------"
echo "Configuration Details:"
echo "Interface:    $INTERFACE"
echo "IP Address:   $NEW_IP/$NETMASK_CIDR"
echo "Gateway:      ${GATEWAY_IP:-Not set}"
echo "DNS Servers:  ${DNS_SERVERS_INPUT:-Not set}"
echo "-------------------------------------------"
echo ""

# --- Detect Network Management System ---
NM_ACTIVE=false
SD_NETWORKD_ACTIVE=false
NETCTL_PROFILES_EXIST=false

echo "Detecting active network management system..."

if command -v nmcli &> /dev/null && systemctl is-active --quiet NetworkManager.service; then
    echo "- NetworkManager appears to be active."
    NM_ACTIVE=true
fi

if systemctl is-active --quiet systemd-networkd.service; then
    echo "- systemd-networkd appears to be active."
    SD_NETWORKD_ACTIVE=true
fi

# Check for actual netctl profile files, not just the directory or examples
if [ -d "/etc/netctl" ]; then
    if find /etc/netctl -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null; then
        # Heuristic: if any file exists directly under /etc/netctl (not in subdirs like examples)
        # A more precise check would be `systemctl list-unit-files | grep "netctl@.*\.service.*enabled"`,
        # but that's more complex for a simple detection here.
        echo "- netctl profiles might exist in /etc/netctl."
        NETCTL_PROFILES_EXIST=true
    fi
fi


echo ""
echo "===================================================================="
echo " Instructions for Permanent Configuration"
echo "===================================================================="
echo "Based on your system, one or more options will be shown below."
echo "Choose the one that matches how your system currently manages networks,"
echo "or the one you intend to use. Ensure only ONE system manages an interface."
echo ""

MANAGER_GUIDANCE_PROVIDED=false

if $NM_ACTIVE; then
    MANAGER_GUIDANCE_PROVIDED=true
    echo ""
    echo ">>> Option 1: NetworkManager (Detected as Active) <<<"
    echo "----------------------------------------------------"
    echo "NetworkManager is active. You should use 'nmcli' (command-line) or 'nmtui' (text UI)."
    echo ""
    echo "1. Identify your connection: If you have an existing connection for '$INTERFACE',"
    echo "   you might want to modify it. List all connections:"
    echo "     sudo nmcli connection show"
    echo "   To find the connection for your specific device (look for UUID or NAME):"
    echo "     sudo nmcli device show \"$INTERFACE\" | grep GENERAL.CONNECTION"
    echo "   Let's assume the existing connection name is '<existing_con_name>' or you'll create a new one."
    echo ""
    echo "2. To MODIFY an existing connection (replace <existing_con_name> or its UUID):"
    echo "   sudo nmcli connection modify <existing_con_name> \\"
    echo "     ipv4.method manual ipv4.addresses \"$NEW_IP/$NETMASK_CIDR\" \\"
    if [ -n "$GATEWAY_IP" ]; then
        echo "     ipv4.gateway \"$GATEWAY_IP\" \\"
    else # Explicitly clear gateway if not provided
        echo "     ipv4.gateway \"\" \\"
    fi
    if [ ${#DNS_SERVERS_ARRAY[@]} -gt 0 ]; then
        echo "     ipv4.dns \"${DNS_SERVERS_ARRAY[*]}\" \\" # nmcli wants space separated string
    else # Explicitly clear DNS if not provided
        echo "     ipv4.dns \"\" \\"
    fi
    echo "     ipv6.method ignore  # Optionally disable IPv6 if not used"
    echo ""
    echo "3. OR, to ADD a NEW static connection profile (replace 'static-$INTERFACE' with your preferred name):"
    echo "   sudo nmcli connection add type ethernet con-name \"static-$INTERFACE\" ifname \"$INTERFACE\" \\"
    echo "     ipv4.method manual ipv4.addresses \"$NEW_IP/$NETMASK_CIDR\" \\"
    if [ -n "$GATEWAY_IP" ]; then
        echo "     ipv4.gateway \"$GATEWAY_IP\" \\"
    fi
    if [ ${#DNS_SERVERS_ARRAY[@]} -gt 0 ]; then
        echo "     ipv4.dns \"${DNS_SERVERS_ARRAY[*]}\" \\"
    fi
    echo "     ipv6.method ignore"
    echo ""
    echo "4. Activate the connection:"
    echo "   If you modified an existing active connection, it might re-apply:"
    echo "     sudo nmcli connection up <existing_con_name>"
    echo "   If you added a new one (or the old one was down):"
    echo "     sudo nmcli connection up \"static-$INTERFACE\"  # Or your chosen connection name"
    echo "   (If another connection was active for '$INTERFACE', it might be auto-deactivated,"
    echo "    or you might need 'sudo nmcli connection down <old_connection_name>' first)."
    echo ""
    echo "5. Verify:"
    echo "   ip addr show dev \"$INTERFACE\""
    echo "   ip route show"
    echo "   resolvectl status global  # Or: cat /etc/resolv.conf (should be managed by NM)"
    echo "   ping -c 3 ${GATEWAY_IP:-archlinux.org}"
    echo ""
    echo "Note: Ensure other network config tools (like systemd-networkd, netctl, or dhcpcd"
    echo "      for this specific interface) are disabled to prevent conflicts."
    echo "      E.g., 'sudo systemctl disable --now dhcpcd@$INTERFACE.service' if it was used."
    echo "----------------------------------------------------"
fi

# Show systemd-networkd if it's active, or if NM isn't active and netctl profiles don't clearly exist (common fallback/recommendation)
if $SD_NETWORKD_ACTIVE || (! $NM_ACTIVE && ! $NETCTL_PROFILES_EXIST ); then
    MANAGER_GUIDANCE_PROVIDED=true
    echo ""
    echo ">>> Option 2: systemd-networkd (Detected or Recommended Default) <<<"
    echo "-------------------------------------------------------------------------"
    if ! $SD_NETWORKD_ACTIVE; then
        echo "systemd-networkd is not detected as active, but is a good choice for static IPs."
    fi
    echo "To use systemd-networkd:"
    echo "1. Ensure services are enabled and running:"
    echo "   sudo systemctl enable systemd-networkd.service"
    echo "   sudo systemctl enable systemd-resolved.service  # For DNS handling"
    echo "   sudo systemctl start systemd-networkd.service"
    echo "   sudo systemctl start systemd-resolved.service"
    echo "   # Make /etc/resolv.conf point to systemd-resolved's file:"
    echo "   sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf"
    echo ""
    echo "2. Create a .network file, e.g., '/etc/systemd/network/20-static-${INTERFACE}.network':"
    echo "   (Use a text editor like nano: sudo nano /etc/systemd/network/20-static-${INTERFACE}.network)"
    echo ""
    echo "   File content:"
    echo "   -------------------------------------------"
    echo "   [Match]"
    echo "   Name=$INTERFACE"
    echo ""
    echo "   [Network]"
    echo "   Address=$NEW_IP/$NETMASK_CIDR"
    if [ -n "$GATEWAY_IP" ]; then
        echo "   Gateway=$GATEWAY_IP"
    fi
    if [ ${#DNS_SERVERS_ARRAY[@]} -gt 0 ]; then
        for DNS_SERVER in "${DNS_SERVERS_ARRAY[@]}"; do
            echo "   DNS=$DNS_SERVER"
        done
        echo "   #Domains=your.search.domain # Optional: for DNS search domains"
    fi
    echo ""
    # echo "   [Link]" # Optional section for things like MAC spoofing, MTU
    # echo "   # MACAddress=aa:bb:cc:dd:ee:ff"
    # echo "   # MTUBytes=1400"
    echo "   -------------------------------------------"
    echo ""
    echo "3. Set correct permissions:"
    echo "   sudo chmod 644 /etc/systemd/network/20-static-${INTERFACE}.network"
    echo ""
    echo "4. CRITICAL: Disable other network management services for this interface, or entirely if"
    echo "   systemd-networkd is taking over fully. Examples:"
    echo "   sudo systemctl disable --now dhcpcd@$INTERFACE.service"
    echo "   sudo systemctl disable --now NetworkManager.service # If switching FROM NetworkManager"
    echo "   sudo systemctl stop NetworkManager # If switching FROM NetworkManager"
    echo "   # If using netctl, disable the relevant profile: sudo netctl disable <profile_name>"
    echo ""
    echo "5. Restart systemd-networkd to apply changes:"
    echo "   sudo systemctl restart systemd-networkd"
    echo "   # If DNS settings were part of the change, systemd-resolved should pick them up."
    echo "   # You can also 'sudo resolvectl flush-caches'."
    echo ""
    echo "6. Verify:"
    echo "   networkctl status \"$INTERFACE\""
    echo "   ip addr show dev \"$INTERFACE\""
    echo "   ip route show"
    echo "   resolvectl query archlinux.org"
    echo "   ping -c 3 ${GATEWAY_IP:-archlinux.org}"
    echo "-------------------------------------------------------------------------"
fi

# Only suggest netctl if profiles are found AND it's not overshadowed by NM or systemd-networkd being active.
# Users explicitly using netctl usually know it.
if $NETCTL_PROFILES_EXIST && ! $NM_ACTIVE && ! $SD_NETWORKD_ACTIVE; then
    MANAGER_GUIDANCE_PROVIDED=true
    echo ""
    echo ">>> Option 3: netctl (Profiles Detected) <<<"
    echo "------------------------------------------"
    echo "netctl profiles were found. If you are actively using netctl:"
    echo "1. Create/edit a profile file in /etc/netctl/, e.g., 'static-$INTERFACE':"
    echo "   (Use a text editor: sudo nano /etc/netctl/static-$INTERFACE)"
    echo ""
    echo "   File content:"
    echo "   -------------------------------------------"
    echo "   Description='Static IP for $INTERFACE'"
    echo "   Interface=$INTERFACE"
    echo "   Connection=ethernet"
    echo "   IP=static"
    echo "   Address=('$NEW_IP/$NETMASK_CIDR')" # Parentheses are important for array
    if [ -n "$GATEWAY_IP" ]; then
        echo "   Gateway='$GATEWAY_IP'"
    fi
    if [ ${#DNS_SERVERS_ARRAY[@]} -gt 0 ]; then
        _dns_netctl_items=()
        for _dns_s in "${DNS_SERVERS_ARRAY[@]}"; do
            _dns_netctl_items+=("'$_dns_s'") # Quote each server
        done
        _dns_netctl_final_str=$(IFS=" "; echo "${_dns_netctl_items[*]}")
        echo "   DNS=($_dns_netctl_final_str)" # e.g., DNS=('1.1.1.1' '8.8.8.8')
    fi
    # echo "   ## For Wi-Fi, you'd add: Security, ESSID, Key etc."
    echo "   -------------------------------------------"
    echo ""
    echo "2. Stop any current netctl profile for this interface:"
    echo "   sudo netctl stop-all # Or specific profile: sudo netctl stop <current_profile_for_$INTERFACE>"
    echo "   Ensure no other services (dhcpcd, NetworkManager, systemd-networkd) manage it."
    echo ""
    echo "3. Enable and start your new profile:"
    echo "   sudo netctl enable static-$INTERFACE"
    echo "   sudo netctl start static-$INTERFACE"
    echo "   # Or, to switch from another profile: sudo netctl switch-to static-$INTERFACE"
    echo ""
    echo "4. Verify:"
    echo "   ip addr show dev \"$INTERFACE\""
    echo "   ip route show"
    echo "   cat /etc/resolv.conf # netctl typically updates this directly or via resolvconf utility"
    echo "   ping -c 3 ${GATEWAY_IP:-archlinux.org}"
    echo "------------------------------------------"
fi

if ! $MANAGER_GUIDANCE_PROVIDED; then
    echo ""
    echo ">>> No Specific Network Manager Actively Detected or Ambiguous Setup <<<"
    echo "-----------------------------------------------------------------------"
    echo "Could not definitively determine a single active network manager, or your setup"
    echo "might be using a more basic tool like 'dhcpcd' directly without a full manager."
    echo ""
    echo "If you are unsure:"
    echo "- For a server or minimal Arch install, 'systemd-networkd' (Option 2 above) is recommended."
    echo "- For a desktop environment, 'NetworkManager' (Option 1 above) is often already in use or is a good choice."
    echo ""
    echo "Please review the general instructions for systemd-networkd (Option 2) as a common method."
    echo "You'll need to ensure that whatever you choose is the SOLE system configuring '$INTERFACE'."
    echo "If 'dhcpcd.service' or 'dhcpcd@$INTERFACE.service' is running and you want a static IP,"
    echo "you typically need to disable it: 'sudo systemctl disable --now dhcpcd@$INTERFACE.service'"
    echo "and then configure static IP using NetworkManager or systemd-networkd."
    echo "-----------------------------------------------------------------------"
fi

echo ""
echo "===================================================================="
echo "Reminder: This script has NOT changed your system."
echo "Apply the chosen method carefully. Test connectivity thoroughly after changes."
echo "If you lose network access, you may need console/physical access to revert."
echo "===================================================================="

exit 0
