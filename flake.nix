{ ... } : {
    description = "Neovim built from source at the 'latest-stable-release' tag";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
    };

    outputs = { self, nixpkgs }: {
        packages.${self.system} = let
            pkgs = import nixpkgs { system = self.system; };
        in
            neovim = pkgs.stdenv.mkDerivation {
                pname = "neovim";
                version = "latest-stable-release";

                src = pkgs.fetchgit {
                    url = self.url;
                    rev = "refs/tags/latest-stable-release";
                    sha256 = "sha256-placeholder";
                };

                buildInputs = with pkgs; [
                    cmake
                    ninja
                    clang
                ];

                nativeBuildInputs = with pkgs; [ pkg-config ];
                buildPhase = ''
                    make CMAKE_BUILD_TYPE=Release
                ''

                installPhase = ''
                    make install
                ''
            };
    };
}
