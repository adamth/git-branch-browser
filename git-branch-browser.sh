#!/bin/bash

# git-branch-browser - Interactive Git branch switcher
# https://github.com/threedivers/git-branch-browser

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage information
show_usage() {
    echo -e "${BLUE}Git Branch Browser${NC} - Interactive Git branch switcher"
    echo ""
    echo "Usage:"
    echo "  git-branch-browser [options] [number_of_branches]"
    echo ""
    echo "Options:"
    echo "  --help, -h       Show this help message"
    echo "  --version, -v    Show version information"
    echo ""
    echo "Examples:"
    echo "  git-branch-browser             # Show last 5 branches"
    echo "  git-branch-browser 10          # Show last 10 branches"
    echo ""
}

# Function to show version information
show_version() {
    echo "Git Branch Browser v1.0.0"
    echo "https://github.com/threedivers/git-branch-browser"
}

# Parse command line options
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --version|-v)
            show_version
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
    shift
done

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo -e "${RED}Error: Not in a git repository.${NC}"
    echo "Please run this command from within a git repository."
    exit 1
fi

# Get number of branches to show (default: 5)
NUM_BRANCHES=5
if [[ "$1" =~ ^[0-9]+$ ]]; then
    NUM_BRANCHES=$1
fi

# Get the last N unique branches from git reflog
BRANCHES=$(git reflog | grep -E 'checkout: moving from|checkout: moving to' | sed -E 's/.*moving (from|to) ([^ ]+).*/\2/' | awk '!seen[$0]++' | head -$NUM_BRANCHES)

# Check if we found any branches
if [[ -z $BRANCHES ]]; then
    echo -e "${RED}No recent branches found.${NC}"
    echo "Try running some git checkout or git switch commands first."
    exit 1
fi

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo -e "${RED}This tool requires fzf.${NC}"
    echo "Install it with 'brew install fzf' (macOS) or your system's package manager."
    exit 1
fi

# Use fzf to select a branch with arrow keys
SELECTED_BRANCH=$(echo "$BRANCHES" | fzf --height=10 --reverse --header="Select a branch to switch to:" --prompt="Branch > ")

# Switch to the selected branch if one was chosen
if [[ -n $SELECTED_BRANCH ]]; then
    echo -e "${GREEN}Switching to $SELECTED_BRANCH...${NC}"
    git switch $SELECTED_BRANCH
else
    echo -e "${YELLOW}No branch selected.${NC}"
    exit 0
fi
