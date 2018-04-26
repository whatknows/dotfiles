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

echo ""
echo ""
echo ""
echo ""
echo ""
echo "Starting bootstrapping..."

# echo "Creating an SSH key for you..."
# ssh-keygen -t rsa
#
# echo "Please add this public key to Github"
# echo "https://github.com/account/ssh		"
# read -p "Press [Enter] key after this..."
#
# ######
# # INSTALL XCODE
# ######
#
# # Install Xcode
# echo "Installing xcode-stuff"
# xcode-select --install
# # Accept agreement
# sudo xcodebuild -license

######
# INSTALL HOMEBREW
######

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
echo "Updating Homebrew..."
brew update

######
# Install OS level packages
######

echo "Installing OS level packages..."
# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-indent --with-default-names
brew install gnu-which --with-default-names
brew install grep --with-default-names

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash

echo "Installing packages..."

comm -23 \
  <(sort brew.txt) \
  <( \
    { \
      brew ls --full-name;
    } \
    | sort \
  ) \
  | xargs brew install

echo "Cleaning up..."
brew cleanup

echo "Adding 'brewup' alias…"
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'

#####
# INSTALL CASKS
#####

echo "Installing cask..."
brew install caskroom/cask/brew-cask

#####
# INSTALL CASK APPS
#####

comm -23 \
  <(grep -v '^#' casks.txt | sort) \
  <( \
    { \
      brew cask ls --full-name \
    } \
    | sort \
  ) \
  | xargs brew cask install --appdir=/Applications


# Remove old taps
comm -13 <(sort brew.txt) <(brew leaves | sort) \
  | xargs brew rm


# Remove old cask taps
# If it is no longer in casks.txt, it is gone!
comm -13 \
  <(sort casks.txt) \
  <(brew cask ls) \
  | xargs brew cask rm


echo "Installing fonts..."
brew tap caskroom/fonts
FONTS=(
    font-inconsolata
    font-roboto
    font-clear-sans
    font-fontawesome
    font-foundation-icons
    font-open-iconic
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

#####
# ATOM PACKAGES
#####
apm install --packages-file atom-packages.txt

#####
# INSTALL APP STORE software
#####
brew install mas
mas signin jedbrubaker@gmail.com

# For this service, you have to search for the application includes
# -- Bear
mas install 1091189122
# -- MonthlyCal Notifications Widget
mas install 935250717
