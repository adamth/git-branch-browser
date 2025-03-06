#!/bin/bash

# Install script for Git Branch Browser
# https://github.com/threedivers/git-branch-browser

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the install directory from the first argument or use default
INSTALL_DIR="${1:-/usr/local/bin}"
CONFIG_DIR="${2:-$HOME/.config/git-branch-browser}"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Copy the main script to the install location
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/git-branch-browser.sh"
DEST_PATH="$INSTALL_DIR/git-branch-browser"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${RED}Error: Could not find git-branch-browser.sh in the current directory.${NC}"
    exit 1
fi

cp "$SCRIPT_PATH" "$DEST_PATH"
chmod +x "$DEST_PATH"

echo -e "${GREEN}✅ Installed to $DEST_PATH${NC}"

# Check for dependencies
echo -e "\n${BLUE}Checking dependencies...${NC}"

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo -e "${YELLOW}⚠️ fzf is not installed.${NC}"
    echo "This tool requires fzf for interactive branch selection."
    echo -e "Installation instructions: ${BLUE}https://github.com/junegunn/fzf#installation${NC}"
    echo -e "For macOS users: ${BLUE}brew install fzf${NC}"
else
    echo -e "${GREEN}✅ fzf is installed.${NC}"
fi

# Add an alias to .zshrc or .bashrc if the user wants
echo -e "\n${BLUE}Would you like to add a 'gbb' alias to your shell configuration? (y/n)${NC}"
read -p "> " add_alias
if [[ "$add_alias" =~ ^[Yy] ]]; then
    # Determine which shell the user is using
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bashrc"
    else
        # Default to .zshrc
        SHELL_RC="$HOME/.zshrc"
    fi
    
    # Check if the alias already exists
    if grep -q "alias gbb=" "$SHELL_RC"; then
        echo -e "${YELLOW}The 'gbb' alias already exists in $SHELL_RC.${NC}"
        echo "You can manually add the following line to your shell configuration:"
        echo -e "${BLUE}alias gbb='git-branch-browser'${NC}"
    else
        # Add the alias
        echo "" >> "$SHELL_RC"
        echo "# Git Branch Browser alias" >> "$SHELL_RC"
        echo "alias gbb='git-branch-browser'" >> "$SHELL_RC"
        echo -e "${GREEN}✅ Added 'gbb' alias to $SHELL_RC${NC}"
        echo -e "Run ${BLUE}source $SHELL_RC${NC} to apply the changes to your current shell."
    fi
else
    echo -e "\n${GREEN}Installation complete!${NC}"
    echo -e "Run ${BLUE}git-branch-browser${NC} to use the tool."
    echo -e "You can also create an alias manually by adding ${BLUE}alias gbb='git-branch-browser'${NC} to your shell configuration."
fi
