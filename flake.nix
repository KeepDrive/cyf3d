{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      pathToPlugin = pkgs.fetchFromGitHub {
        owner = "KeepDrive";
        repo = "luaPreProcess_ls";
        rev = "46eaa948025342727d3e36fd2b5e908476a4dd5f";
        sha256 = "oGpwNrhEn/Brd5p1JQSKyE6Dsue4++zfY0yog7irb7A=";
        fetchSubmodules = true;
      };
    in {
      devShell = with pkgs; mkShellNoCC {
        shellHook = "export DEV_SHELL_LSPS='lua_ls = { settings = { Lua = { semantic = { enable = false }, runtime = { plugin = \"${pathToPlugin + "/plugin.lua"}\"}}}}'";
        packages = [
          (lua-language-server.overrideAttrs {
            src = (fetchFromGitHub {
              owner = "KeepDrive";
              repo = "lua-language-server";
              rev = "4329df384acc7479711dfdd0797abea2d2857791";
              sha256 = "ufx5lB6sGbEmBI8o/DanwNBPxp/uB6u1NsOXnQHjWZY=";
              fetchSubmodules = true;
            });
          })
          vimPlugins.nvim-treesitter-parsers.lua 
        ];
      };
    }
  );
}
