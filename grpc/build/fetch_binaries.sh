#!/bin/sh
set -e

# Function to get latest release tag from GitHub
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        GRPCURL_ARCH="x86_64"
        GRPCUI_ARCH="x86_64"
        GHZ_ARCH="x86_64"
        EVANS_ARCH="amd64"
        ;;
    aarch64)
        GRPCURL_ARCH="arm64"
        GRPCUI_ARCH="arm64"
        GHZ_ARCH="arm64"
        EVANS_ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

echo "Installing gRPC debugging tools for $ARCH..."

# Get latest versions from GitHub
echo "Fetching latest release versions..."
GRPCURL_VERSION=$(get_latest_release "fullstorydev/grpcurl")
GRPCUI_VERSION=$(get_latest_release "fullstorydev/grpcui")
GHZ_VERSION=$(get_latest_release "bojand/ghz")
EVANS_VERSION=$(get_latest_release "ktr0731/evans")

# Install grpcurl
echo "Installing grpcurl ${GRPCURL_VERSION}..."
wget -q -O grpcurl.tar.gz "https://github.com/fullstorydev/grpcurl/releases/download/${GRPCURL_VERSION}/grpcurl_${GRPCURL_VERSION#v}_linux_${GRPCURL_ARCH}.tar.gz"
tar -xzf grpcurl.tar.gz -C "$INSTALL_DIR" grpcurl
chmod +x "$INSTALL_DIR/grpcurl"
rm grpcurl.tar.gz
echo "✓ grpcurl installed"

# Install grpcui
echo "Installing grpcui ${GRPCUI_VERSION}..."
wget -q -O grpcui.tar.gz "https://github.com/fullstorydev/grpcui/releases/download/${GRPCUI_VERSION}/grpcui_${GRPCUI_VERSION#v}_linux_${GRPCUI_ARCH}.tar.gz"
tar -xzf grpcui.tar.gz -C "$INSTALL_DIR" grpcui
chmod +x "$INSTALL_DIR/grpcui"
rm grpcui.tar.gz
echo "✓ grpcui installed"

# Install ghz
echo "Installing ghz ${GHZ_VERSION}..."
wget -q -O ghz.tar.gz "https://github.com/bojand/ghz/releases/download/${GHZ_VERSION}/ghz-linux-${GHZ_ARCH}.tar.gz"
tar -xzf ghz.tar.gz -C "$INSTALL_DIR" ghz
chmod +x "$INSTALL_DIR/ghz"
rm ghz.tar.gz
echo "✓ ghz installed"

# Install evans
echo "Installing evans ${EVANS_VERSION}..."
wget -q -O evans.tar.gz "https://github.com/ktr0731/evans/releases/download/${EVANS_VERSION}/evans_linux_${EVANS_ARCH}.tar.gz"
tar -xzf evans.tar.gz -C "$INSTALL_DIR" evans
chmod +x "$INSTALL_DIR/evans"
rm evans.tar.gz
echo "✓ evans installed"

echo "All tools installed successfully!"
