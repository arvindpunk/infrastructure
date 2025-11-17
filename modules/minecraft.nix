{ modulesPath, pkgs, ... }:
{

  services.minecraft-server = {
    enable = true;
    eula = true;
    package = pkgs.papermc;
    declarative = true;

    serverProperties = {
      difficulty = "normal";
      gamemode = "survival";
      motd = "OSDCraft";
      spawn-protection = 0;
      online-mode = "false";
    };
  };

}
