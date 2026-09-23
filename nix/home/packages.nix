# CLI tools installed on every machine (macOS and Linux) from nixpkgs.
# Search for a package: `nix search nixpkgs <name>` or https://search.nixos.org
# Language runtimes (node, python, go, ...) are managed by mise: config/mise/config.toml
pkgs: with pkgs; [
  # Shell & prompt
  fish
  starship
  atuin
  zoxide
  fzf

  # Files & text
  bat
  lsd
  fd
  ripgrep
  tree
  yazi
  fx
  jq
  less
  tealdeer

  # Git
  git
  gh
  delta
  lazygit

  # Editors & dev tooling
  neovim
  mise
  rustup
  uv
  bun
  pnpm
  biome
  npm-check-updates
  omp

  # Cloud & infra
  awscli2
  ssm-session-manager-plugin
  coder
  supabase-cli
  tfenv

  # System & network
  btop
  procs
  ipcalc
  netwatch
  rustscan
  spotify-player
]
