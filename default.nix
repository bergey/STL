{ stdenv, lib, haskellBuildTools, pkgs, callPackage, frozenCabbages ? {} }:
let cabalTmp = "cabal --config-file=./.cabal/config";
    myCabbages = lib.fix (frozenCabbages: {
      cereal = callPackage .cabbages/cereal-0.5.1.0 {
        inherit frozenCabbages haskellBuildTools pkgs;
      };
      primitive = callPackage .cabbages/primitive-0.6.1.0 {
        inherit frozenCabbages haskellBuildTools pkgs;
      };
      text = callPackage .cabbages/text-1.2.2.1 {
        inherit frozenCabbages haskellBuildTools pkgs;
      };
      hashable = callPackage .cabbages/hashable-1.2.4.0 {
        inherit frozenCabbages haskellBuildTools pkgs;
      };
      vector = callPackage .cabbages/vector-0.11.0.0 {
        inherit frozenCabbages haskellBuildTools pkgs;
      };
      scientific = callPackage .cabbages/scientific-0.3.4.6 {
        inherit frozenCabbages haskellBuildTools pkgs;
      };
      attoparsec = callPackage .cabbages/attoparsec-0.13.0.1 {
        inherit frozenCabbages haskellBuildTools pkgs;
      };
    });
    mkCmd = pkg: let nm = lib.strings.removePrefix "haskell-" pkg.name;
                     p = pkg.outPath;
                     pkgPath = ".cabal-sandbox/x86_64-linux-ghc-7.10.3-packages.conf.d";
                 in ''ln -sFf ${p}/${pkgPath}/*.conf $out/${pkgPath}/
                    '';
    mkSetupCmd = pkg: let nm = lib.strings.removePrefix "haskell-" pkg.name;
                          p = pkg.outPath;
                      in "ln -sFf ${pkg.outPath}/.cabal-sandbox/x86_64-linux-ghc-7.10.3-packages.conf.d/*.conf /home/bergey/code/active/STL/.cabal-sandbox/x86_64-linux-ghc-7.10.3-packages.conf.d/\n";
in
stdenv.mkDerivation rec {
  name = "haskell-STL-0.3.0.4";
  src = ./dist/STL-0.3.0.4.tar.gz;
  cabbageDeps = with myCabbages; [ 
cereal primitive text hashable vector scientific attoparsec ];
  systemDeps = (with pkgs;  [  ]) ++
               lib.lists.unique (lib.concatMap (lib.attrByPath ["systemDeps"] []) cabbageDeps);
  propagatedBuildInputs = systemDeps;
  buildInputs = [ stdenv.cc ] ++ haskellBuildTools ++ cabbageDeps ++ systemDeps;

  # Build the commands to merge package databases
  cmds = lib.strings.concatStrings (map mkCmd cabbageDeps);
  setupCmds = lib.strings.concatStrings (map mkSetupCmd cabbageDeps);
  setup = builtins.toFile "setup.sh" ''
    
    # Takes a GHC platform string, an array of add-source dependency
    # directories, and a string of old timestamps. Produces a new
    # timestamp string.
    updateTimeStamps() {
      local -a DEPS=("''${!2}")
      local CUR_TIME=$(date +%s)
      local i
      local STAMPED
      for ((i = 0; i < "''${#DEPS[@]}"; ++i)); do
        STAMPED[$i]="(\"''${DEPS[$i]}\",$CUR_TIME)"
      done
      local LIST=$(printf ",%s" "''${STAMPED[@]}")
      LIST=''${LIST:1}
      local NEWSTAMP="(\"$1\",[$LIST])"
      if echo "$3" | grep -q "$1"; then
        echo "$3" | sed "s:(\"$1\",[^]]*\]):$NEWSTAMP:"
      elif echo "$3" | grep -q "]\\$"; then
        echo "$3" | sed "s:\]\$:,$NEWSTAMP]:"
      else
        echo "[$NEWSTAMP]"
      fi
    }
    eval "$setupCmds"
    ${cabalTmp} sandbox hc-pkg recache
    SRCS=($(cabal sandbox list-sources | sed '1,/^$/ d' | sed '/^$/,$ d'))
    OLDTIMESTAMPS=$(cat .cabal-sandbox/add-source-timestamps)
    updateTimeStamps "x86_64-linux-ghc-7.10.3" SRCS[@] "$OLDTIMESTAMPS" > .cabal-sandbox/add-source-timestamps
  '';

  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup
    mkdir $out

    if [ -d "$src" ]; then
      cp -R "$src"/* .
      #*/
      if [ -f $src/buildplan ]; then
        mkdir $out/.cabbageCache
        cp "$src/buildplan" "$out/.cabbageCache/buildplan"
      fi
    else
      tar xf "$src" --strip=1
    fi

    chmod -R u+w .
    if [ -d dist ]; then
      # Copy pre-generated dist files to store
      cp -R dist $out
    fi
    ${cabalTmp} sandbox --sandbox=$out/.cabal-sandbox init -v0
    mkdir -p $out/.cabal-sandbox/lib/x86_64-linux-ghc-7.10.3
    eval "$cmds"
    ${cabalTmp} sandbox hc-pkg recache

    ${cabalTmp} --builddir=$out/dist --bindir=$out/bin --libexecdir=$out/libexec --libdir=$out/.cabal-sandbox/lib --with-gcc=$CC configure -p $(echo $NIX_LDFLAGS | awk -e '{ for(i=1;i <= NF; i++) { if(match($(i), /^-L/)) printf("--extra-lib-dirs=%s ", substr($(i),3)); } }')
    echo "Building..."

    # Ensure framework dependencies are used by GHC as they are needed
    # when GHC invokes a C compiler.
    COPTS=$(echo "$NIX_CFLAGS_COMPILE" | awk -e '{ for(i=1; i<=NF; i++) { if (match($(i), /^-F/)) printf("-optc %s ", $(i)); }}')
    ${cabalTmp} --builddir=$out/dist build -v0 --ghc-options="$COPTS"
    ${cabalTmp} --builddir=$out/dist haddock -v0 || true
    ${cabalTmp} --builddir=$out/dist copy
    ${cabalTmp} --builddir=$out/dist register
    ${cabalTmp} --builddir=$out/dist clean || true
  '';    
  meta = {
    description = "STL 3D geometry format parsing and pretty-printing ";
  };
}
