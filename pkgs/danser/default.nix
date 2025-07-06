{buildGoModule, autoPatchelfHook, glfw, gtk2, gtk3, pkg-config, xorg, ...}: 
buildGoModule (finalAttrs: {
  pname = "danser";
  version = "0.11.0";

  src = fetchTarball {
    url = "https://github.com/Wieku/danser-go/archive/refs/tags/${finalAttrs.version}.tar.gz";
    sha256 = "sha256:06lkjp4vjss7m55iwa8wq026d0kh9bmqpsyjg25y0rg5mrs0gnbs";
  };

  vendorHash = "sha256-+Is1eSpHcn+R+8E/Bdecv0UuFE26fopKFGXWBgsCjso=";

  patches = [
    ./update-go-module.patch
  ];

  buildInputs = [
    glfw
    gtk2
    gtk3
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXxf86vm
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    pkg-config
  ];
})
