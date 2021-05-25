{ lib, pkgs, config, ... }:
with lib;
let cfg = config.foundry.dev.clojure;
in
{
  options.foundry.dev.clojure = {
    enable = mkEnableOption "clojure stuff";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # https://github.com/babashka/babashka
      babashka

      # https://github.com/clj-kondo/clj-kondo
      clj-kondo # linter

      # https://clojure.org/
      clojure # core language

      # https://github.com/candid82/joker
      joker #  small Clojure interpreter, linter and formatter

      # https://github.com/technomancy/leiningen
      leiningen # build tooling

      # https://github.com/clojure-lsp/clojure-lsp
      clojure-lsp
    ];

    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          # https://github.com/Olical/conjure
          # "conversational software development"
          plugin = conjure;
        }

        # todo: does LSP + TreeSitter made is not needed?
        #{
        #  # Extend builtin syntax highlighting
        #  plugin= vim-clojure-highlight;
        #}

        # todo: do I need this? Why?
        #{
        #  # https://github.com/radenling/vim-dispatch-neovim
        #  plugin = vim-dispatch-neovim;
        #}

        {
          # https://github.com/guns/vim-sexp
          # Precision Editing for S-expressions
          plugin = vim-sexp;
        }

        {
          # https://github.com/tpope/vim-sexp-mappings-for-regular-people
          # tpope to the rescue again
          plugin = vim-sexp-mappings-for-regular-people;
        }
      ];
    };
  };
}