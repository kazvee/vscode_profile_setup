#!/bin/bash

LOG_FILE="vscode_profiles_install.log"

# Check that VSCode CLI exists
if ! command -v code &> /dev/null; then
    echo "Error: VSCode CLI 'code' not found in PATH"
    exit 1
fi

# ==============================
# Common extensions
# ==============================
COMMON_EXTENSIONS=(
    "azemoh.one-monokai"
    "christian-kohler.path-intellisense"
    "eamodio.gitlens"
    "editorconfig.editorconfig"
    "esbenp.prettier-vscode"
    "pkief.material-icon-theme"
    "naumovs.color-highlight"
)

# ==============================
# Profile-specific extensions
# ==============================
declare -A PROFILE_EXTENSIONS

PROFILE_EXTENSIONS[JavaScript]=$(
cat <<'EOF'
dbaeumer.vscode-eslint
dsznajder.es7-react-js-snippets
wix.vscode-import-cost
formulahendry.auto-rename-tag
ritwickdey.liveserver
negokaz.live-server-preview
bradlc.vscode-tailwindcss
bierner.markdown-mermaid
svelte.svelte-vscode
vue.volar
EOF
)

PROFILE_EXTENSIONS[Python]=$(
cat <<'EOF'
ms-python.python
formulahendry.code-runner
EOF
)

PROFILE_EXTENSIONS[PHP]=$(
cat <<'EOF'
bmewburn.vscode-intelephense-client
formulahendry.code-runner
marlon407.code-groovy
EOF
)

PROFILE_EXTENSIONS[Java]=$(
cat <<'EOF'
vscjava.vscode-java-pack
formulahendry.code-runner
EOF
)

# ==============================
# Function to setup a profile
# ==============================
setup_profile() {
    PROFILE=$1
    echo "-------------------------------------"
    echo "⏳ Setting up profile: $PROFILE"
    echo "Profile: $PROFILE" >> "$LOG_FILE"

    # Launch VSCode once to initialize the profile folder
    code --profile "$PROFILE" --disable-extensions &
    echo "Launching VSCode to create profile folder. Feel free to minimize the new VSCode window..."
    sleep 5

    # Install common extensions
    for ext in "${COMMON_EXTENSIONS[@]}"; do
		code --install-extension "$ext" --profile "$PROFILE" > /dev/null 2>&1
		echo "Installed: $ext"
		echo "Installed: $ext" >> "$LOG_FILE"
	done

    # Install profile-specific extensions
    while IFS= read -r ext; do
        [ -z "$ext" ] && continue
        code --install-extension "$ext" --profile "$PROFILE" > /dev/null 2>&1
		echo "Installed: $ext"
        echo "Installed: $ext" >> "$LOG_FILE"
    done <<< "${PROFILE_EXTENSIONS[$PROFILE]}"

    echo "✅ Finished setting up $PROFILE profile!"
    echo "" >> "$LOG_FILE"
}

# ==============================
# Interactive menu
# ==============================
echo "Type the number(s) for the profiles to set up:"
echo "1. JavaScript 🙂"
echo "2. Python 🐍"
echo "3. PHP 🅿️"
echo "4. Java ☕"
echo "Enter multiple selections using commas, for example: 1,2,3"

read -p "Enter selection(s): " SELECTION

# Convert numbers to profile names
declare -a SELECTED_PROFILES
IFS=',' read -ra NUMS <<< "$SELECTION"
for n in "${NUMS[@]}"; do
    n=$(echo "$n" | xargs) # trim
    case "$n" in
        1) SELECTED_PROFILES+=("JavaScript") ;;
        2) SELECTED_PROFILES+=("Python") ;;
        3) SELECTED_PROFILES+=("PHP") ;;
        4) SELECTED_PROFILES+=("Java") ;;
        *) echo "Warning: '$n' is not a valid option. Skipping..." ;;
    esac
done

if [ ${#SELECTED_PROFILES[@]} -eq 0 ]; then
    echo "No valid profiles selected. Exiting."
    exit 1
fi

# ==============================
# Install selected profiles
# ==============================
for PROFILE in "${SELECTED_PROFILES[@]}"; do
    setup_profile "$PROFILE"
done

echo "-------------------------------------"
echo "Selected profiles have been set up! 🎉"
echo "Installation log saved to: $LOG_FILE"
