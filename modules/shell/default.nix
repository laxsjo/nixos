{ lib, config, pkgs, inputs, ... }:

let
  name = "shell";
  cfg = config.module.${name};
in {
  options.module.${name} = with lib; {
    enable = lib.mkEnableOption "shell. You want to enable this. (Why did I even make this an option?)";
    # Custom option for setting environment variables because both home.sessionVariables
    # and programs.zsh.sessionVariables appear to be broken in zsh per 
    # https://github.com/nix-community/home-manager/issues/3681
    sessionVariables = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        "EDITOR" = "vim";
      };
    };
  };
  
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      oh-my-posh
      zsh-syntax-highlighting
      zsh-autocomplete
      bat
      eza
    ];
    
    module.${name}.sessionVariables = {
      "EDITOR" = "code --wait";
    };
    
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      
      shellAliases = {
        # Apparently this makes aliases resolve when using sudo...
        "sudo" = "sudo ";
        
        "ls" = "eza --icons always";
        "ll" = "eza -lh --icons always";
        "lt" = "eza -T -L 4 --icons always";
        "gitp" = "git --no-pager";
        "dd" = "\\dd status=progress";
      };
      
      initExtra = ''
        # Bind ctrl+backspace to delete word
        bindkey '^H' backward-kill-word
        
        git-is-descendant() {
          git merge-base --is-ancestor $1 $2
          if [[ $? = 0 ]]; then
            echo "true"
          elif [[ $? = 1 ]]; then
            echo "false"
          else
            return $?
          fi
        }
        
        # Make sure that `nix develop` always uses zsh with my prompt:
        # Override nix develop to add -c "zsh" to the end of the given arguments.
        alias nix="nix-override"
        nix-override() {
          if [[ $1 == "develop" ]]; then
            \nix develop ''${@:2} -c "zsh"
          else
            \nix $@
          fi
        }
        
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (key: value:
          ''export ${key}="${lib.escape ["\""] value}"''
        ) cfg.sessionVariables)}
      '';
      
      oh-my-zsh = {
        enable = true;
      };
    };
    programs.oh-my-posh = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile ./myCatppuccin.omp.toml);
    };
    
    # Konsole
    # IDK where I should place this...
    # From here: https://unix.stackexchange.com/a/545615
    home.file.".hacks/useShell.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        PSHELL=$(getent passwd $USER | cut -d: -f7)
        eval "$PSHELL"
      '';
    };
    home.file.".local/share/konsole/UserProfile.profile".text = ''
      [Appearance]
      Font=FiraCode Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
      
      [General]
      Command=~/.hacks/useShell.sh
      Name=UserProfile
      Parent=FALLBACK/
    '';
  };
}