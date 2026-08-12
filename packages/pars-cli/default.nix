{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "pars-cli";
  version = "0.2.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-sxdQJVKbhSKG7AwSl0P2LpS7Ncr41ZYndAHuOmC87So=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  meta = {
    description = "zx2c4-pass compatible password manager";
    homepage = "https://github.com/vollate/pass-store-rs";
    license = lib.licenses.gpl3Plus;
    mainProgram = "pars";
  };
}
