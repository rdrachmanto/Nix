{
  lib,
  stdenv,
  fetchurl,
  janet,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "janet-lsp";
  version = "0.0.11";

  # This points directly at the .jimage file in the GitHub release
  src = fetchurl {
    url = "https://github.com/CFiggers/janet-lsp/releases/download/v${version}/janet-lsp.jimage";
    sha256 = "15vn4l20i43qkryqkyslhixn0p5qlxd235dxyznamx8g2dcdx5ai"; # nix-prefetch-url this once
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ janet ];

  # We’re not unpacking a tarball; it's just one file.
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/lib/janet-lsp $out/bin

    # Store the image somewhere “nice”
    cp $src $out/lib/janet-lsp/janet-lsp.jimage

    # Make a `janet-lsp` binary that just calls janet on that image
    makeWrapper ${janet}/bin/janet $out/bin/janet-lsp \
      --add-flags "-i" \
      --add-flags "$out/lib/janet-lsp/janet-lsp.jimage"
  '';

  meta = {
    description = "Language Server (LSP) for the Janet programming language";
    homepage = "https://github.com/CFiggers/janet-lsp";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
