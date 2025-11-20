function devinfo --description 'Show current development environment info'
    set -l has_info false

    echo "🔍 Development Environment Info"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Check for Rust
    if test -f Cargo.toml
        echo "📦 Language: Rust"
        if type -q cargo
            echo "   Version: "(cargo --version 2>/dev/null | string split ' ')[2]
        end
        if test -f rust-toolchain.toml
            echo "   Toolchain: Custom (see rust-toolchain.toml)"
        end
        set has_info true
    end

    # Check for Python
    if test -f pyproject.toml; or test -f setup.py; or test -f requirements.txt
        echo "📦 Language: Python"
        if type -q python
            echo "   Version: "(python --version 2>/dev/null | string split ' ')[2]
        end
        if test -f .python-version
            echo "   Expected: "(cat .python-version)
        end
        if test -d .venv
            echo "   Venv: ✓ (.venv/)"
        else
            echo "   Venv: ✗ (run 'just venv')"
        end
        set has_info true
    end

    # Check for Solidity
    if test -f foundry.toml
        echo "📦 Language: Solidity"
        if type -q forge
            echo "   Foundry: "(forge --version 2>/dev/null | head -n1)
        end
        if type -q solc
            echo "   Solc: "(solc --version 2>/dev/null | head -n1)
        end
        set has_info true
    end

    # Check for Node.js
    if test -f package.json
        echo "📦 Language: JavaScript/TypeScript"
        if type -q node
            echo "   Node: "(node --version)
        end
        if type -q npm
            echo "   npm: "(npm --version)
        end
        if test -d node_modules
            echo "   Packages: ✓ (node_modules/)"
        else
            echo "   Packages: ✗ (run 'npm install')"
        end
        set has_info true
    end

    # Check for Go
    if test -f go.mod
        echo "📦 Language: Go"
        if type -q go
            echo "   Version: "(go version | string split ' ')[2]
        end
        set has_info true
    end

    echo ""

    # Check for Nix flake
    if test -f flake.nix
        echo "❄️  Nix: flake.nix present"
        if test -f flake.lock
            echo "   Lock: ✓"
        else
            echo "   Lock: ✗ (run 'nix flake lock')"
        end
    end

    # Check for direnv
    if test -f .envrc
        echo "🔧 Direnv: .envrc present"
        if direnv status 2>/dev/null | grep -q "Found RC allowed true"
            echo "   Status: ✓ Activated"
        else
            echo "   Status: ✗ Not activated (run 'direnv allow')"
        end
    end

    # Check for justfile
    if test -f justfile; or test -f Justfile
        echo "⚙️  Just: Task runner available (run 'just help')"
    end

    # Check for git
    if test -d .git
        echo "📝 Git: Repository initialized"
        set -l branch (git branch --show-current 2>/dev/null)
        if test -n "$branch"
            echo "   Branch: $branch"
        end
        set -l status_output (git status --short 2>/dev/null)
        if test -n "$status_output"
            echo "   Status: Uncommitted changes"
        else
            echo "   Status: Clean"
        end
    end

    if not $has_info
        echo "ℹ️  No recognized development project in current directory"
        echo ""
        echo "Initialize a new project with:"
        echo "  devinit rust      - Rust project"
        echo "  devinit python    - Python project"
        echo "  devinit solidity  - Solidity project"
    end

    echo ""
end
