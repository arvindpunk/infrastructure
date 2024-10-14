{ modulesPath, pkgs, ... }: {
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
    ./modules/docker.nix
    ./modules/nginx.nix
    ./modules/postgres.nix
  ];
  ec2.efi = true;

  # swapDevices = [{
  #   device = "/var/lib/swapfile";
  #   size = 2 * 1024;
  # }];

  security.sudo.wheelNeedsPassword = false;

  users.users = { arvindpunk = (import ./users/arvindpunk.nix); };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.tmux.enable = true;
  programs.neovim.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 20 22 80 443 8080 ];
  };

  system.stateVersion = "24.05";
}
