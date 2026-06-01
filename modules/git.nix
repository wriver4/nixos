{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      git
      gitg
      gitui
      github-desktop
      gitlab
    ];

    # Git credential configuration with fallback for headless/CLI users
    programs.git = {
      enable = true;
      config = {
        credential = {
          # Primary: use git-credential-store as fallback for headless systems
          helper = "store";
          credentialStore = "secretservice";
        };
        # GitHub-specific: try gh first, fall back to store
        "credential \"https://github.com\"" = {
          helper = [
            ""  # Reset helpers
            "!${pkgs.gh}/bin/gh auth git-credential"
            "store"
          ];
        };
        "credential \"https://gist.github.com\"" = {
          helper = [
            ""
            "!${pkgs.gh}/bin/gh auth git-credential"
            "store"
          ];
        };
      };
    };
  };
}
