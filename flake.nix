{
  description = "Neovim built from source at the 'latest-stable-version' tag";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: let
    lib = nixpkgs.lib;
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  in {
    packages = lib.genAttrs supportedSystems (system: let
      pkgs = import nixpkgs { inherit system; };
    in
      pkgs.stdenv.mkDerivation {
        pname = "neovim";
        version = "latest-stable-version";

        src = builtins.fetchGit {
          url = "https://github.com/LarssonMartin1998/neovim";
          ref = "refs/tags/latest-stable-version";
        };

        buildInputs = with pkgs; [
          cmake
          ninja
          clang
        ];

        nativeBuildInputs = with pkgs; [ pkg-config ];

        buildPhase = ''
          make CMAKE_BUILD_TYPE=Release
        '';

        installPhase = ''
          make install DESTDIR=$out
        '';
      });

    # Set the default package to the `neovim` attribute for the current system
    defaultPackage = lib.genAttrs supportedSystems (system:
      self.packages.${system}.neovim);
  };
}
