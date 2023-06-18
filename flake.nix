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

    bin = pkgs: pkgs.buildGoModule {
      name = "xpropdate";
      src = ./.;
      vendorSha256 = null;
    };

    xpropdate = pkgs: pkgs.writeShellApplication {
      name = "xpropdate";
      runtimeInputs = with pkgs; [ xorg.xprop ];
      text = ''
        exec ${bin pkgs}/bin/xpropdate
      '';
    };

    overlay = final: prev: {
      xpropdate = xpropdate prev;
    };

  in utils.lib.eachSystem targetSystems (system:
  let
    pkgs = import nixpkgs { inherit system; };

  in rec {
    packages = {
      xpropdate = (bin pkgs);
      default = (xpropdate pkgs);
    };

    apps = {
      xpropdate = {type = "app"; program = "${packages.xpropdate}/bin/xpropdate";};
      default = {type = "app"; program = "${packages.xpropdate}/bin/xpropdate";};
    };
  }) // rec {
    overlays.default = overlay;
    nixosModules.default = {
      nixpkgs.overlays = [ overlays.default ];
    };
  };
}
