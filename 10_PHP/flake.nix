{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.php-debug = nixpkgs.legacyPackages.x86_64-linux.php.buildEnv {
      extensions = ({ enabled, all }: enabled ++ [ all.xdebug ]);
      extraConfig = ''
        xdebug.mode=debug
      '';
    };

  };
}
