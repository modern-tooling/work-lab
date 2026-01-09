#!/usr/bin/env bash
# Example post-start.sh
# Copyright (c) 2026 Ryan Snodgrass. MIT License.
# Copy to ~/.config/work-lab/post-start.sh
# Runs every time the devcontainer starts.

# Refresh credentials
# aws sso login --profile my-profile

# Start background services
# some-daemon &

# Set environment variables
# export MY_VAR="value"

echo "Custom post-start complete"
