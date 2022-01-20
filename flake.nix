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
    sops-nix.url = "github:Mic92/sops-nix";
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
      getModules = path:
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
        getNixFilesRec path;

      hmModules = getModules ./modules/hm_modules;
      systemModules = getModules ./modules/system_modules;
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
          modules = systemModules ++ [
            ./hosts/alpha/configuration.nix
            ./hosts/alpha/hardware-configuration.nix

            ./users/kyle.nix # todo: some service user

            # todo: refactor these into something else
            ./hosts/_includes/common.nix
            ./hosts/_includes/docker.nix
            ./hosts/_includes/kvm.nix
            ./hosts/_includes/laptop.nix
            ./hosts/_includes/wifi_networks.nix

            inputs.sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.home-manager
            {
              systemFoundry.deployment_target.enable = true;
              nixpkgs.overlays = overlays;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = hmModules;
                users.kyle = import ./profiles/full.nix;
              };
            }
          ];
        };
        util_lan = inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = systemModules ++ [
            ./hosts/util_lan/configuration.nix
            inputs.sops-nix.nixosModules.sops
            { systemFoundry.deployment_target.enable = true; }
          ];
        };
        util_dmz = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = systemModules ++ [
            ./hosts/util_dmz/configuration.nix
            inputs.sops-nix.nixosModules.sops
            { systemFoundry.deployment_target.enable = true; }
          ];
        };
        m1 = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = systemModules ++ [
            ./hosts/m1/configuration.nix
            inputs.sops-nix.nixosModules.sops
            { systemFoundry.deployment_target.enable = true; }
          ];
        };
        m2 = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = systemModules ++ [
            ./hosts/m2/configuration.nix
            inputs.sops-nix.nixosModules.sops
            { systemFoundry.deployment_target.enable = true; }
          ];
        };
        m3 = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = systemModules ++ [
            ./hosts/m3/configuration.nix
            inputs.sops-nix.nixosModules.sops
            { systemFoundry.deployment_target.enable = true; }
          ];
        };
        tiger = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = systemModules ++ [
            ./hosts/tiger/configuration.nix
            inputs.sops-nix.nixosModules.sops
            { systemFoundry.deployment_target.enable = true; }
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
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = hmModules;
              users."kyle.ondy" = {
                imports = [ ./profiles/ssh.nix ];

                # darwin overrides. This is ripe for refactoring. Declaring
                # this in the flake so it is very clear what is happening.
                services.lorri.enable = inputs.nixpkgs.lib.mkForce false;
                hmFoundry = inputs.nixpkgs.lib.mkForce {
                  terminal = {
                    email.enable = false;
                    gpg = {
                      enable = true;
                      service = false; # no service on darwin
                    };
                  };
                };
              };
            };
          }
        ];
      };
      alpha = self.nixosConfigurations.alpha.config.system.build.toplevel;
      C02CL8GXLVDL = self.darwinConfigurations.C02CL8GXLVDL.system;
      m1 = self.nixosConfigurations.m1.config.system.build.toplevel;
      m2 = self.nixosConfigurations.m2.config.system.build.toplevel;
      m3 = self.nixosConfigurations.m3.config.system.build.toplevel;
      util_dmz = self.nixosConfigurations.util_dmz.config.system.build.toplevel;
      util_lan = self.nixosConfigurations.util_lan.config.system.build.toplevel;
      tiger = self.nixosConfigurations.tiger.config.system.build.toplevel;
    };
}
