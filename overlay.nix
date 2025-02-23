final: pkgs: {
  # Create a new derivation with a symlink to the given file at the the
  # specified path, effectively moving it into (potentially) a new directory.
  atPath = file: path: pkgs.runCommand path {} ''
    mkdir -p "$out/$(dirname ${path})"
    ln -s ${file} "$out/${path}"
  '';
}