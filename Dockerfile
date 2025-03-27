FROM node:18-bullseye

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    fakeroot \
    dpkg \
    rpm \
    libx11-xcb1 \
    libxtst6 \
    libxss1 \
    libasound2 \
    libsecret-1-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the app
COPY . .

# Set environment variables for Electron
ENV USE_SYSTEM_SANDBOX=false
ENV DEBUG=electron-builder

# Create a shell script to build
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Starting build process..."\n\
\n\
# Create directories for caching\n\
mkdir -p /root/.cache/electron\n\
mkdir -p /root/.electron-gyp\n\
\n\
# Download Electron binary for macOS\n\
ELECTRON_VERSION=$(node -e "console.log(require(\`./package.json\`).devDependencies.electron.replace(\`^\`, \`\`))")\n\
echo "Installing Electron version $ELECTRON_VERSION for macOS..."\n\
\n\
# Create a temporary forge config file that targets macOS\n\
cp forge.config.docker.js /tmp/forge.config.js\n\
cp /tmp/forge.config.js forge.config.js\n\
cat forge.config.js\n\
\n\
# Configure npm for macOS builds\n\
export npm_config_target_platform=darwin\n\
export npm_config_target=darwin\n\
\n\
# Run build for x64 architecture\n\
echo "Running electron-forge package for x64..."\n\
npx electron-forge package --platform=darwin --arch=x64\n\
\n\
# Run build for arm64 architecture\n\
echo "Running electron-forge package for arm64..."\n\
npx electron-forge package --platform=darwin --arch=arm64\n\
\n\
# Debug: List the output directory contents\n\
echo "Build output contents:"\n\
find /app/out -type d | sort\n\
find /app/out -type f | sort\n\
\n\
# Package the resulting files\n\
echo "Creating final package..."\n\
mkdir -p /app/out/build\n\
\n\
# Check if files exist before creating tar\n\
if find /app/out -name "*.app" -o -name "homeconnect-profile-downloader-darwin-*" | grep -q .; then\n\
  echo "Packaging macOS builds..."\n\
  cd /app/out\n\
  find . -name "*.app" -o -name "homeconnect-profile-downloader-darwin-*" | xargs tar -czvf build/homeconnect-profile-downloader-mac.tar.gz\n\
  echo "Build completed. Find your build at /app/out/build/homeconnect-profile-downloader-mac.tar.gz"\n\
  ls -la /app/out/build\n\
else\n\
  echo "ERROR: No macOS builds found!"\n\
  echo "Contents of /app/out directory:"\n\
  find /app/out -type f | sort\n\
  exit 1\n\
fi\n\
' > /app/build-mac.sh && chmod +x /app/build-mac.sh

# Set the entrypoint
ENTRYPOINT ["/app/build-mac.sh"]