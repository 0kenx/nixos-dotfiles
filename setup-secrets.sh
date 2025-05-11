#!/bin/bash
# Script to set up the secrets submodule and encryption

# Check if we're in the root directory of the repository
if [ ! -d "nixos" ] || [ ! -d "nixos/nixos-secrets" ]; then
    echo "This script must be run from the root of the nixos-dotfiles repository"
    exit 1
fi

# Setup age keys
echo "Setting up age keys..."
./nixos/nixos-secrets/setup-age-key.sh

echo ""
echo "Next steps:"
echo "1. Edit .sops.yaml in the nixos/nixos-secrets directory to use your age public key"
echo "2. Update your secrets in nixos/nixos-secrets/common/secrets.yaml and nixos/nixos-secrets/hosts/*/secrets.yaml"
echo "3. Run ./nixos/nixos-secrets/encrypt-secrets.sh to encrypt your secrets"
echo "4. Commit and push your encrypted secrets:"
echo "   cd nixos/nixos-secrets"
echo "   git add ."
echo "   git commit -m \"Update encrypted secrets\""
echo "   git push origin main"
echo ""
echo "5. Update the submodule reference in the main repository:"
echo "   cd ../.."
echo "   git add nixos/nixos-secrets"
echo "   git commit -m \"Update secrets submodule\""
echo "   git push origin main"