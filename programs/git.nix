{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

{
  config = {
    programs.git = {
      enable = true;
      extraConfig = {
        user.name = "laxsjo";
        user.email = "rasmus.soderhielm@gmail.com";

        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingKey = "~/.ssh/id_ed25519";

        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        submodule.recurse = true;
        submodule.fetchJobs = 8;
        advice.detachedHead = false;

        # usage `git adog`: pretty commit graph
        # from this amazing post: https://stackoverflow.com/a/35075021/15507414
        # I've customized the formatting of oneline to place the commit
        # decorations after the summary.
        alias.adog = "log --all --decorate --format=\"%C(auto)%h %s%d\" --graph";
        alias.dog = "log --decorate --format=\"%C(auto)%h %s%d\" --graph";

        alias.show-names = "show --oneline --name-status";
        alias.log-line = "log --oneline";
        alias.switchd = "switch --detach";
      };

      ignores = [
        # Created by the "VS Code Counter" extension
        ".VSCodeCounter/"
      ];
    };
  };
}
