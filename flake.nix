{
  description = "xpropdate: sets the current root window's name to the current time.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils}:
  let
    lib = nixpkgs.lib;
    targetSystems = with utils.lib.system; [ x86_64-linux aarch64-linux ];

  in utils.lib.eachSystem targetSystems (system:
  let
    pkgs = import nixpkgs { inherit system; };

    xpropdate = pkgs.buildGoModule {
      name = "xpropdate";
      src = ./.;
      vendorSha256 = null;
    };

  in {
    packages = {
      inherit xpropdate;
      default = xpropdate;
    };

    apps = rec {
      xpropdate = {type = "app"; program = "${xpropdate}/bin/xpropdate";};
      default = xpropdate;
    };
  });
}
