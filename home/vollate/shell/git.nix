{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.git = {
    enable = true;

    # NEW STRUCTURE: Everything goes inside 'settings'
    settings = {
      # User details now go here
      user = {
        name = "Vollate";
        email = "uint44t@gmail.com";
        signingkey = "A5B9B2C58C04DCB6A157566A9CDFDE550783E7BB";
      };

      commit.gpgSign = true;

      # Aliases now go here (note: it is singular 'alias', not 'aliases')
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        df = "diff";
        dc = "diff --cached";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
      };

      # Previous 'extraConfig' items now sit directly here
      init.defaultBranch = "main";
      push.default = "current";
      pull.rebase = true;
      core.editor = "nvim";
      merge.tool = "nvim -d";
      diff.algorithm = "patience";
      include.path = "~/.gitconfig.local";
    };
  };

  # GitHub CLI (remains unchanged)
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
