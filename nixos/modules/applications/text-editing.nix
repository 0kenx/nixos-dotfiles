{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # LaTeX distribution
    (texlive.combine {
      inherit (texlive) scheme-medium enumitem titlesec;
    })
  ];
}
