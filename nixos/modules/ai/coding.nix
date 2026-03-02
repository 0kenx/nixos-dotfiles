{ pkgs, pkgs-unstable, pkgs-main, config, inputs, ... }:

let
  # OpenAI Codex CLI wrapper: lazily npm-installs on first run
  openai-codex = pkgs.writeShellScriptBin "codex" ''
    export PATH="${pkgs.nodejs_22}/bin:$PATH"
    export HOME="''${HOME:-/tmp}"
    export npm_config_cache="$HOME/.cache/openai-codex-npm"

    INSTALL_DIR="$HOME/.local/share/openai-codex-nix"
    if [ ! -f "$INSTALL_DIR/node_modules/.package-lock.json" ]; then
      mkdir -p "$INSTALL_DIR"
      cd "$INSTALL_DIR"
      cat > package.json << 'PKGJSON'
    {
      "name": "openai-codex-nix",
      "private": true,
      "dependencies": {
        "@openai/codex": "latest"
      }
    }
    PKGJSON
      npm install 2>/dev/null
    fi

    exec node "$INSTALL_DIR/node_modules/@openai/codex/bin/codex.js" "$@"
  '';
in
{
  # AI-powered coding assistants and development tools
  # These tools are specifically designed for software development workflows
  environment.systemPackages = [
    pkgs.aider-chat             # AI pair programming tool with git integration
    pkgs-main.claude-code-bin   # Claude's official CLI for development (from nixpkgs main)
    pkgs-unstable.amp-cli       # Amp AI coding agent CLI
    pkgs-unstable.antigravity   # Agentic development platform, evolving the IDE into the agent-first era
    openai-codex                # OpenAI Codex CLI agent (npm-wrapped)

    # Claude Desktop temporarily disabled due to hash mismatch 0.12.29
    # inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
  ];

  # Future expansion possibilities:
  # - GitHub Copilot CLI
  # - Continue.dev
  # - Cursor IDE integrations
  # - Code review assistants
  # - Documentation generators
}
