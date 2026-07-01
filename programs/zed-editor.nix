{
  lib,
  pkgs,
  config,
  inputs,
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
      package = inputs.zed.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default;

      userSettings = {
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
      };

      userKeymaps = [
        {
          context = "Workspace";
          bindings = {
            "ctrl-shift-t" = "terminal_panel::ToggleFocus";
            "ctrl-shift-g" = null;
            "ctrl-shift-g g" = "git_panel::ToggleFocus";
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
          };
        }
        {
          context = "Pane > GitPanel > Editor";
          bindings = {
            "ctrl-alt-enter" = "git::Commit";
          };
        }
        {
          context = "Pane > GitDiff > Editor";
          bindings = {
            "ctrl-shift-g a" = "git::StageAndNext";
            "ctrl-shift-g u" = "git::UnstageAndNext";
          };
        }
      ];
    };

    programs.zed-editor.extensions = [
      "catppuccin"
      "catppuccin-icons"
      "git-firefly"
      "nix"
      "rust"
      "toml"
      "zig"
    ];
    home.packages = [
      # Includes C/C++ language server
      pkgs.clang-tools
      # Nix language server
      pkgs.nixd
      # Includes the rust langauge server
      pkgs.rustup
      # Zig language server
      pkgs.zls
    ];

    # Configure Zed as the default editor
    module.shell.sessionVariables = {
      "EDITOR" = "zed --wait --classic";
    };
  };
}
