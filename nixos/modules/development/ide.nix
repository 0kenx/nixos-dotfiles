{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    # Language servers and debugging tools
    lldb
    dioxus-cli
    trunk
    
    # IDEs and editors
    vscode

    # From unstable channel
    pkgs-unstable.code-cursor
  ];
}