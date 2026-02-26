{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          jslib = pkgs.buildNpmPackage {
            pname = "fastspell-nvim-jslib";
            version = "0.1.0";

            src = ./jslib;

            npmDepsHash = "sha256-UManohhkExLMo2ftN/X1l6xfnj7QSrFjBswp5MP15OA=";

            dontNpmBuild = false;

            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp -r dist $out/
              cp -r node_modules $out/
              runHook postInstall
            '';
          };
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "fastspell.nvim";
            version = "0.1.0";

            src = ./.;

            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp -r $src/* $out/
              chmod -R u+w $out
              rm -rf $out/jslib/dist $out/jslib/node_modules
              cp -r ${jslib}/* $out/jslib/
              runHook postInstall
            '';

            meta = {
              description = "Fast spell checking for Neovim";
              homepage = "https://github.com/lucaSartore/fastspell.nvim";
              license = lib.licenses.mit;
              maintainers = [ ];
            };
          };
        }
      );
    };
}
