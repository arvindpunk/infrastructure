{ modulesPath, pkgs, ... }:
{

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
    #   plugins = [
    #     "git"
    #     "zsh-autosuggestions"
    #   ];
      theme = "robbyrussell";
    };
    shellInit = ''
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    '';
  };
}
