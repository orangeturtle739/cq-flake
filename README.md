# CadQuery and cq-studio flake

## What is this

Concepts:

1. [nix package manager](https://nixos.org/guides/nix-pills/why-you-should-give-it-a-try.html) and [the NixOS Linux distribution](https://nixos.org/)
2. [nix flakes](https://www.tweag.io/blog/2020-05-25-flakes/)
3. [CadQuery and CQ-editor](https://cadquery.readthedocs.io/en/latest/intro.html)
4. [Cachix](https://docs.cachix.org/)

This repo is a nix flake forked from [https://github.com/vinszent/cq-flake] with the goal of making `cq-studio` work.

## Commands

To run `cq-studio`:

```sh
nix run github:orangeturtle739/cq-flake
```

To create an environment with CadQuery and python-language-server (where hopefully your IDE will pick up python-language-server and supply autocomplete, docs, etc.):
```sh
nix shell github:orangeturtle739/cq-flake#cadquery-env
```

To get the most out of this flake you should specify a commit along with those commands and note it down so you are always using the same CadQuery, eg.
```sh
nix run github:orangeturtle739/cq-flake/14d05cee591dccf5d64fa0e502e6e381a531c718
```

You can also generate the docs with:
```
nix build github:orangeturtle739/cq-flake#cq-docs
```
which will leave a symlink called `result` pointing to the HTML docs.

## Local dev

Should you wish to do dev work with CadQuery check out the `dev` branch of this repo. `flake.nix` shows how to reference a local copy (must be a Git repo) of CadQuery instead of a GitHub copy. Then use a command like:

```sh
nix flake update --update-input cadquery . && nix build -L .#cadquery-docs && qutebrowser ./result-doc/share/doc/index.html
```

~~I've also added some debug stuff for debugging with `gdb`. Debugging symbols for Python have come and gone from nixpkgs, if the debugging attributes don't have all the symbols you need look into setting overriding `separateDebugInfo = true;` in the Python expression. The most likely method you need for debugging is to run `nix develop github:orangeturtle739/cq-flake#cadquery-env-debug`, start python, switch to a second terminal, `gdb python <PID>`, `continue`, switch back to python, make it crash, switch back to gdb, `bt`. gdb can't run scripts so it's difficult to start Python (which under nix is usually a script wrapper around the actual Python binary) from within gdb, easier just to attach it to a running instance.~~
Debugging currently removed from nixpkgs.
