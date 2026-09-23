{
  description = "Hayden's dotfiles: nix-darwin (macOS) + home-manager (macOS & Linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      # Change these if your username differs on a machine; the repo MUST be
      # cloned to ~/dev/dotfiles because configs are symlinked live from there.
      user = {
        name = "haydenduffy";
        fullName = "Hayden Duffy";
        email = "hayden@coder.com";
        dotfiles = "dev/dotfiles"; # relative to $HOME
      };

      linuxHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit user; };
          modules = [
            ./nix/home
            ./nix/home/linux.nix
          ];
        };
    in
    {
      # macOS: sudo darwin-rebuild switch --flake ~/dev/dotfiles#macbook
      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user; };
        modules = [
          ./nix/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = { inherit user; };
              users.${user.name}.imports = [
                ./nix/home
                ./nix/home/darwin.nix
              ];
            };
          }
        ];
      };

      # Linux: home-manager switch --flake ~/dev/dotfiles#linux-$(uname -m)
      homeConfigurations = {
        linux-x86_64 = linuxHome "x86_64-linux";
        linux-aarch64 = linuxHome "aarch64-linux";
      };
    };
}
