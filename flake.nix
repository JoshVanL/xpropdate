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

    xpropdateSH = pkgs.writeShellApplication {
      name = "xpropdate";
      runtimeInputs = with pkgs; [ xorg.xprop ];
      text = ''
        exec ${xpropdate}/bin/xpropdate
      '';
    };

  in {
    packages = {
      inherit xpropdate;
      default = xpropdateSH;
    };

    overlays = _: _: { inherit xpropdate; };

    apps = rec {
      xpropdate = {type = "app"; program = "${xpropdate}/bin/xpropdate";};
      default = {type = "app"; program = "${xpropdateSH}/bin/xpropdate";};
    };
  });
}
