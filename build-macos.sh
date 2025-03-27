#!/bin/bash

echo "Preparing Home Connect Profile Downloader macOS build package..."
echo "This process may take a few minutes..."

# Create output directory if it doesn't exist
mkdir -p out

# Run the Docker container to create the macOS build package
docker-compose -f docker-compose.macos-package.yml build && docker-compose -f docker-compose.macos-package.yml up

# Output success message
if [ -f "./out/build/homeconnect-profile-downloader-macos-package.tar.gz" ]; then
    echo "Package created successfully!"
    echo "Your macOS build package is available at: ./out/build/homeconnect-profile-downloader-macos-package.tar.gz"
    echo ""
    echo "To build on macOS:"
    echo "1. Copy this file to your Mac"
    echo "2. Extract it: tar -xzvf homeconnect-profile-downloader-macos-package.tar.gz"
    echo "3. Navigate to the extracted directory: cd homeconnect-app"
    echo "4. Run the build script: ./build-macos.sh"
    echo "5. The built app will be in the out/ directory"
else
    echo "Build failed. Check the Docker logs for more information."
fi