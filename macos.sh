#!/bin/bash

# macOS settings. Safe to re-run: each line just sets a value.
# setup.sh runs this, or run it on its own after adding a setting.

echo "Applying macOS settings"

# Keyboard
# Holding a key repeats it, instead of showing the accented-character popup
defaults write -g ApplePressAndHoldEnabled -bool false

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

# Dock
# Show the hidden Dock without a delay, and slide it in quickly
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2
# Dim the icons of hidden apps
defaults write com.apple.dock showhidden -bool true

# Finder
# Show every file's extension
defaults write -g AppleShowAllExtensions -bool true
# Search the current folder, not the whole Mac
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
# Open new windows in the home directory
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

# Screenshots
defaults write com.apple.screencapture type jpg

# Restart Finder so its settings apply now. The rest wait for a log out.
killall Finder

echo "Log out and back in for the keyboard and Dock changes to take effect"
