{
  description = "Optimized Solidity development environment with Foundry";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    foundry.url = "github:shazow/foundry.nix/monthly";
  };

  outputs = { self, nixpkgs, flake-utils, foundry, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ foundry.overlay ];
        };

        inherit (pkgs) lib;

        # Foundry tools (forge, cast, anvil, chisel)
        foundryToolchain = pkgs.foundry-bin;

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Foundry suite (forge, cast, anvil, chisel)
            foundryToolchain

            # Solidity compiler
            solc

            # Development tools
            lcov  # Code coverage
            jq    # JSON processing

            # Editor
            neovim

            # Task runner
            just
          ];

          shellHook = ''
            echo "🔨 Foundry Solidity Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Foundry: $(forge --version | head -n1)"
            echo "Solc:    $(solc --version | head -n1)"
            echo ""
            echo "Available tools:"
            echo "  forge     - Ethereum testing framework"
            echo "  cast      - Swiss army knife for Ethereum"
            echo "  anvil     - Local Ethereum node"
            echo "  chisel    - Solidity REPL"
            echo "  just      - Task runner (see justfile)"
            echo ""
            echo "Quick start:"
            echo "  just init           - Initialize Foundry project"
            echo "  just build          - Build contracts"
            echo "  just test           - Run tests"
            echo "  just help           - Show all tasks"
          '';
        };
      });
}
