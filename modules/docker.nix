{ modulesPath, pkgs, ... }: {

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      # apps
      # hello = (import ../docker/apps/hello.nix);
    };
  };
}
