#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== ShopShop WiFi Updater ===${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "wifi-config.json" ]; then
    echo -e "${RED}Error: wifi-config.json not found.${NC}"
    echo "Please run this script from your shop-wifi repo directory."
    exit 1
fi

# Prompt for new password
echo -n "Enter new password for ShopShop: "
read -s NEW_PASSWORD
echo ""

# Validate input
if [ -z "$NEW_PASSWORD" ]; then
    echo -e "${RED}Error: Password cannot be empty.${NC}"
    exit 1
fi

# Confirm
echo ""
echo -e "New password will be: ${GREEN}$NEW_PASSWORD${NC}"
echo -n "Confirm? (y/N): "
read CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "${YELLOW}Cancelled. No changes made.${NC}"
    exit 0
fi

# Update the JSON file
echo ""
echo "Updating wifi-config.json..."

# Use Python to properly update JSON (more reliable than sed)
python3 -c "
import json
with open('wifi-config.json', 'r') as f:
    config = json.load(f)
config['password'] = '$NEW_PASSWORD'
with open('wifi-config.json', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
"

# Check if Python succeeded
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to update wifi-config.json${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Config updated${NC}"

# Git operations
echo ""
echo "Pushing to GitHub..."

git add wifi-config.json

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo -e "${YELLOW}No changes detected (password might be the same).${NC}"
    exit 0
fi

git commit -m "Update ShopShop WiFi password"
git push origin main

# Check if push succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Done!${NC}"
    echo -e "Your site will update in ~30-60 seconds."
    echo -e "Visit: ${YELLOW}https://chubbypenguin69.github.io/wifi-home-automation/${NC}"
    echo ""
    echo -e "${YELLOW}Remember:${NC} You still need to manually change the password"
    echo -e "on your Nokia router at ${YELLOW}http://192.168.1.1${NC}"
else
    echo ""
    echo -e "${RED}✗ Push failed. Check your internet connection or SSH key.${NC}"
    exit 1
fi
