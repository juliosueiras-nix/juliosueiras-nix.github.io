{---
title = "Nix PSP Toolchain Part 1: Main Toolchain";
---}

__NOTE: This is a 5 part series blog focusing on the steps to port the PSP toolchain to Nix__

Table of Contents
=================

   * [Why port the PSP toolchain to Nix?](#why-port-the-psp-toolchain-to-nix)
   * [The Code](#the-code)
   * [Part 1.1 Nix Flakes](#part-11-nix-flakes)
      * [Setting up the flake structure](#setting-up-the-flake-structure)
   * [Part 1.2 Investigating &amp; Understating the PSP Toolchain](#part-12-investigating--understating-the-psp-toolchain)
   * [Part 1.3 Starting the Port Process](#part-13-starting-the-port-process)
      * [Binutils](#binutils)
      * [Stage 1](#stage-1)
         * [GCC](#gcc)

# Why port the PSP toolchain to Nix?

Because why not, but in serious, I decided to port the toolchain as a challenge for myself, and also due to the desire to build homebrew and plugins in a reproducible format(no more docker or github releases)

# The Code

The ported toolchain is located at [here](https://github.com/juliosueiras-nix/nix-psp)

# Part 1.1 Nix Flakes

I decided right away to use [nix flakes](https://www.tweag.io/blog/2020-05-25-flakes/), since the toolchain need to use a pinned nixpkgs for better reproducibility (also to reduce cached size for my poor digitalocean space)

## Setting up the flake structure

Setting up flake is quite straight forward only needing 

```shell
$ nix flake init
```

The next step is just pinning the nixpkgs

```nix
{
  description = "PSP Toolchain";

  inputs.nixpkgs.url =
    "github:NixOS/nixpkgs/469f14ef0fade3ae4c07e4977638fdf3afc29e08";

  outputs = { self, nixpkgs }: {
  };
}
```

and thats it at least for the basic setup of flake, for now we can leave it like this until we start actually adding the toolchain packages

# Part 1.2 Investigating & Understating the PSP Toolchain

To port the toolchain, the current method need to be understood first

After two days of running the scripts and going through various repos, the conclusions of the existing toolchain are these:

  - the main toolchain process is located in [psptoolchain](https://github.com/pspdev/psptoolchain)

  - there are two branches for psptoolchain, where one(master) uses `newlib-1.20.0` and the other one(toolchain-only) uses `newlib-3.3.0`, this distinction become important later

  - the toolchain itself is a two stage gcc build process, where it follow the path of `binutils -> stage-1 gcc -> newlib -> stage-2 gcc`

  - the external libraries(SDL, etc) are located in [psplibraries](https://github.com/pspdev/psplibraries)

# Part 1.3 Starting the Port Process

## Binutils

Lets start with binutils

This is the original bash script

```bash
{{ lib.readFile "${psptoolchain-src}/scripts/001-binutils.sh" }}
```

This is the same script but converted to nix derivation

```nix
{{ lib.readFile "${nix-psp-src}/pkgs/toolchain/binutils/default.nix" }}
```

The two changes that is noticable right away is the `inherit src;`, and no patches are being done in the nix version. These two changes are due to pspdev having a new repo for [binutils](https://github.com/pspdev/binutils) which have the patch in the repo itself, and src is being import via `fetchTree` or hydra input, depending on the type of build is doing.

The `fetchTree` for above will look like this 

```nix
fetchTree {
  type = "tarball";
  url = "https://github.com/pspdev/binutils/archive/b8577007c5e0a463b0fa9229efed59165ce13508.tar.gz";
  narHash = "sha256-MM76SqNk0ltXu5Kc3g+yZ8T5LQvDUDtW3t4rTSFyfFA=";
};
```

The important part for the nix derivation above when doing toolchain porting is to introduce attributes like `dontStrip`, `dontDisableStatic`, `hardeningDisable`, stripping and hardening are normally useful in nix packages, however due to this being a new toolchain, having any hardening mean introducing new configura flags that might introduce issues

## Stage 1

For stage 1, we need gcc, newlib and pspsdk data(and only the data)

### GCC

The process is very similar to binutils as well

Bash version:

```bash
{{ lib.readFile "${psptoolchain-src}/scripts/002-gcc-stage1.sh" }}
```

Nix version:

```nix
{{ lib.readFile "${nix-psp-src}/pkgs/toolchain/gcc/stage1.nix" }}
```

However gcc need the corresponding libraries like gmp.

GCC Deps Libraries:

```nix
{{ lib.readFile "${nix-psp-src}/pkgs/toolchain/gcc/libs.nix" }}
```
