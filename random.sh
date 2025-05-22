#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
AUR_HELPER="yay" # Change to "paru" or your preferred AUR helper
SOUND_SYSTEM="pulseaudio" # Change to "pulseaudio" if you use PulseAudio

# --- Helper Functions ---
info() {
    echo "[INFO] $1"
}

warn() {
    echo "[WARN] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

check_aur_helper() {
    if ! command -v "$AUR_HELPER" &> /dev/null; then
        error "$AUR_HELPER is not installed. Please install it first, or modify the script to use your AUR package management method."
    fi
}

# --- Main Script ---

info "Starting XRDP setup for Arch Linux with GNOME..."

# 0. Check for AUR Helper
info "Checking for AUR helper ($AUR_HELPER)..."
check_aur_helper

# 1. Install necessary packages
info "Installing XRDP, XorgXRDP, and sound modules..."
if ! pacman -Q gnome &>/dev/null; then
    info "GNOME desktop group not found. Installing 'gnome' group..."
    sudo pacman -S --noconfirm --needed gnome
else
    info "GNOME desktop group is already installed."
fi

sudo pacman -S --noconfirm --needed xorg-server xorg-xinit # Ensure base Xorg components are present

info "Installing XRDP and XorgXRDP from AUR using $AUR_HELPER..."
"$AUR_HELPER" -S --noconfirm --needed xrdp xorgxrdp

if [ "$SOUND_SYSTEM" == "pipewire" ]; then
    info "Installing PipeWire XRDP module..."
    "$AUR_HELPER" -S --noconfirm --needed pipewire-module-xrdp
elif [ "$SOUND_SYSTEM" == "pulseaudio" ]; then
    info "Installing PulseAudio XRDP module..."
    "$AUR_HELPER" -S --noconfirm --needed pulseaudio-module-xrdp
else
    warn "Unknown sound system: $SOUND_SYSTEM. Skipping sound module installation."
fi

# 2. Configure ~/.xrdpinitrc for the current user
XF_XRDPINITRC_PATH="${HOME}/.xrdpinitrc"
info "Creating/updating ${XF_XRDPINITRC_PATH} for GNOME session..."
cat << EOF > "${XF_XRDPINITRC_PATH}"
#!/bin/sh
# Script to start GNOME session for XRDP

# Set environment variables for GNOME
export XDG_SESSION_DESKTOP=gnome
export GNOME_SHELL_SESSION_MODE=gnome
# export XDG_CURRENT_DESKTOP=GNOME # Alternative/additional variable

# Start GNOME session
exec gnome-session
EOF
chmod +x "${XF_XRDPINITRC_PATH}"
info "${XF_XRDPINITRC_PATH} created successfully."

# 3. Modify /etc/xrdp/startwm.sh
STARTWM_PATH="/etc/xrdp/startwm.sh"
STARTWM_BACKUP_PATH="/etc/xrdp/startwm.sh.backup.$(date +%F-%T)"
info "Backing up ${STARTWM_PATH} to ${STARTWM_BACKUP_PATH}..."
sudo cp "${STARTWM_PATH}" "${STARTWM_BACKUP_PATH}"

info "Modifying ${STARTWM_PATH} to use ~/.xrdpinitrc if available..."
sudo tee "${STARTWM_PATH}" > /dev/null << 'EOF'
#!/bin/sh

# xrdp X session startup script for users
#
# This script is run by xrdp-sesmanDisplay to start the X session.
# It first tries to execute ~/.xrdpinitrc if it exists and is executable.
# Otherwise, it falls back to ~/.xinitrc and then /etc/X11/xinit/xinitrc.

# Check for a user-specific .xrdpinitrc and use it if it exists
if [ -x "${HOME}/.xrdpinitrc" ]; then
  . "${HOME}/.xrdpinitrc"
# Else, fall back to standard .xinitrc behavior
elif [ -r "${HOME}/.xinitrc" ]; then
  . "${HOME}/.xinitrc"
elif [ -r "/etc/X11/xinit/xinitrc" ]; then
  . "/etc/X11/xinit/xinitrc"
else
  # Fallback if nothing else is found
  echo "No session startup script found, launching xterm and twm as failsafe." >&2
  xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
  twm &
fi

exit 0
EOF
sudo chmod +x "${STARTWM_PATH}"
info "${STARTWM_PATH} modified successfully."

# 4. Create Polkit rule for colord (common issue)
POLKIT_RULES_DIR="/etc/polkit-1/rules.d"
COLORD_RULE_PATH="${POLKIT_RULES_DIR}/45-allow-colord-xrdp.rules"
info "Creating Polkit rule for org.freedesktop.color-manager..."
sudo mkdir -p "${POLKIT_RULES_DIR}"
sudo tee "${COLORD_RULE_PATH}" > /dev/null << 'EOF'
// Allow users in 'wheel' group (or any logged-in user for simplicity here)
// to manage color profiles without repeated auth in XRDP sessions.
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.color-manager.create-device" ||
         action.id == "org.freedesktop.color-manager.create-profile" ||
         action.id == "org.freedesktop.color-manager.delete-device" ||
         action.id == "org.freedesktop.color-manager.delete-profile" ||
         action.id == "org.freedesktop.color-manager.modify-device" ||
         action.id == "org.freedesktop.color-manager.modify-profile") &&
        subject.active && subject.local === false) { // Check for active, remote session
        // For simplicity, we'll allow if the user is in 'wheel'.
        // Adjust subject.isInGroup("your_user_group") if needed for more fine-grained control.
        if (subject.isInGroup("wheel")) {
             return polkit.Result.YES;
        }
    }
});
EOF
info "Polkit rule ${COLORD_RULE_PATH} created."
warn "Additional Polkit rules might be necessary depending on your usage."
warn "For very permissive (less secure) Polkit access for admin users in wheel group, you could create a rule like:"
warn "/* /etc/polkit-1/rules.d/00-admin-allow-all-xrdp.rules */"
warn "polkit.addRule(function(action, subject) { if (subject.isInGroup(\"wheel\") && subject.active && subject.local === false) { return polkit.Result.YES; } });"
warn "USE WITH CAUTION due to security implications."


