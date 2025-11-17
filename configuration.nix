{ modulesPath, pkgs, ... }: {
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
    # ./modules/clickhouse.nix
    # ./modules/docker.nix
    ./modules/minecraft.nix
    # ./modules/nginx.nix
    # ./modules/postgres.nix
    ./modules/zsh.nix
  ];
  ec2.efi = true;

  # swapDevices = [{
  #   device = "/var/lib/swapfile";
  #   size = 2 * 1024;
  # }];

  security.sudo.wheelNeedsPassword = false;

  users.defaultUserShell = pkgs.zsh;
  users.users = { arvindpunk = (import ./users/arvindpunk.nix); };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.tmux.enable = true;
  programs.neovim.enable = true;
  programs.git = {
    enable = true;
    config = {
      user.name = "Arvind PJ";
      user.email = "arvindpunk@gmail.com";
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 20 22 80 443 5432 8080 9418 25565 ];
  };

  system.stateVersion = "25.05";
}
