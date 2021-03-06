{ stdenv, lib, fetchurl
, pkgconfig, autoconf, automake, texinfo
, ncurses, libXpm, jansson, gmp, gettext
, cairo, libtiff, harfbuzz, libpng, libjpeg, librsvg, libungif
, gtk3-x11, gnutls, libxml2
}:

stdenv.mkDerivation rec {
  pname = "emacs27";
  version = "27.1";
  src = fetchurl {
    url = "https://mirror.squ.edu.om/gnu/emacs/emacs-${version}.tar.gz";
    sha256 = "1nw4lpid1kqncypa9f1228d43m59qn3gqgmy3vrjrfair4fsdgzz";
  };

  buildInputs = [
    ncurses libXpm jansson gmp gettext
    cairo libtiff harfbuzz libpng libjpeg librsvg libungif
    gtk3-x11 gnutls libxml2
  ];
  nativeBuildInputs = [
    pkgconfig
    autoconf
    automake
    texinfo
  ];

  hardeningDisable = [ "format" ];

  preConfigure = ''
    ./autogen.sh
    substituteInPlace lisp/international/mule-cmds.el \
      --replace /usr/share/locale ${gettext}/share/locale
    for makefile_in in $(find . -name Makefile.in -print); do
        substituteInPlace $makefile_in --replace /bin/pwd pwd
    done
  '';

  configureFlags = [
    "--with-x"
    "--with-x-toolkit=gtk3"
    "--with-gnutls"
    "--with-json"
    "--with-cairo"
    "--with-modules"
    "--with-harfbuzz"
    "--without-sound"
    "--without-dbus"
    "--without-gsettings"
    "--without-libsystemd"
  ];

  installTargets = [ "tags" "install" ];

  postInstall = let
    sitestart = "${builtins.fetchurl
      "https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/applications/editors/emacs/site-start.el"}";
  in ''
    mkdir -p $out/share/emacs/site-lisp
    cp ${sitestart} $out/share/emacs/site-lisp/site-start.el
    $out/bin/emacs --batch -f batch-byte-compile $out/share/emacs/site-lisp/site-start.el
    rm -fr $out/{var,share/emacs/${version}/site-lisp}
  '';

  meta = with lib; {
    description = "GNU Emacs";
    homepage = "https://www.gnu.org/software/emacs";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
