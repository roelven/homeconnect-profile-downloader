#!/bin/bash
set -e
echo "Preparing macOS build package..."

mkdir -p /app/out/build

rm -rf /tmp/homeconnect-app
mkdir -p /tmp/homeconnect-app

# Copy the essential files for building on macOS
cp -r index.html loading.html download.html main.js preload.js style.css /tmp/homeconnect-app/
cp -r package.json package-lock.json forge.config.js /tmp/homeconnect-app/
[ -d "doc" ] && cp -r doc /tmp/homeconnect-app/

# Create a simple build script for macOS
cat > /tmp/homeconnect-app/build-macos.sh << 'EOFSCRIPT'
#!/bin/bash

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js 18+ before proceeding."
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the app for macOS
echo "Building app for macOS..."
npm run package:all

echo "Build completed!"
echo "Your macOS app is available in the out/ directory."
echo "To run it, open the .app file in the out/homeconnect-profile-downloader-darwin-* directory."
EOFSCRIPT

# Make the script executable
chmod +x /tmp/homeconnect-app/build-macos.sh

# Create a README for macOS build
cat > /tmp/homeconnect-app/README.macos.md << 'EOFREADME'
# Home Connect Profile Downloader - macOS Build Package

This package contains everything you need to build the Home Connect Profile Downloader app on your macOS system.

## Build Instructions

1. Make sure you have Node.js 18+ installed. If not, you can install it with Homebrew:
   ```bash
   brew install node@18
   ```

2. Open Terminal and navigate to this directory.

3. Run the build script:
   ```bash
   ./build-macos.sh
   ```

4. Once completed, you'll find the app in the `out/` directory.

5. Move the app to your Applications folder or run it directly from the build location.

## Running the App

The first time you run the app, you may need to right-click on it and select "Open" to bypass macOS security restrictions for unsigned apps.

## Troubleshooting

If you encounter any issues during the build process:

1. Make sure you're using Node.js 18+
2. Try removing the node_modules directory and running the build script again
3. Check that you have sufficient permissions to write to the current directory
EOFREADME

# Package it all up
cd /tmp
tar -czvf /app/out/build/homeconnect-profile-downloader-macos-package.tar.gz homeconnect-app

echo "Package created at /app/out/build/homeconnect-profile-downloader-macos-package.tar.gz"
ls -la /app/out/build