{ pkgs, ... }:

{
  # Enable Kasm
  # services.kasmweb = {
  #   enable = true;
  #   listenPort = 9999;
  # };

  # Enable Containerd
  # virtualisation.containerd.enable = true;

  # Enable Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings.features.cdi = true;
    };
    # Add kernel module support
    extraOptions = "--iptables=false";
  };
  users.extraGroups.docker.members = [ "dev" ];


  # Enable Podman
  virtualisation.podman = {
    enable = true;

    # Cannot use dockerCompat when Docker is enabled
    # dockerCompat = true;
    # Cannot use dockerSocket when Docker is enabled
    # dockerSocket.enable = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };
  environment.variables.DBX_CONTAINER_MANAGER = "podman";
  users.extraGroups.podman.members = [ "dev" ];

  environment.systemPackages = with pkgs; [
    # nvidia-docker
    nerdctl

    # firecracker
    # firectl
    # flintlock

    distrobox
    qemu
    lima

    podman-compose
    podman-tui

    docker-compose
    # lazydocker
    # docker-credential-helpers
  ];
}
