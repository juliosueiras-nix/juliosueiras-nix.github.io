{ lib }:
{
  siteUrl = "https://juliosueiras-nix.github.io";

  social = {
    email = "juliosueiras@gmail.com";
  };
  theme = {
    social = {
      github = "https://github.com/juliosueiras";
      email = "juliosueiras@gmail.com";
      linked-in = "https://www.linkedin.com/in/julio-alejandro-tain-sueiras-5b88a862";
      twitter = "https://twitter.com/juliosueiras";
      gitlab = "https://gitlab.com/juliosueiras";
    };
    site = {
      title = "Nix Toolchain Blog";
      author = "Julio Tain Sueiras";
      description = "A Blog focus on Various Nix Toolchain Porting";
      copyright = ''
        &copy; 2020. All rights reserved. 
      '';
    };

    lib.highlightjs = {
      enable = true;
      style = "monokai";
      extraLanguages = [ "nix" ];
    };
  };
}
