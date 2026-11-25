# Nix

This project uses Nix flakes and direnv for development. You run inside a dev shell. If a tool is missing, ask the user to restart you.

## Dev shell lifecycle

When `flake.nix` changes and the dev shell needs a reload, wait. Run no build or test command until the user confirms that the shell restarted. Do not wrap commands in `nix develop --command`. The user manages the dev shell lifecycle.
