#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo ">>> Starting installation and setup script for Docker, XRDP, and GNOME <<<"

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "ERROR: yay is not installed. Please install yay first to proceed."
    echo "You can typically install it by cloning the yay git repo and running makepkg."
    exit 1
fi

# --- 1. Update system and install Docker with pacman ---
echo ""
echo ">>> Updating system and installing Docker..."
sudo pacman -Syu --noconfirm docker

echo ">>> Enabling and starting Docker service..."
sudo systemctl enable --now docker.service

echo ">>> Adding current user ($USER) to the docker group..."
if ! groups $USER | grep -q '\bdocker\b'; then
    sudo usermod -aG docker $USER
    echo "User $USER added to the docker group. A log out/log in or reboot is required for this change to take full effect."
else
    echo "User $USER is already in the docker group."
fi

# --- 2. Install Docker Compose with yay ---
echo ""
echo ">>> Installing Docker Compose..."
yay -S --noconfirm docker-compose

# --- 3. Install XRDP and Xorg components with yay ---
echo ""
echo ">>> Installing XRDP, xorgxrdp, xorg-server, and xorg-xinit..."
# xorgxrdp is the driver for XRDP to communicate with Xorg.
# xorg-server is the X server itself.
# xorg-xinit is useful for .xinitrc scripts and startx.
yay -S --noconfirm xrdp xorgxrdp xorg-server xorg-xinit

# --- 4. Setup GNOME to work with XRDP ---
echo ""
echo ">>> Configuring GNOME and XRDP..."

# 4a. Configure GDM to prefer Xorg (optional but recommended for local session stability with XRDP)
GDM_CUSTOM_CONF="/etc/gdm/custom.conf"
echo ">>> Checking GDM configuration for Wayland..."
if [ -f "$GDM_CUSTOM_CONF" ]; then
    if grep -q "^\s*WaylandEnable=false" "$GDM_CUSTOM_CONF"; then
        echo "GDM WaylandEnable is already set to false in $GDM_CUSTOM_CONF."
    elif grep -q "^\s*#\s*WaylandEnable=false" "$GDM_CUSTOM_CONF"; then
        echo "Uncommenting WaylandEnable=false in $GDM_CUSTOM_CONF..."
        sudo sed -i 's/^\s*#\s*WaylandEnable=false/WaylandEnable=false/' "$GDM_CUSTOM_CONF"
    elif grep -q "\[daemon\]" "$GDM_CUSTOM_CONF"; then
        echo "Adding WaylandEnable=false under [daemon] in $GDM_CUSTOM_CONF..."
        sudo sed -i '/\[daemon\]/a WaylandEnable=false' "$GDM_CUSTOM_CONF"
    else
        echo "Warning: Could not find [daemon] section in $GDM_CUSTOM_CONF to automatically set WaylandEnable=false."
        echo "Please manually edit $GDM_CUSTOM_CONF if you want to disable Wayland for GDM."
    fi
else
    echo "Warning: $GDM_CUSTOM_CONF not found. Skipping GDM Wayland disable. Your system might use a different GDM configuration or not use GDM."
fi

# 4b. Create/Update ~/.xinitrc for the current user to start GNOME session via XRDP
echo ">>> Creating/updating ~/.xinitrc for GNOME session with XRDP for user $USER..."
cat << EOF > "$HOME/.xinitrc"
#!/bin/sh

# Set environment variables for GNOME session
export GNOME_SHELL_SESSION_MODE=gnome
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=GNOME
# export XDG_CONFIG_DIRS=/etc/xdg/xdg-gnome:/etc/xdg

# The following might be needed if you face issues with dbus or systemd user services
# Make sure XDG_RUNTIME_DIR is set correctly.
# if test -z "\$XDG_RUNTIME_DIR"; then
#     export XDG_RUNTIME_DIR=/run/user/\$(id -u)
#     # mkdir -p "\$XDG_RUNTIME_DIR" # Systemd usually creates this
#     # chmod 0700 "\$XDG_RUNTIME_DIR"
# fi

