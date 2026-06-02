# Nix

This project uses Nix flakes and direnv for development. You should be running inside a dev shell already. If something appears missing then prompt the user to restart you.

## Dev shell lifecycle

When `flake.nix` is modified and needs a dev shell reload, wait for the user to confirm they have restarted the shell before running any build or test commands. Do not wrap commands in `nix develop --command`. The user manages their own dev shell lifecycle.
