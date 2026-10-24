# Sets reasonable OS X defaults.
#
# Or, in other words, set shit how I like in OS X.
#
# The original idea (and a couple settings) were grabbed from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.osx
#
# Run ./set-defaults.sh and you'll be good to go.

info ()    { printf "\r  [ \033[00;34m..\033[0m ] $1\n"; }
success () { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"; }

# set_default <domain> <key> <type> <value> — keeps a value you already set unless FORCE=1
set_default () {
  if [ -z "$FORCE" ] && defaults read "$1" "$2" >/dev/null 2>&1; then
    info "kept existing $1 $2 = $(defaults read "$1" "$2")"
    return
  fi
  defaults write "$1" "$2" "$3" "$4"
  success "set $1 $2 = $4"
}

# Disable press-and-hold for keys in favor of key repeat.
set_default NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Use AirDrop over every interface. srsly this should be a default.
set_default com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Always open everything in Finder's list view. This is important.
set_default com.apple.Finder FXPreferredViewStyle -string Nlsv

# Show the ~/Library folder.
chflags nohidden ~/Library

# Set a really fast key repeat.
set_default NSGlobalDomain KeyRepeat -int 0

# Set the Finder prefs for showing a few different volumes on the Desktop.
set_default com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
set_default com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Run the screensaver if we're in the bottom-left hot corner.
# defaults write com.apple.dock wvous-bl-corner -int 5
# defaults write com.apple.dock wvous-bl-modifier -int 0

# Hide Safari's bookmark bar.
# defaults write com.apple.Safari ShowFavoritesBar -bool false

# Set up Safari for development.
set_default com.apple.Safari IncludeInternalDebugMenu -bool true
set_default com.apple.Safari IncludeDevelopMenu -bool true
set_default com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
set_default com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
set_default NSGlobalDomain WebKitDeveloperExtras -bool true

# font smoothing for all LCD
set_default NSGlobalDomain AppleFontSmoothing -int 2

# add recent items to the dock (once — -array-add appends a new tile every run)
if ! defaults read com.apple.dock persistent-others 2>/dev/null | grep -q recents-tile; then
  defaults write com.apple.dock persistent-others -array-add '{ "tile-data" = { "list-type" = 1; }; "tile-type" = "recents-tile"; }' && killall Dock
fi
