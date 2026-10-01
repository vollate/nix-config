# Default overlays
# This file manages all overlays

inputs: [
  # Neovim with Node.js support
  (import ./neovim-with-nodejs.nix)

  # GCC 16 defaults to C++20, which warns about the demangle test's volatile
  # return types. DejaGNU treats compiler warnings as test compilation failures.
  # Keep this legacy test on C++17 without disabling ltrace's test suite.
  (final: prev: {
    ltrace = prev.ltrace.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace testsuite/ltrace.minor/demangle.exp \
          --replace-fail '[list debug c++]' '[list debug c++ additional_flags=-std=c++17]' \
          --replace-fail '[list debug shlib=$lib_sl c++]' '[list debug shlib=$lib_sl c++ additional_flags=-std=c++17]'
      '';
    });
  })

  # More overlays can be added here
  # (import ./other-overlay.nix)
]
