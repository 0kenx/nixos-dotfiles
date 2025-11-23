function devinit --description 'Initialize development environment from template'
    # Base path to templates
    set -l template_base "$HOME/git/nixos-dotfiles/user/projects"

    # Check if language argument is provided
    if test (count $argv) -eq 0
        echo "Usage: devinit <language>"
        echo ""
        echo "Available templates:"
        echo "  devinit rust      - Rust with Crane, cargo tools"
        echo "  devinit python    - Python 3.12 with uv"
        echo "  devinit solidity  - Solidity with Foundry"
        return 1
    end

    set -l language $argv[1]
    set -l template_dir ""

    # Determine template directory
    switch $language
        case rust
            set template_dir "$template_base/optimized-pre-config-rust"
        case python py
            set template_dir "$template_base/optimized-pre-config-python"
        case solidity sol
            set template_dir "$template_base/optimized-pre-config-solidity"
        case '*'
            echo "❌ Unknown language: $language"
            echo ""
            echo "Available templates: rust, python, solidity"
            return 1
    end

    # Check if template exists
    if not test -d "$template_dir"
        echo "❌ Template directory not found: $template_dir"
        return 1
    end

    # Check if current directory is empty (excluding hidden files)
    set -l visible_files (ls -A 2>/dev/null | grep -v '^\.' | wc -l)
    if test $visible_files -gt 0
        echo "⚠️  Current directory is not empty!"
        echo "Files will be copied from template. Continue? [y/N]"
        read -l confirm
        if test "$confirm" != "y" -a "$confirm" != "Y"
            echo "Cancelled."
            return 1
        end
    end

    # Copy template files
    echo "📦 Copying $language template..."
    cp -r "$template_dir"/. .

    if test $status -ne 0
        echo "❌ Failed to copy template files"
        return 1
    end

    echo "✓ Template files copied"

    # Initialize git if not already a git repo
    if not test -d .git
        echo "📝 Initializing git repository..."
        git init
        echo "✓ Git repository initialized"
    end

    # Run direnv allow if .envrc exists
    if test -f .envrc
        echo "🔧 Activating direnv..."
        direnv allow
        if test $status -eq 0
            echo "✓ Direnv activated"
        else
            echo "⚠️  Direnv activation failed. Run 'direnv allow' manually."
        end
    end

    # Show next steps based on language
    echo ""
    echo "🎉 $language development environment initialized!"
    echo ""
    echo "Next steps:"

    switch $language
        case rust
            echo "  1. cargo init               # Initialize Rust project"
            echo "  2. just build               # Build project"
            echo "  3. just test                # Run tests"
            echo "  4. just help                # See all commands"
        case python py
            echo "  1. just venv                # Create virtual environment"
            echo "  2. source .venv/bin/activate"
            echo "  3. just install             # Install dependencies"
            echo "  4. just test                # Run tests"
            echo "  5. just help                # See all commands"
        case solidity sol
            echo "  1. just init                # Initialize Foundry project"
            echo "  2. just build               # Build contracts"
            echo "  3. just test                # Run tests"
            echo "  4. just help                # See all commands"
    end

    echo ""
    echo "📖 Read README.md for detailed documentation"
end
