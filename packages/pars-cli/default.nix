{
  lib,
  fetchCrate,
  gitMinimal,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "pars-cli";
  version = "0.3.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-K7Wzk32CSQHsKihbXn7trsxse+nMDriH2RKz8ll1+A0=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";
  nativeCheckInputs = [ gitMinimal ];

  meta = {
    description = "zx2c4-pass compatible password manager";
    homepage = "https://github.com/vollate/pass-store-rs";
    license = lib.licenses.gpl3Plus;
    mainProgram = "pars";
  };
}
