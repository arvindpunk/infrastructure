{
  isNormalUser = true;
  home = "/home/arvindpunk";
  extraGroups = [ "wheel" "networkmanager" ];
  openssh.authorizedKeys.keys = (import ./arvindpunk.public-keys.nix);
}
