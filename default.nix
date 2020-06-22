let
  sources = import ./nix/sources.nix;
  nix-pre-commit-hooks = import sources."pre-commit-hooks.nix";
in
{
  pre-commit-check = nix-pre-commit-hooks.run {
    src = ./.;
    hooks = {
      nix-linter.enable = true;
      nixpkgs-fmt.enable = true;
      shellcheck.enable = true;
    };
  };
}
