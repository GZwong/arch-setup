#!/bin/bash

# Add eww to PATH temporarily
export PATH="$HOME/Downloads/eww/target/release:$PATH"

# Start the eww daemon in the background
eww daemon &

echo "✅ eww daemon started and PATH updated temporarily."
