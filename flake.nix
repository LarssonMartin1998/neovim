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
    in {
        neovim = pkgs.stdenv.mkDerivation {
          pname = "neovim";
          version = "latest-stable-version";

          src = self;

          buildInputs = with pkgs; [
            cmake
            ninja
            clang
            luajit
            luv
          ];

          nativeBuildInputs = with pkgs; [ pkg-config ];

          buildPhase = ''
            make CMAKE_BUILD_TYPE=Release
          '';

          installPhase = ''
            make install DESTDIR=$out
          '';

          passthru = {
            lua = pkgs.luajit;
          };

          # Add metadata here
          meta = with pkgs.lib; {
            description = "Fork of Neovim built from the latest-stable-version tag";
            longDescription = ''
              This is a Neovim built from source, no changes have been made to the repo
              outside of adding a flake and tagging the version that I've built.
              This will always build from the "latest-stable-version" tag, and that is
              in context to my personal config.
            '';
            homepage = "https://github.com/LarssonMartin1998/neovim";
            maintainers = [ maintainers.LarssonMartin1998 ]; # Replace with your username if it's defined
            platforms = platforms.unix; # Add more platforms if needed
            license = with licenses; [ vim asl20 ];
          };
        };
      });

    # Set the default package to the `neovim` attribute for the current system
    defaultPackage = lib.genAttrs supportedSystems (system:
      self.packages.${system}.neovim);
  };
}
