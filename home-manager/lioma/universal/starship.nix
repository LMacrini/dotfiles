{
  directory = {
    fish_style_pwd_dir_length = 1;
  };
  direnv = {
    allowed_msg = "";
    denied_msg = "/denied";
    disabled = false;
    format = ''[$symbol$loaded$allowed]($style) '';
    not_allowed_msg = "/not allowed";
    symbol = "󰁨 ";
  };
  shlvl = {
    disabled = true;
    format = ''[\[$shlvl\]]($style) '';
  };
  sudo = {
    disabled = false;
    symbol = "󰆥 ";
  };
  time = {
    disabled = false;
  };

  format = builtins.concatStringsSep "" [
    "$username"
    "$hostname"
    "$localip"
    "$singularity"
    "$kubernetes"
    "$directory"
    "$vcsh"
    "$fossil_branch"
    "$fossil_metrics"
    "$git_branch"
    "$git_commit"
    "$git_state"
    "$git_metrics"
    "$git_status"
    "$hg_branch"
    "$pijul_channel"
    "$docker_context"
    "$package"
    "$c"
    "$cmake"
    "$cobol"
    "$daml"
    "$dart"
    "$deno"
    "$dotnet"
    "$elixir"
    "$elm"
    "$erlang"
    "$fennel"
    "$gleam"
    "$golang"
    "$guix_shell"
    "$haskell"
    "$haxe"
    "$helm"
    "$java"
    "$julia"
    "$kotlin"
    "$gradle"
    "$lua"
    "$nim"
    "$nodejs"
    "$ocaml"
    "$opa"
    "$perl"
    "$php"
    "$pulumi"
    "$purescript"
    "$python"
    "$quarto"
    "$raku"
    "$rlang"
    "$red"
    "$ruby"
    "$rust"
    "$scala"
    "$solidity"
    "$swift"
    "$terraform"
    "$typst"
    "$vlang"
    "$vagrant"
    "$zig"
    "$buf"
    "$nix_shell"
    "$conda"
    "$meson"
    "$spack"
    "$memory_usage"
    "$aws"
    "$gcloud"
    "$openstack"
    "$azure"
    "$nats"
    "$direnv"
    "$env_var"
    "$mise"
    "$crystal"
    "$custom"
    "$sudo"
    "$cmd_duration"
    "$line_break"
    "$jobs"
    "$battery"
    # "$time"
    "$status"
    "$os"
    "$container"
    "$netns"
    "$shell"
    "$shlvl"
    "$character"
  ];

  aws.symbol = "  ";
  buf.symbol = " ";
  c.symbol = " ";
  conda.symbol = " ";
  crystal.symbol = " ";
  dart.symbol = " ";
  directory.read_only = " 󰌾";
  docker_context.symbol = " ";
  elixir.symbol = " ";
  elm.symbol = " ";
  fennel.symbol = " ";
  fossil_branch.symbol = " ";
  git_branch.symbol = " ";
  git_commit.tag_symbol = "  ";
  golang.symbol = " ";
  guix_shell.symbol = " ";
  haskell.symbol = " ";
  haxe.symbol = " ";
  hg_branch.symbol = " ";
  hostname.ssh_symbol = " ";
  java.symbol = " ";
  julia.symbol = " ";
  kotlin.symbol = " ";
  lua.symbol = " ";
  memory_usage.symbol = "󰍛 ";
  meson.symbol = "󰔷 ";
  nim.symbol = "󰆥 ";
  nix_shell.symbol = " ";
  nodejs.symbol = " ";
  ocaml.symbol = " ";
  package.symbol = "󰏗 ";
  perl.symbol = " ";
  php.symbol = " ";
  pijul_channel.symbol = " ";
  python.symbol = " ";
  rlang.symbol = "󰟔 ";
  ruby.symbol = " ";
  rust.symbol = "󱘗 ";
  scala.symbol = " ";
  swift.symbol = " ";
  zig.symbol = " ";
  gradle.symbol = " ";

  # idk if there's a point to having all of these, maybe distrobox?
  os.symbols = {
    Alpaquita = " ";
    Alpine = " ";
    AlmaLinux = " ";
    Amazon = " ";
    Android = " ";
    Arch = " ";
    Artix = " ";
    CentOS = " ";
    Debian = " ";
    DragonFly = " ";
    Emscripten = " ";
    EndeavourOS = " ";
    Fedora = " ";
    FreeBSD = " ";
    Garuda = "󰛓 ";
    Gentoo = " ";
    HardenedBSD = "󰞌 ";
    Illumos = "󰈸 ";
    Kali = " ";
    Linux = " ";
    Mabox = " ";
    Macos = " ";
    Manjaro = " ";
    Mariner = " ";
    MidnightBSD = " ";
    Mint = " ";
    NetBSD = " ";
    NixOS = " ";
    OpenBSD = "󰈺 ";
    openSUSE = " ";
    OracleLinux = "󰌷 ";
    Pop = " ";
    Raspbian = " ";
    Redhat = " ";
    RedHatEnterprise = " ";
    RockyLinux = " ";
    Redox = "󰀘 ";
    Solus = "󰠳 ";
    SUSE = " ";
    Ubuntu = " ";
    Unknown = " ";
    Void = " ";
    Windows = "󰍲 ";
  };
}
