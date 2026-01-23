#!/bin/bash
# Flutter installation script for Vercel

# Install Flutter if not exists
if [ ! -d "$HOME/flutter" ]; then
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git $HOME/flutter
fi

# Setup Flutter
export PATH="$PATH:$HOME/flutter/bin"
flutter config --no-analytics
flutter pub get
