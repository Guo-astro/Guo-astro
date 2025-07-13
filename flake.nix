{
  description = "GitHub Profile Makeover Script";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Required dependencies for the GitHub profile makeover script
            gh          # GitHub CLI
            git         # Git version control
            jq          # JSON processor
            bash        # Bash shell
            coreutils   # Core utilities (base64, etc.)
            zsh         # Zsh shell
          ];

          shellHook = ''
            # Source your existing zsh configuration to get aliases and functions
            if [ -f "$HOME/.zshrc" ]; then
              source "$HOME/.zshrc"
            fi
            
            echo "🚀 GitHub Profile Makeover Development Environment"
            echo "📋 Available tools:"
            echo "  - gh (GitHub CLI): $(gh --version | head -1)"
            echo "  - git: $(git --version)"
            echo "  - jq: $(jq --version)"
            echo "  - zsh: $(zsh --version)"
            echo ""
            echo "💡 Usage:"
            echo "  ./github_profile_makeover.sh            # dry run"
            echo "  ./github_profile_makeover.sh --apply    # apply changes"
            echo ""
            echo "✅ Your ~/.zshrc aliases and functions are available!"
            
            # Check if GitHub CLI is authenticated
            if ! gh auth status &>/dev/null; then
              echo "⚠️  GitHub CLI not authenticated. Run 'gh auth login' first."
            else
              echo "✅ GitHub CLI is authenticated"
            fi
          '';
        };

        # Make the script executable and available as a package
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "github-profile-makeover";
          version = "1.0.0";
          src = pkgs.lib.cleanSource ./.;
          
          buildInputs = with pkgs; [ bash gh git jq ];
          
          installPhase = ''
            mkdir -p $out/bin
            cp github_profile_makeover.sh $out/bin/github-profile-makeover
            chmod +x $out/bin/github-profile-makeover
            
            # Wrap the script to ensure dependencies are in PATH
            wrapProgram $out/bin/github-profile-makeover \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.gh pkgs.git pkgs.jq pkgs.bash pkgs.coreutils ]}
          '';
          
          nativeBuildInputs = [ pkgs.makeWrapper ];
          
          meta = with pkgs.lib; {
            description = "One-stop GitHub CLI script to automate the stunning profile checklist";
            license = licenses.mit;
            platforms = platforms.unix;
          };
        };
      });
}
