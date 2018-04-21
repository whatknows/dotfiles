#!/usr/bin/env bash
# 
# Bootstrap script for setting up a new OSX machine
#
# This script includes the following steps:
# 1. Install Xcode
# 2. Install Homebrew
# 3. Install OS level packages
# 4. Install software via Cask
# 
# This should be idempotent so it can be run multiple times.
#
# Some apps don't have a cask and so still need to be installed by hand. These
# include:
#
# @TODO: List apps you care about here.
#
# Notes:
#
# - If installing full Xcode, it's better to install that first from the app
#   store before running the bootstrap script. Otherwise, Homebrew can't access
#   the Xcode libraries as the agreement hasn't been accepted yet.
#
# Reading:
#
# - http://lapwinglabs.com/blog/hacker-guide-to-setting-up-your-mac
# - https://gist.github.com/MatthewMueller/e22d9840f9ea2fee4716
# - https://news.ycombinator.com/item?id=8402079
# - http://notes.jerzygangi.com/the-best-pgp-tutorial-for-mac-os-x-ever/

echo "Starting bootstrapping"

echo "Creating an SSH key for you..."
ssh-keygen -t rsa

echo "Please add this public key to Github"
echo "https://github.com/account/ssh		"
read -p "Press [Enter] key after this..."

######
# INSTALL XCODE
######

# Install Xcode
echo "Installing xcode-stuff"
xcode-select --install
# Accept agreement
sudo xcodebuild -license

######
# INSTALL HOMEBREW
######

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
brew update

######
# Install OS level packages
######

# Install GNU core utilities (those that come with OS X are outdated)
brew tap homebrew/dupes
brew install coreutils
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-indent --with-default-names
brew install gnu-which --with-default-names
brew install gnu-grep --with-default-names

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash

echo "Installing packages..."
PACKAGES=(
    ack
    autoconf
    automake
    boot2docker
    ffmpeg
    gettext
    gifsicle
    git
    graphviz
    hub
    imagemagick
    jq
    libjpeg
    libmemcached 
    lynx
    markdown
    memcached
    mercurial
    npm
    pkg-config
    python
    python3
    pypy
    rabbitmq
    rename
    ssh-copy-id
    terminal-notifier
    the_silver_searcher
    tmux
    tree
    vim
    wget
)
brew install ${PACKAGES[@]}

echo "Cleaning up..."
brew cleanup

echo "Adding ‘brewup' alias…"  
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'

#####
# INSTALL CASK
#####

echo "Installing cask..."
brew install caskroom/cask/brew-cask

#####
# INSTALL CASK APPS
#####

echo "Installing DEVELOPER cask apps..."
CASKS=(
    github
    atom
    iterm2
    vagrant
    virtualbox
)
brew cask install ${CASKS[@]}

#Communication Apps
echo "Installing COMMUNICATION cask apps..."
CASKS=(
    slack
    skype
    zoomus
)
brew cask install ${CASKS[@]}

# Web Apps
echo "Installing WEB cask apps..."
CASKS=(
    google-chrome
    firefox
    lastpass
)
brew cask install ${CASKS[@]}

#File Storage
brew cask install google-backup-and-sync
brew cask install google-drive-file-stream
brew cask install dropbox

# File Storage
echo "Installing FILE STORAGE cask apps..."
CASKS=(
    google-backup-and-sync
    google-drive-file-stream
    dropbox
)
brew cask install ${CASKS[@]}

#Productivity Apps
echo "Installing PRODUCTIVITY cask apps..."
CASKS=(
    microsoft-office
    adobe-creative-cloud
    evernote
    omnidisksweeper
    spectacle
}
brew cask install ${CASKS[@]}

#Writing Apps
echo "Installing WRITING cask apps..."
CASKS=(
brew cask install basictex
brew cask install tex-live-utility
brew install pandoc
brew install pandoc-citeproc
brew cask install zotero
brew cask install mendeley
}
brew cask install ${CASKS[@]}

#Entertainment
brew cask install spotify
brew cask install vlc
}
brew cask install ${CASKS[@]}

echo "Installing fonts..."
brew tap caskroom/fonts
FONTS=(
    font-inconsolidata
    font-roboto
    font-clear-sans
)
brew cask install ${FONTS[@]}

echo "Installing Python packages..."
PYTHON_PACKAGES=(
    ipython
    virtualenv
    virtualenvwrapper
)
sudo pip install ${PYTHON_PACKAGES[@]}

echo "Installing Ruby gems"
RUBY_GEMS=(
    bundler
    filewatcher
    cocoapods
)
sudo gem install ${RUBY_GEMS[@]}