# 5. Enable and start XRDP service
info "Enabling and starting xrdp.service..."
sudo systemctl enable xrdp.service
# Older setups might have used xrdp-sesman.service separately,
# but xrdp.service should manage it.
# If xrdp.service fails to start xrdp-sesman, you might need:
# sudo systemctl enable xrdp-sesman.service
# sudo systemctl restart xrdp-sesman.service
sudo systemctl restart xrdp.service # Use restart to ensure it picks up changes

# Check status
sleep 2 # Give a moment for the service to start/restart
if sudo systemctl is-active --quiet xrdp.service; then
    info "xrdp.service is active."
else
    warn "xrdp.service may not have started correctly. Check with 'systemctl status xrdp.service' and logs."
fi

# 6. Firewall configuration (User needs to uncomment and adapt)
info "Firewall configuration needed for port 3389/tcp."
info "Please uncomment and run the appropriate command for your firewall if enabled:"
info "# For UFW: sudo ufw allow 3389/tcp && sudo ufw reload"
info "# For firewalld: sudo firewall-cmd --permanent --add-port=3389/tcp && sudo firewall-cmd --reload"

# --- Completion ---
echo ""
info "XRDP setup for GNOME script finished."
info "Important next steps:"
info "1. If you have a firewall, ensure port 3389/tcp is open (see examples above)."
info "2. You may need to log out and log back in, or even reboot, for all changes to take effect, especially regarding D-Bus and session environment variables."
info "3. Test the RDP connection from a client machine."
info "4. If you encounter issues (e.g., black screen, components not working):"
info "   - Check XRDP logs: /var/log/xrdp.log and /var/log/xrdp-sesman.log"
info "   - Check session errors: ~/.xsession-errors (or ~/.xsession-errors.old)"
info "   - Check system journal: journalctl -xe for general errors, journalctl -u xrdp.service"
info "   - Review Polkit rules and create more specific ones if needed based on log messages."

exit 0
