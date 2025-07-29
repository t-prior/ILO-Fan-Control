#!/bin/sh

# === SECTION 0: Double-confirm Security Override Switch ===

echo ""
echo "⚠️  IMPORTANT: This process requires the iLO Security Override Switch to be ENABLED."
echo "Physically locate the switch or jumper on the server motherboard and flip it ON."
echo ""

while true; do
    echo "❓ Is the iLO Security Override Switch flipped ON? Type 'yes' to confirm:"
    read -r CONFIRM1
    if [ "$CONFIRM1" = "yes" ]; then
        echo "✅ Confirmed. Now confirm again to proceed:"
        read -r CONFIRM2
        if [ "$CONFIRM2" = "yes" ]; then
            echo "✔ Proceeding with installation..."
            break
        else
            echo "✘ Second confirmation failed. Please flip the switch and restart the installer."
            exit 1
        fi
    else
        echo "✘ First confirmation not received. Please flip the switch and restart the installer."
        exit 1
    fi
done

# === SECTION 1: Enforce Root Privileges ===

if [ "$(id -u)" -ne 0 ]; then
    echo "✘ This script must be run as root. Switching to root shell..."
    exec sudo su -c "$0"
    exit 1
fi

set -e

# === SECTION 2: System Setup ===

echo "[1/6] Installing required system packages..."
apt-get update
apt-get install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libdb5.3-dev \
    libbz2-dev \
    libexpat1-dev \
    liblzma-dev \
    tk-dev \
    wget \
    curl \
    git \
    ca-certificates

echo "[2/6] Installing Python 2.7.18..."
cd /usr/src
wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
tar xzf Python-2.7.18.tgz
cd Python-2.7.18
./configure --prefix=/usr/local
make -j"$(nproc)"
make install
ln -sf /usr/local/bin/python2.7 /usr/bin/python

PYTHON_VERSION=$(python --version 2>&1)
echo "Detected Python version: $PYTHON_VERSION"
if echo "$PYTHON_VERSION" | grep -q "Python 2.7.18"; then
    echo "✔ Python 2.7.18 installed."
else
    echo "✘ Python installation failed."
    exit 1
fi

echo "[3/6] Installing pip for Python 2.7..."
cd /tmp
wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
python get-pip.py

pip --version | grep "python 2.7" >/dev/null || {
    echo "✘ pip installation failed."
    exit 1
}

python -m pip install virtualenv

# === SECTION 3: Clone Repo and Build Firmware ===

echo "[4/6] Cloning ilo4_unlock and building firmware..."
cd ~
git clone --recurse-submodules https://github.com/kendallgoto/ilo4_unlock.git
cd ilo4_unlock

python -m virtualenv venv
. venv/bin/activate
pip install -r requirements.txt

./build.sh init
./build.sh 277

# === SECTION 4: Flash Firmware ===

echo "[5/6] Preparing to flash firmware..."
modprobe -r hpilo

mkdir -p flash
cp binaries/flash_ilo4 binaries/CP027911.xml flash/
cp build/ilo4_277.bin.patched flash/ilo4_250.bin

cd flash

echo "Flashing firmware directly using flash_ilo4..."
./flash_ilo4 --direct

echo ""
echo ">>> WAIT: Firmware is flashing. DO NOT interrupt power."
echo ">>> Wait for fans to spin down completely."

# === SECTION 5: Double Confirmation and Shutdown ===

while true; do
    echo ""
    echo "⚠️  Have the fans spun down and the flash completed?"
    echo "Type 'yes' to confirm:"
    read -r CONFIRM3
    if [ "$CONFIRM3" = "yes" ]; then
        echo "Please confirm again — are you absolutely sure the flashing is complete?"
        echo "Type 'yes' again to shut down:"
        read -r CONFIRM4
        if [ "$CONFIRM4" = "yes" ]; then
            echo "✔ Confirmation received. Shutting down now..."
            shutdown now
        else
            echo "✘ Confirmation mismatch. Aborting shutdown."
            exit 1
        fi
    else
        echo "✘ Confirmation not received. Please try again after verifying the fan state."
    fi
done
