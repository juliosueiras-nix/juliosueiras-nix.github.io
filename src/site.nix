{ styx, nixpkgs ? import <nixpkgs> { }, extraConf ? { } }:

rec {
  styxLib = import styx.lib styx nixpkgs;
  styx-themes = import styx.themes { pkgs = nixpkgs; };

  themes = [ styx-themes.generic-templates styx-themes.ghostwriter ];

  themesData = styxLib.themes.load {
    inherit styxLib themes;
    extraEnv = { inherit data pages; 
    psptoolchain-src = fetchTree {
      type = "git";
      url = "https://github.com/pspdev/psptoolchain";
      rev = "dfd455c2ebb5e0468d275db4d2fe3565e91b0331";
    };
    nix-psp-src = fetchTree {
      type = "git";
      url = "https://github.com/juliosueiras-nix/nix-psp";
      rev = "c52544e7e602140826f339d810fbd9399bdbd0b9";
    }; };
    extraConf = [ ./conf.nix extraConf ];
  };

  inherit (themesData) conf lib files templates env;

  data = with lib; {
    posts = lib.sortBy "date" "dsc" (lib.loadDir { dir = ./data/posts; inherit env; });
    about = lib.loadFile { file = ./data/pages/about.md; inherit env; };

    menu = [ pages.about ];

    # Create an author data
    author = {
      name = "Julio Tain Sueiras";
    };
  };

  pages = with lib; rec {
    index = lib.mkSplit {
      title        = "Home";
      basePath     = "/index";
      itemsPerPage = conf.theme.itemsPerPage;
      template     = templates.index;
      data         = posts.list;
    };

    about = data.about // {
      path     = "/about.html";
      template = templates.page.full;
    };

    posts = lib.mkPageList {
      data       = data.posts;
      pathPrefix = "/posts/";
      template   = templates.post.full;
    };
  };


  pageList = lib.pagesToList { inherit pages; default = { layout = templates.layout; }; };
  site = lib.mkSite { inherit files pageList; };
}
