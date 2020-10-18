{
  description = "My Nix Blog";

  inputs.nixpkgs.url =
    "github:NixOS/nixpkgs/469f14ef0fade3ae4c07e4977638fdf3afc29e08";
  
  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          (self: super: {
            styx = super.styx.overrideAttrs (oldAttrs: {
              src = super.applyPatches {
                name = "styx-src";
                src = fetchTree {
                  type = "git";
                  url = "https://github.com/styx-static/styx";
                  rev = "0f0a878156eac416620a177cc030fa9f2f69b1b8";
                };
                patches = [ ./lib.patch ];
              };
            });
          })
        ];
      };
    in {
      defaultPackage.x86_64-linux = pkgs.callPackage ./src { };

      generateSite = let
        generateSite = pkgs.writeScript "generate-site" ''
          mkdir build
          cp -rf ${self.defaultPackage.x86_64-linux}/* build/
        '';
      in {
        type = "app";
        program = "${generateSite}";
      };

      devShell.x86_64-linux = pkgs.mkShell { buildInputs = [ pkgs.styx ]; };
    };
}
