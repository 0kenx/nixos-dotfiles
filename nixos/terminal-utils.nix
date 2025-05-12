{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # core
    curl
    wget
    vim
    file
    jq
    tree
    progress
    ripgrep
    fd # find
    sd # replace
    fzf
    skim # fzf alternative
    rmtrash
    # prettier tools
    lsd # ls
    gping # ping
    procs # ps
    # git
    git
    gh
    lazygit
    delta
    license-generator
    git-ignore
    gitleaks
    git-secrets
    pass-git-helper
    # tools
    just # run scripts
    xh # request
    process-compose # uncontainerized docker
    monolith # save webpage locally
    # compression
    zip
    unzip
    upx



    zellij
    noti
    topgrade
    rewrk
    wrk2
    tealdeer
    aria
    du-dust
    trash-cli
    zoxide
    tokei
    bat
    hexyl
    pandoc
    viu
    tre-command
    yazi
    chafa
    cmatrix
    pipes-rs
    rsclock
    cava
    figlet
  ];
}
