#!/usr/bin/env bash

if ! command -v sudo &> /dev/null; then
    cat << EOF
ERROR: sudo not found

This script requires 'sudo' to manage system packages.
To fix this, please run the following as root:

    apt update
    apt install sudo
    usermod -aG sudo $USER

After running those, LOG OUT and LOG BACK IN for the 
group changes to take effect, then run this script again.
EOF
    exit 1
fi


# Install additional dependencies
sudo apt install --no-install-recommends \
  gnupg \
  python3-debian \
  ansible-core

# Since ansible-core is used (and not full ansible package), certain/dependency
# collections need to be installed as well
ansible-galaxy collection install -r requirements.yml


# dot-files configuration
DEFAULT_DOTFILES_GIT_URL="https://github.com/kkostrebic/dotfiles.git"
DEFAULT_DOTFILES_GIT_BRANCH="main"
DEFAULT_DOTFILES_DIR="$HOME/projects/dotfiles"
DEFAULT_DOTFILES_FORCE=false

# Ask for dot-files git repo url 
# read -p <prompt/message> -r (treats backslash as normal chat, i.e. non-escape char)
read -p "Git Repository [$DEFAULT_DOTFILES_GIT_URL]: " -r INPUT_DOTFILES_GIT_URL
DOTFILES_GIT_URL=${INPUT_DOTFILES_GIT_URL:-$DEFAULT_DOTFILES_GIT_URL}

# Ask for version, i.e. branch name
read -p "Branch [$DEFAULT_DOTFILES_GIT_BRANCH]: " -r INPUT_DOTFILES_GIT_BRANCH
DOTFILES_GIT_BRANCH=${INPUT_DOTFILES_GIT_BRANCH:-$DEFAULT_DOTFILES_GIT_BRANCH}

# Ask for destination directory
read -p "Where to clone [$DEFAULT_DOTFILES_DIR]: " -r INPUT_DOTFILES_DIR
DOTFILES_DIR=${INPUT_DOTFILES_DIR:-$DEFAULT_DOTFILES_DIR}

# Force replacement?
read -p "Replace existing configuration files [$DEFAULT_DOTFILES_FORCE]: " -r INPUT_DOTFILES_FORCE
DOTFILES_FORCE=${INPUT_DOTFILES_FORCE:-$DEFAULT_DOTFILES_FORCE}


# Setup workstation
ansible-playbook \
  --ask-become-pass \
  --extra-vars "dotfiles_force=$DOTFILES_FORCE" \
  --extra-vars "dotfiles_git_url=$DOTFILES_GIT_URL" \
  --extra-vars "dotfiles_git_branch=$DOTFILES_GIT_BRANCH" \
  --extra-vars "dotfiles_dir=$DOTFILES_DIR" \
  workstation.yml
