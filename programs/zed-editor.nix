{
  lib,
  pkgs,
  config,
  inputs,
  system,
  ...
}:

# This is pretty empty right now, but I anticepate needing more
# configurations soon :)

let
  name = "zed-editor";
in
{
  config = {
    programs.zed-editor = {
      enable = true;
      # Building this took roughly 26 mins on my machine...
      package = inputs.zed.outputs.packages.${system}.default;

      userSettings = {
        # I only switch panes using ctrl-tab, therefore disable the tab bar. :)
        tab_bar.show = false;
        project_panel = {
          dock = "left";
        };
        outline_panel = {
          dock = "left";
        };
        collaboration_panel = {
          dock = "left";
        };
        agent = {
          dock = "right";
          favorite_models = [ ];
          model_parameters = [ ];
        };
        git_panel = {
          dock = "left";
        };
        vim_mode = false;
        ui_font_size = 16;
        buffer_font_family = "FiraCode Nerd Font";
        buffer_font_size = 16;
        theme = {
          mode = "system";
          light = "One Light";
          dark = "Catppuccin Frappé";
        };
        terminal = {
          font_family = "FiraCode Nerd Font";
          font_size = 14;
          line_height = "standard";
        };
        wrap_guides = [ 80 ];
        vertical_scroll_margin = 10;

        languages = {
          "LispBM" = {
            colorize_brackets = true;
          };
          "Git Commit" = {
            wrap_guides = [
              50
              72
            ];
          };
        };
      };

      userKeymaps = [
        {
          bindings = {
            "ctrl-<" = "zed::OpenSettingsFile";
          };
          unbind = {
            # Unbind these from the default keybindings as they conflict with
            # other mappings, and I don't care about them.
            "ctrl-n" = "menu::SelectNext";
            "ctrl-p" = "menu::SelectPrevious";
            "ctrl-alt-," = "zed::OpenSettingsFile";

            "ctrl-q" = "zed::Quit";
          };
        }
        {
          context = "Workspace";
          bindings = {
            "ctrl-shift-t" = "terminal_panel::ToggleFocus";
            "ctrl-shift-g" = null;
            "ctrl-shift-g g" = "git_panel::ToggleFocus";
            "ctrl-shift-s" = "workspace::SaveWithoutFormat";
          };
          unbind = {
            "ctrl-shift-s" = "workspace::SaveAs";
          };
        }
        {
          context = "Pane";
          bindings = {
            "ctrl-alt-." = "pane::GoBack";
            "ctrl-alt-," = "pane::GoForward";
          };
        }
        {
          context = "Pane > Editor";
          bindings = {
            "ctrl-k ctrl-c" = "editor::ToggleComments";
            "ctrl-alt-up" = "editor::AddSelectionAbove";
            "ctrl-alt-down" = "editor::AddSelectionBelow";
            "ctrl-enter" = "editor::NewlineBelow";
            "ctrl-shift-enter" = "editor::NewlineAbove";
            "ctrl-d" = "editor::DuplicateLineDown";
            "ctrl-shift-d" = "editor::DuplicateLineUp";
            "alt-n" = [
              "editor::SelectNext"
              { replace_newest = false; }
            ];
            "alt-shift-n" = [
              "editor::SelectPrevious"
              { replace_newest = false; }
            ];
            "ctrl-shift-a" = "editor::SelectLargerSyntaxNode";
            "alt-h" = "editor::Hover";
            "ctrl-shift-g a" = "git::StageAndNext";
            "ctrl-shift-g u" = "git::UnstageAndNext";
            "ctrl-shift-g r" = "git::Restore";
          };
        }
        {
          context = "Pane > GitPanel > Editor";
          bindings = {
            "ctrl-alt-enter" = "git::Commit";
          };
        }
      ];
    };

    programs.zed-editor.extensions = [
      "catppuccin"
      "catppuccin-icons"
      "git-firefly"
      "just"
      "nix"
      "rust"
      "toml"
      "typst"
      "zig"
    ];
    home.packages = [
      pkgs.bash-language-server
      # Includes C/C++ language server
      pkgs.clang-tools
      # Go language server
      pkgs.gopls
      # Just language server
      pkgs.just-lsp
      # LispBM language server
      # Note that the Zed LispBM extension is currently installed manually from
      # the repo.
      inputs.lispbm-lsp.packages.${system}.default
      # Language server for package.json I think?
      pkgs.package-version-server
      # Nix language server
      pkgs.nixd
      # Python linter, formatter, and language server
      pkgs.ruff
      # Includes the rust langauge server
      pkgs.rustup
      # Tailwind CSS language server
      pkgs.tailwindcss-language-server
      # Typst language server
      pkgs.tinymist
      pkgs.typescript-language-server
      # CSS language server
      pkgs.vscode-css-languageserver
      pkgs.yaml-language-server
      # Zig language server
      pkgs.zls
    ];

    # Configure Zed as the default editor
    module.shell.sessionVariables = {
      "EDITOR" = "zed --wait --classic";
    };
  };
}
