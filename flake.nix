{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, ... }@inputs:
    let
      # import all the overlays that extend packages via nix or home-manager.
      # Overlays are a nix file within the `overlay` folder or a sub folder in
      # `overlay` that contains a `default.nix`.
      overlays = [
        inputs.nur.overlay
        (import ./pkgs)
        (import ./overlays/st)
      ];


      # I am sure this is ugly to experienced nix users, and might break in all
      # kinds of unexpected ways. This was my first actual function written in
      # nix, and I never really figured out the repl, this is what I ended up
      # with.
      #
      # This function takes a path, and returns a list of every file under it.
      #
      # TODO:
      #   - filter by .nix
      #   - handles readDir's `symlink` and `unknown` types
      #   - is there a better way than (path + ("/" + path))?
      #   - can this be moved into a library and sourced over inline?
      foundryModules =
        let
          lib = inputs.nixpkgs.lib;
          getNixFilesRec = path:
            let
              contents = builtins.readDir path;
              files = builtins.attrNames (lib.filterAttrs (_: v: v == "regular") contents);
              dirs = builtins.attrNames (lib.filterAttrs (_: v: v == "directory") contents);
              nixFiles = lib.filter (p: lib.hasSuffix ".nix" p) files;
            in
            # return the path of all files found in this directory
            (map (p: path + ("/" + p)) nixFiles)
            ++
            # pass each directory into this function again
            (lib.concatMap (d: getNixFilesRec (path + ("/" + d))) dirs);
        in
        getNixFilesRec ./modules;
    in
    # this allows us to get the propper `system` whereever we are running
    inputs.flake-utils.lib.eachSystem [ "x86_64-darwin" "x86_64-linux" ]
      (system: {
        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              black.enable = true;
              nixpkgs-fmt.enable = true;
              prettier.enable = true;
              shellcheck.enable = true;
              yamllint.enable = true;
            };
          };
        };
        devShell = inputs.nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      })
    // {
      nixosConfigurations = {
        alpha = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/alpha/configuration.nix
            ./hosts/alpha/hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = overlays;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = foundryModules;
                users.kyle = import ./users/kyle/full.nix;
              };
            }
          ];
        };
        xi = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/xi/configuration.nix
            #./hosts/xi/hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = overlays;
              # todo: some service user
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = foundryModules;
                users.kyle = import ./users/kyle/ssh.nix;
              };
            }
          ];
        };
      };
      darwinConfigurations.C02CL8GXLVDL = inputs.nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          ./hosts/C02CL8GXLVDL/configuration.nix
          inputs.home-manager.darwinModule
          {
            nixpkgs.overlays = overlays;
            #users.nix.configureBuildUsers = true; # todo: doc: why?
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = foundryModules;
              users."kyle.ondy" = import ./users/kyle/ssh.nix;
            };
          }
        ];
      };
      alpha = self.nixosConfigurations.alpha.config.system.build.toplevel;
      xi = self.nixosConfigurations.xi.config.system.build.toplevel;
      C02CL8GXLVDL = self.darwinConfigurations.C02CL8GXLVDL.system;
    };
}