# Start GNOME Session
exec gnome-session
EOF
chmod +x "$HOME/.xinitrc"
echo "~/.xinitrc created/updated and made executable for user $USER."

# 4c. Optional: Polkit rule for color management (often helps with GNOME black screen/usability issues on XRDP)
POLKIT_RULES_DIR="/etc/polkit-1/rules.d"
POLKIT_COLORD_RULE="$POLKIT_RULES_DIR/02-allow-colord.rules"
echo ">>> Creating Polkit rule for color management in XRDP sessions..."
sudo mkdir -p "$POLKIT_RULES_DIR"
sudo bash -c "cat << EOF > '$POLKIT_COLORD_RULE'
// Allow users (especially in remote sessions) to manage color profiles
// This can prevent black screens or usability issues in GNOME over XRDP
polkit.addRule(function(action, subject) {
    if (action.id == \"org.freedesktop.color-manager.create-device\" ||
        action.id == \"org.freedesktop.color-manager.create-profile\" ||
        action.id == \"org.freedesktop.color-manager.delete-device\" ||
        action.id == \"org.freedesktop.color-manager.delete-profile\" ||
        action.id == \"org.freedesktop.color-manager.modify-device\" ||
        action.id == \"org.freedesktop.color-manager.modify-profile\") {
        // Allow any authenticated user in the 'users' group or any active session user
        if (subject.isInGroup(\"users\") || subject.active) {
            return polkit.Result.YES;
        }
    }
});
EOF"
echo "Polkit rule for colord created at $POLKIT_COLORD_RULE."

# 4d. Ensure /etc/xrdp/startwm.sh calls user's .xinitrc or similar
# Most default startwm.sh scripts are set up to execute ~/.xsession or ~/.xinitrc.
# If GNOME doesn't start, you might need to edit /etc/xrdp/startwm.sh to directly call gnome-session.
# For example, comment out existing session startups and add:
# unset DBUS_SESSION_BUS_ADDRESS
# unset XDG_RUNTIME_DIR
# . $HOME/.profile # optional
# exec gnome-session
echo ">>> Ensuring XRDP session startup..."
echo "The ~/.xinitrc file has been configured for user $USER."
echo "Most default /etc/xrdp/startwm.sh scripts will use this file."
echo "If you experience issues with session startup, you may need to check or customize /etc/xrdp/startwm.sh."

# 4e. Enable and start XRDP service
echo ">>> Enabling and starting XRDP service..."
sudo systemctl daemon-reload # Reload systemd manager configuration (due to polkit rule)
sudo systemctl enable --now xrdp.service
sudo systemctl restart xrdp.service # Ensure it picks up all configs

echo ""
echo ">>> Installation and setup complete! <<<"
echo ""
echo "--- Important Notes ---"
echo "1. Docker: User '$USER' has been added to the 'docker' group. You MUST log out and log back in"
echo "   or reboot for this group change to take full effect for your current session."
echo "2. XRDP: The XRDP service is now running and enabled to start on boot."
echo "   - You can connect using an RDP client to this machine's IP address."
echo "   - When prompted by your RDP client for session type, choose 'Xorg' or 'X11' (not Wayland)."
echo "   - The .xinitrc file created is for user '$USER'. If other users need to connect via XRDP"
echo "     with GNOME, they will need a similar ~/.xinitrc in their home directory, or you'll"
echo "     need to configure /etc/xrdp/startwm.sh for a system-wide GNOME setup."
echo "3. Firewall: If you have a firewall enabled (e.g., ufw, firewalld), ensure TCP port 3389"
echo "   is open to allow incoming RDP connections."
echo "   Example for ufw: sudo ufw allow 3389/tcp"
echo "4. Reboot: A system reboot is recommended to ensure all changes are applied correctly,"
echo "   especially for GDM configuration and kernel modules if they were updated."
echo ""
echo "To verify Docker, after logging back in, try: docker run hello-world"
echo "To connect via RDP, use your machine's IP and user '$USER' credentials."
