{ pkgs, pkgs-unstable, pkgs-main, config, inputs, ... }:

{
  # AI-powered coding assistants and development tools
  # These tools are specifically designed for software development workflows
  environment.systemPackages = [
    pkgs.aider-chat             # AI pair programming tool with git integration
    pkgs-main.claude-code-bin   # Claude's official CLI for development (from nixpkgs main)
    pkgs-unstable.amp-cli       # Amp AI coding agent CLI
    pkgs-unstable.antigravity   # Agentic development platform, evolving the IDE into the agent-first era

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
