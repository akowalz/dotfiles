#!/bin/bash

# macOS settings. Safe to re-run: each line just sets a value.
# setup.sh runs this, or run it on its own after adding a setting.

echo "Applying macOS settings"

# Keyboard
# Holding a key repeats it, instead of showing the accented-character popup
defaults write -g ApplePressAndHoldEnabled -bool false
# Fast key repeat, with a short delay before it starts
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
# No autocorrect, auto-capitalization, or double-space period
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
# Straight quotes and plain dashes, so pasted shell commands still work
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

# Caps Lock is Control on every keyboard, including ones plugged in later.
# hidutil's mapping is lost on restart, so a LaunchAgent sets it at each login.
capslock_agent=~/Library/LaunchAgents/local.capslock-to-control.plist
mkdir -p ~/Library/LaunchAgents
cat > $capslock_agent <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>local.capslock-to-control</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--set</string>
    <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF
# Reload the agent, which also applies the mapping now
launchctl bootout gui/$(id -u) $capslock_agent 2>/dev/null
launchctl bootstrap gui/$(id -u) $capslock_agent

# Trackpad
# Tap to click, for the built-in and Bluetooth trackpads
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1

# Menu bar and windows
# Always show the menu bar, in full screen too
defaults write -g _HIHideMenuBar -bool false
defaults write -g AppleMenuBarVisibleInFullscreen -bool true
# Leave gaps between tiled windows
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool true

# Dock
# Hide the Dock until the pointer reaches it
defaults write com.apple.dock autohide -bool true
# Show the hidden Dock without a delay, and slide it in quickly
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2
# Dim the icons of hidden apps
defaults write com.apple.dock showhidden -bool true
# Don't show recently used apps
defaults write com.apple.dock show-recents -bool false

# Finder
# Show every file's extension
defaults write -g AppleShowAllExtensions -bool true
# Search the current folder, not the whole Mac
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
# Open new windows in the home directory
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"
# Show the path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
# List view by default, with folders above files when sorting by name
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Don't warn when changing a file's extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Screenshots
defaults write com.apple.screencapture type jpg
# Save them to ~/Screenshots instead of the Desktop, without window shadows
# (Newer macOS reads location-screenshot and location-screenrecording, and
# falls back to the Desktop with only location set. These match what the
# Cmd-Shift-5 Options menu writes.)
mkdir -p ~/Screenshots
for key in location location-screenshot location-screenrecording location-last
do
  defaults write com.apple.screencapture $key -string "~/Screenshots"
done
defaults write com.apple.screencapture target -string file
defaults write com.apple.screencapture disable-shadow -bool true

# Restart what reads these settings, so they apply now
killall Finder
killall Dock
killall SystemUIServer

echo "Log out and back in for the keyboard, trackpad and menu bar changes to take effect"
