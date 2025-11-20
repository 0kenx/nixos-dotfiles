{
  description = "Optimized Python development environment with uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        inherit (pkgs) lib;

        # Python with commonly needed packages
        pythonEnv = pkgs.python312;

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Python runtime
            pythonEnv

            # uv - Fast Python package installer and resolver
            python312Packages.uv

            # Development tools
            python312Packages.pip
            python312Packages.setuptools
            python312Packages.wheel
            python312Packages.build
            python312Packages.twine

            # Testing
            python312Packages.pytest
            python312Packages.pytest-cov
            python312Packages.pytest-asyncio
            python312Packages.pytest-xdist
            python312Packages.hypothesis

            # Linting and formatting
            ruff  # Fast Python linter and formatter
            python312Packages.mypy
            python312Packages.black
            python312Packages.isort

            # Type stubs
            python312Packages.types-requests
            python312Packages.types-setuptools

            # Documentation
            python312Packages.sphinx
            python312Packages.sphinx-rtd-theme

            # Debugging
            python312Packages.ipdb
            python312Packages.ipython

            # Editor
            neovim

            # Task runner
            just

            # System dependencies commonly needed
            gcc
            gnumake
            pkg-config
            openssl
            libffi
            zlib
          ];

          shellHook = ''
            echo "🐍 Python Development Environment with uv"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Python: $(python --version)"
            echo "uv:     $(uv --version)"
            echo "ruff:   $(ruff --version)"
            echo ""
            echo "Available tools:"
            echo "  uv         - Fast Python package manager"
            echo "  python     - Python interpreter"
            echo "  pytest     - Testing framework"
            echo "  ruff       - Linter and formatter"
            echo "  mypy       - Type checker"
            echo "  ipython    - Interactive Python shell"
            echo "  just       - Task runner (see justfile)"
            echo ""
            echo "Quick start:"
            echo "  just setup-project myapp  - Create src/ structure"
            echo "  just venv                 - Create virtual environment"
            echo "  source .venv/bin/activate"
            echo "  just install              - Install dependencies"
            echo "  just help                 - Show all tasks"
            echo ""
            echo "Virtual environment:"
            echo "  source .venv/bin/activate"
          '';

          # Environment variables
          PYTHONPATH = ".";
          UV_CACHE_DIR = ".uv-cache";
        };
      });
}
