{ modulesPath, pkgs, ... }: {
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "arvindpunk+acme@gmail.com";
  # security.acme.defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
  security.acme.certs."arvindpunk.dev".extraDomainNames =
    [ "www.arvindpunk.dev" "api.arvindpunk.dev" ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      "arvindpunk.dev" = {
        default = true;
        forceSSL = true;
        enableACME = true;
        root = "/var/www/";
      };
      "api.arvindpunk.dev" = {
        forceSSL = true;
        useACMEHost = "arvindpunk.dev";
        locations = {
          "/word-proximity/internal/" = { return = "401"; };
          "/word-proximity/" = { proxyPass = "http://127.0.0.1:5001/"; };
          "/rps-tag/internal/" = { return = "401"; };
          "/rps-tag/" = {
            proxyPass = "http://127.0.0.1:2567/";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
