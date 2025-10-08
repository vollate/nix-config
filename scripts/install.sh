#!/usr/bin/env bash

# NixOS Configuration Installation Script
# Usage: ./scripts/install.sh [hostname]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
HOSTNAME=${1:-"tb-amd-6800h"}
FLAKE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

echo -e "${BLUE}🚀 NixOS Configuration Deployment${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "Hostname: ${GREEN}${HOSTNAME}${NC}"
echo -e "Flake Directory: ${GREEN}${FLAKE_DIR}${NC}"
echo ""

# Check if we're running as root for system rebuild
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}❌ Please run this script as a regular user, not as root${NC}"
    echo -e "${YELLOW}The script will use sudo when needed${NC}"
    exit 1
fi

# Check if flake.nix exists
if [[ ! -f "${FLAKE_DIR}/flake.nix" ]]; then
    echo -e "${RED}❌ flake.nix not found in ${FLAKE_DIR}${NC}"
    exit 1
fi

# Check if the hostname configuration exists
if [[ ! -d "${FLAKE_DIR}/hosts/${HOSTNAME}" ]]; then
    echo -e "${RED}❌ Host configuration not found: ${HOSTNAME}${NC}"
    echo -e "${YELLOW}Available hosts:${NC}"
    ls -1 "${FLAKE_DIR}/hosts/" | sed 's/^/  - /'
    exit 1
fi

# Function to run commands with nice output
run_step() {
    local step_name="$1"
    local command="$2"
    
    echo -e "${YELLOW}📦 ${step_name}...${NC}"
    if eval "$command"; then
        echo -e "${GREEN}✅ ${step_name} completed${NC}"
    else
        echo -e "${RED}❌ ${step_name} failed${NC}"
        exit 1
    fi
    echo ""
}

# Pre-deployment checks
echo -e "${YELLOW}🔍 Running pre-deployment checks...${NC}"

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo -e "${RED}❌ Nix is not installed${NC}"
    exit 1
fi

# Check if flakes are enabled
if ! nix --version | grep -q "flakes"; then
    echo -e "${YELLOW}⚠️  Flakes support might not be enabled${NC}"
fi

echo -e "${GREEN}✅ Pre-deployment checks passed${NC}"
echo ""

# Initialize submodules if needed
if [[ -f "${FLAKE_DIR}/.gitmodules" ]] && [[ ! -f "${FLAKE_DIR}/private/.git" ]]; then
    echo -e "${YELLOW}🔑 Initializing private submodule...${NC}"
    cd "${FLAKE_DIR}"

    # Configure git to use SSH config for submodule operations
    git config submodule.private.sshCommand "ssh -F ${HOME}/.ssh/config"

    # Ensure git uses SSH config for submodule operations
    export GIT_SSH_COMMAND="ssh -F ${HOME}/.ssh/config"

    if git submodule update --init --recursive; then
        echo -e "${GREEN}✅ Submodule initialized${NC}"
    else
        echo -e "${RED}❌ Failed to initialize submodule${NC}"
        echo -e "${YELLOW}💡 Make sure your SSH key is configured correctly in ~/.ssh/config${NC}"
        echo -e "${YELLOW}💡 You can manually run: git config submodule.private.sshCommand 'ssh -F ~/.ssh/config'${NC}"
        exit 1
    fi
    echo ""
fi

# Deployment steps
echo -e "${BLUE}🔧 Starting deployment...${NC}"

# Build the configuration first (dry-run)
run_step "Testing configuration build" \
    "nix build --dry-run '${FLAKE_DIR}#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel'"

# Deploy the configuration
run_step "Deploying NixOS configuration" \
    "sudo nixos-rebuild switch --flake '${FLAKE_DIR}#${HOSTNAME}'"

# Success message
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo -e "  1. Reboot to ensure all changes take effect"
echo -e "  2. Check that all services are running correctly"
echo -e "  3. Update your Git configuration in ~/.gitconfig.local"
echo -e "  4. Set up your development environment"
echo ""
echo -e "${YELLOW}📚 Useful commands:${NC}"
echo -e "  - Update system: ${GREEN}sudo nixos-rebuild switch --upgrade --flake .${NC}"
echo -e "  - Clean old generations: ${GREEN}sudo nix-collect-garbage -d${NC}"
echo -e "  - Enter dev shell: ${GREEN}nix develop${NC}"
echo -e "  - Format code: ${GREEN}nix fmt${NC}" 