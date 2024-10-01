with (import <nixpkgs> {});
let
  libs = [
  
];
in 
mkShell {
      packages = [ gcc gnumake binutils mars-mips  ];
      buildInputs = libs;
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libs;
}
