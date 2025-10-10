{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # LaTeX distribution
    texlive.combined.scheme-medium
  ];
}
