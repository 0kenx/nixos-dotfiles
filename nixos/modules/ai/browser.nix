{ pkgs, pkgs-unstable, ... }:

let
  # Use unstable playwright-driver for newer browser builds matching agent-browser's expectations
  playwright-browsers-compat = pkgs.runCommand "playwright-browsers-compat" {} ''
    mkdir -p $out

    # Symlink all existing browser directories from unstable
    for item in ${pkgs-unstable.playwright-driver.browsers}/*; do
      ln -s "$item" "$out/$(basename $item)"
    done

    # Find the actual chromium revision unstable provides
    CHROMIUM_REV=$(ls -d ${pkgs-unstable.playwright-driver.browsers}/chromium-* | head -1 | sed 's/.*chromium-//')
    HEADLESS_REV=$(ls -d ${pkgs-unstable.playwright-driver.browsers}/chromium_headless_shell-* | head -1 | sed 's/.*chromium_headless_shell-//')

    # Create aliases for revisions that newer playwright versions may request
    for rev in 1200 1208 1210 1212; do
      [ ! -e "$out/chromium-$rev" ] && \
        ln -s ${pkgs-unstable.playwright-driver.browsers}/chromium-$CHROMIUM_REV $out/chromium-$rev
      [ ! -e "$out/chromium_headless_shell-$rev" ] && \
        ln -s ${pkgs-unstable.playwright-driver.browsers}/chromium_headless_shell-$HEADLESS_REV $out/chromium_headless_shell-$rev
    done
  '';

  # Agent-browser wrapper: lazily npm-installs on first run, uses Nix-provided Chromium
  agent-browser = pkgs.writeShellScriptBin "agent-browser" ''
    export PATH="${pkgs.nodejs_22}/bin:$PATH"
    export HOME="''${HOME:-/tmp}"
    export npm_config_cache="$HOME/.cache/agent-browser-npm"

    INSTALL_DIR="$HOME/.local/share/agent-browser-nix"
    if [ ! -f "$INSTALL_DIR/node_modules/.package-lock.json" ]; then
      mkdir -p "$INSTALL_DIR"
      cd "$INSTALL_DIR"
      cat > package.json << 'PKGJSON'
    {
      "name": "agent-browser-nix",
      "private": true,
      "dependencies": {
        "agent-browser": "latest"
      }
    }
    PKGJSON
      npm install 2>/dev/null
    fi

    exec env \
      PLAYWRIGHT_BROWSERS_PATH="${playwright-browsers-compat}" \
      PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
      NODE_PATH="$INSTALL_DIR/node_modules" \
      node "$INSTALL_DIR/node_modules/agent-browser/bin/agent-browser.js" "$@"
  '';
in
{
  environment.systemPackages = [
    agent-browser
  ];

  # Playwright/agent-browser: use Nix-provided browsers system-wide
  environment.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${playwright-browsers-compat}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };

  # nix-ld libraries required by Chromium (dynamically linked via Playwright)
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    curl
    libGL
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
  ];
}
