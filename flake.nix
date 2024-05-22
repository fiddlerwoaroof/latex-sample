{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      texpkgs = pkgs.texlive.combine {
        inherit
          (pkgs.texlive)
          scheme-basic
          alegreya
          etoolbox
          fontspec
          geometry
          hyperref
          intcalc
          latexmk
          lipsum
          luahbtex
          lualibs
          luatex
          luatexbase
          memoir
          microtype
          polyglossia
          sourcecodepro
          textcase
          ;
      };

      writeZsh = pkgs.writers.makeScriptWriter {interpreter = "${pkgs.zsh}/bin/zsh";};
      # tt = it: builtins.trace it it;
      ## For custom fonts, do something like this:
      #fonts = pkgs.stdenv.mkDerivation {
      #  name = "font-data";
      #  version = "0.0.0";
      #  buildInputs = [
      #    texpkgs
      #  ];
      #  src = ./fc_config;
      #  buildPhase = ''
      #    export TEXMFHOME="$out"
      #    export TEXMFVAR="$TEXMFHOME/texmf-var/"
      #    export FONTCONFIG_PATH="${./fc_config}"
      #    mkdir -p "$out"
      #    export OSFONTDIR="${./fc_config/fonts}"
      #    echo FONTCONFIG_PATH is $FONTCONFIG_PATH
      #    cp -R ./ "$out"
      #    luaotfload-tool -u -f
      #  '';
      #};
    in {
      packages = {
        # inherit fonts;

        default = pkgs.stdenv.mkDerivation {
          name = "sample-pdf";
          version = "0.0.0";
          buildInputs = [
            texpkgs
            #fonts
          ];
          src = ./src;
          buildPhase = ''
            export TEXMFHOME="$(mktemp -d)"
            export TEXMFVAR="$TEXMFHOME/texmf-var/"
            mkdir -p "$TEXMFVAR"
            #export FONTCONFIG_PATH="$'{fonts}"
            #export OSFONTDIR="$'{fonts}/fonts"
            #cp -R $'{fonts}/texmf-var/ "$TEXMFVAR"
            chmod -R +w "$TEXMFVAR"
            #echo FONTCONFIG_PATH is $FONTCONFIG_PATH
            #luaotfload-tool  --find='Dove Text' --fuzzy
            latexmk -lualatex sample.tex;
          '';
          installPhase = ''
            mkdir "$out"
            cp sample.pdf "$out"
          '';
        };
      };
      devShells.default = pkgs.mkShell {
        buildInputs = [
          texpkgs
          pkgs.pandoc
          pkgs.poppler_utils
          pkgs.ghostscript
          pkgs.imagemagick
        ];
      };
      apps.latexmk = {
        type = "app";
        buildInputs = [texpkgs];
        program = toString (writeZsh "latexmk-wrap" ''
          export TEXMFHOME="$(mktemp -d)"
          export TEXMFVAR="$TEXMFHOME/texmf-var/"
          #export FONTCONFIG_PATH="$'{fonts}"
          #export OSFONTDIR="$'{fonts}/fonts"
          #cp -R $'{fonts}/texmf-var/ "$TEXMFVAR"
          chmod -R +w "$TEXMFVAR"
          #echo FONTCONFIG_PATH is $FONTCONFIG_PATH
          echo $PATH
          #$'{texpkgs}/bin/luaotfload-tool  --find='Equity A'
          mkdir -p $out
          mkdir -p "$TEXMFVAR"
          ${texpkgs}/bin/latexmk -lualatex "$@";
        '');
      };
    });
}
