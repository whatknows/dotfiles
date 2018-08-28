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


#####
# FUNCTIONS
#####

# Run `dig` and display the most useful info
# function brewifnew() {
#   if [ ! $(brew ls | grep $1) ]; then
#       echo Installing $1...
#       brew install $1;
#   fi
# }


#####
# MAIN
#####
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Start bootstrapping..."

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
echo ""
echo ""
echo ""
echo ""
echo ""
echo "HOMEBREW"

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Fix settings to make Homebrew happy
# These are recommendations from `brew doctor`
sudo chown -R $(whoami) /usr/local/lib /usr/local/sbin

# Update homebrew recipes
echo "Updating Homebrew..."
brew update

######
# Install OS level packages
######
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Installing OS level packages..."
# Install GNU core utilities (those that come with macOS are outdated).

# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
if test ! $(brew ls | grep coreutils); then
    echo "Installing coreutils..."
    brew install coreutils
fi

# Install some other useful utilities like `sponge`.
if test ! $(brew ls | grep moreutils); then
    echo "Installing moreutils..."
    brew install moreutils
fi

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
if test ! $(brew ls | grep findutils); then
    echo "Installing findutils..."
    brew install findutils
fi

OS_PACKAGES=(
    gnu-sed
    gnu-tar
    gnu-indent
    gnu-which
    grep
)
for p in ${OS_PACKAGES[@]}
do
  if test ! $(brew ls | grep ${p}); then
    echo "Installing ${p}..."
    brew install ${p} --with-default-names
  fi
done


######
# INSTALL BASH
######
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Installing Bash..."

# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
if test ! $(brew ls | grep -x bash); then
  brew install bash
fi
if test ! $(brew ls | grep bash-completion@2); then
  brew install bash-completion@2
fi

# Switch to using brew-installed bash as default shell
if ! fgrep '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

# Install font tools.
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Installing fonts..."
brew tap caskroom/fonts
brew tap bramstein/webfonttools

# Install brews
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Installing brews..."

comm -23 \
  <(grep -v '^#' init/brew.txt | sort) \
  <( \
    { \
      brew list --full-name | awk '{print $9}';
    } \
    | sort \
  ) \
  | xargs brew install


echo "Cleaning up..."
brew cleanup

#####
# INSTALL CASK APPS
#####
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Installing cask apps..."

comm -23 \
  <(grep -v '^#' init/casks.txt | grep -v -e '^$' | sort) \
  <( \
    { \
      brew cask ls --full-name | sed -e 's/caskroom\/fonts\///g'; \
    } \
    | sort \
  ) \
  | xargs brew cask install --appdir=/Applications


#####
# CLEAN UP!
#####

# Remove old taps
echo "Remove old taps..."
comm -13 \
  <(sort init/brew.txt) \
  <( \
      brew leaves | sed -e 's/bramstein\/webfonttools\///g' | sort \
  ) \
  | xargs brew rm


# Remove old cask taps
# If it is no longer in casks.txt, it is gone!
echo "Remove old casks..."
comm -13 \
  <(grep -v '^#' init/casks.txt | grep -v -e '^$' | sort) \
  <( \
    { \
      brew cask ls --full-name | sed -e 's/caskroom\/fonts\///g' | sed -e 's/homebrew\/cask-fonts\///g';
    } \
    | sort \
  ) \
  | xargs brew cask rm

  # s#^#Caskroom/cask/#'

#####
# PYTHON ENVIRONMENT CONFIG
#####
echo ""
echo ""
echo ""
echo ""
echo ""
echo "PYTHON"

echo "Linking python3..."
brew link python3
brew cleanup python3

echo "Installing Python packages..."
PYTHON_PACKAGES=(
    ipython
    virtualenv
    virtualenvwrapper
)
for p in ${PYTHON_PACKAGES[@]}
do
  pip list | grep '\<${p}\>\s'
  if [ $? -eq 0 ]; then
    sudo pip install ${p}
  fi
  pip3 list | grep '\<${p}\>\s'
  if [ $? -eq 0 ]; then
    sudo pip3 install ${p}
  fi
done

#####
# RUBY GEMS
#####
echo ""
echo ""
echo ""
echo ""
echo ""
echo "RUBY"

echo "Installing Ruby gems..."
RUBY_GEMS=(
    bundler
    filewatcher
    cocoapods
    jekyll
)
for p in ${RUBY_GEMS[@]}
do
  gem list | grep '\<${p}\>\s'
  if [ $? -eq 0 ]; then
    sudo gem install ${p}
  fi
done

#####
# NODE PACKAGES
#####
echo ""
echo ""
echo ""
echo ""
echo ""
echo "NODE"

echo "Upgrading npm..."
npm install -g npm

npm install -g grunt-cli



#####
# ATOM PACKAGES
#####
echo ""
echo ""
echo ""
echo ""
echo ""
echo "ATOM PACKAGES"

echo "Upgrading..."
apm upgrade

echo "Installing new packages..."
grep -v '^#' init/atom-packages.txt | grep -v -e '^$' | xargs apm install

#####
# INSTALL APP STORE software
#####
echo ""
echo ""
echo ""
echo ""
echo ""
echo "MACOS APP STORE"

# Skip if logged in
if test ! $(mas account); then
  echo "Signing in..."
  mas signin jedbrubaker@gmail.com
fi

# Upgrade
echo "Upgrading..."
mas upgrade

# For this service, you have to search for the application includes
echo "Installing..."
# -- Bear
mas install 1091189122
# -- MonthlyCal Notifications Widget
mas install 935250717




############
## TROUBLE?
############
#
# Getting that git error about gpg? Try this hack:
# > git config commit.gpgsign false
# https://github.com/desktop/desktop/issues/1391
# You might have to do it in the dir of the repo.
