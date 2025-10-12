{ pkgs, pkgs-unstable, config, lib, resolvedHostDotfilesConfig, ... }:

let
  # GPU backend detection for PyTorch installation
  hasNvidia = resolvedHostDotfilesConfig.hardware.hasNvidia or false;
  # Future: hasIntelGPU = resolvedHostDotfilesConfig.hardware.hasIntelGPU or false;
  # Future: hasAMDGPU = resolvedHostDotfilesConfig.hardware.hasAMDGPU or false;

  # Determine PyTorch installation command based on GPU
  # Following ComfyUI's recommended installation methods
  torchInstallCmd =
    if hasNvidia then
      # NVIDIA: Use CUDA 12.9 stable
      "uv pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu129"
    # Future Intel GPU support:
    # else if hasIntelGPU then
    #   "uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu"
    # Future AMD GPU support:
    # else if hasAMDGPU then
    #   "uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.4"
    else
      # CPU fallback
      "uv pip install torch torchvision torchaudio";

  # ComfyUI setup and launch script with NixOS GPU driver support
  comfyui-launcher = pkgs.writeScriptBin "comfyui" ''
    #!${pkgs.bash}/bin/bash
    set -e

    # ComfyUI installation directory
    COMFYUI_DIR="$HOME/.local/share/comfyui"
    REPO_URL="https://github.com/comfyanonymous/ComfyUI.git"

    # Create directory structure
    mkdir -p "$COMFYUI_DIR"
    cd "$COMFYUI_DIR"

    # Clone ComfyUI if not present
    if [ ! -d "$COMFYUI_DIR/ComfyUI" ]; then
      echo "Cloning ComfyUI..."
      ${pkgs.git}/bin/git clone "$REPO_URL" ComfyUI
    fi

    cd ComfyUI

    # Create model directories
    mkdir -p models/checkpoints models/vae models/loras models/embeddings \
             models/upscale_models models/controlnet models/clip_vision \
             models/style_models models/clip

    # Create/update virtual environment using uv with Python 3.12
    # Note: Python 3.13 has compatibility issues with some dependencies (e.g., mediapipe)
    if [ ! -d ".venv" ]; then
      echo "Creating virtual environment with Python 3.12..."
      ${pkgs-unstable.uv}/bin/uv venv --python ${pkgs.python312}/bin/python3.12 .venv
    fi

    # Activate virtual environment
    source .venv/bin/activate

    # Install PyTorch with appropriate backend
    echo "Installing PyTorch for your GPU..."
    ${torchInstallCmd}

    # Install ComfyUI dependencies
    echo "Installing ComfyUI dependencies..."
    ${pkgs-unstable.uv}/bin/uv pip install -r requirements.txt

    # NixOS: Make GPU drivers and system libraries accessible to Python virtual environment
    ${if hasNvidia then ''
      # Add NVIDIA and OpenGL libraries to LD_LIBRARY_PATH for NixOS
      # /run/opengl-driver is a NixOS standard path containing GPU drivers
      # libglvnd provides libGL.so.1, glib provides libgthread-2.0.so.0 for opencv-python
      export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.libglvnd}/lib:${pkgs.glib.out}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      echo "GPU: NVIDIA drivers loaded from /run/opengl-driver"
      echo "OpenCV libraries: libGL from libglvnd, libgthread from glib"
    '' else ""}

    # Launch ComfyUI
    echo "Starting ComfyUI..."
    echo "Access the UI at: http://127.0.0.1:8188"
    echo ""
    echo "Model directories:"
    echo "  Checkpoints: $COMFYUI_DIR/ComfyUI/models/checkpoints"
    echo "  VAE:         $COMFYUI_DIR/ComfyUI/models/vae"
    echo "  LoRAs:       $COMFYUI_DIR/ComfyUI/models/loras"
    echo ""
    python main.py --auto-launch "$@"
  '';

  # ComfyUI update script
  comfyui-update = pkgs.writeScriptBin "comfyui-update" ''
    #!${pkgs.bash}/bin/bash
    set -e

    COMFYUI_DIR="$HOME/.local/share/comfyui/ComfyUI"

    if [ ! -d "$COMFYUI_DIR" ]; then
      echo "ComfyUI not installed. Run 'comfyui' first."
      exit 1
    fi

    cd "$COMFYUI_DIR"
    echo "Updating ComfyUI..."
    ${pkgs.git}/bin/git pull

    # Update dependencies
    source .venv/bin/activate
    ${pkgs-unstable.uv}/bin/uv pip install -r requirements.txt --upgrade

    echo "ComfyUI updated successfully!"
  '';

  # ComfyUI custom node installer script with NixOS build dependencies
  comfyui-install-nodes = pkgs.writeScriptBin "comfyui-install-nodes" ''
    #!${pkgs.bash}/bin/bash
    set -e

    COMFYUI_DIR="$HOME/.local/share/comfyui/ComfyUI"
    CUSTOM_NODES_DIR="$COMFYUI_DIR/custom_nodes"

    if [ ! -d "$COMFYUI_DIR" ]; then
      echo "ComfyUI not installed. Run 'comfyui' first."
      exit 1
    fi

    cd "$CUSTOM_NODES_DIR"

    echo "Installing ComfyUI custom nodes..."
    echo ""

    # Set up build environment for packages that need native dependencies
    # Export NixOS library paths for building Python packages with C extensions
    export PKG_CONFIG_PATH="${pkgs.cairo.dev}/lib/pkgconfig:${pkgs.glib.dev}/lib/pkgconfig:${pkgs.freetype.dev}/lib/pkgconfig:${pkgs.fontconfig.dev}/lib/pkgconfig:${pkgs.libpng}/lib/pkgconfig:${pkgs.pixman}/lib/pkgconfig:${pkgs.xorg.libxcb.dev}/lib/pkgconfig:${pkgs.xorg.libX11.dev}/lib/pkgconfig:${pkgs.xorg.xorgproto}/lib/pkgconfig"
    export LD_LIBRARY_PATH="${pkgs.cairo}/lib:${pkgs.glib}/lib:${pkgs.freetype}/lib:${pkgs.fontconfig.lib}/lib:${pkgs.libpng}/lib:${pkgs.pixman}/lib:${pkgs.zlib}/lib:${pkgs.xorg.libxcb}/lib:${pkgs.xorg.libX11}/lib:${pkgs.stdenv.cc.cc.lib}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export C_INCLUDE_PATH="${pkgs.xorg.xorgproto}/include:${pkgs.xorg.libxcb.dev}/include:${pkgs.xorg.libX11.dev}/include:${pkgs.cairo.dev}/include''${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"

    # List of essential custom node repositories
    declare -A NODES=(
      ["ComfyUI-Manager"]="https://github.com/Comfy-Org/ComfyUI-Manager.git"
      ["rgthree-comfy"]="https://github.com/rgthree/rgthree-comfy.git"
      ["ComfyUI-KJNodes"]="https://github.com/kijai/ComfyUI-KJNodes.git"
      ["Comfyui-QwenEditUtils"]="https://github.com/lrzjason/Comfyui-QwenEditUtils.git"
      ["gguf"]="https://github.com/calcuis/gguf.git"
      ["comfyui_controlnet_aux"]="https://github.com/Fannovel16/comfyui_controlnet_aux.git"
    )

    # Install each custom node
    for node_name in "''${!NODES[@]}"; do
      node_url="''${NODES[$node_name]}"

      if [ -d "$node_name" ]; then
        echo "[$node_name] Already installed, updating..."
        cd "$node_name"
        ${pkgs.git}/bin/git pull
        cd ..
      else
        echo "[$node_name] Installing from $node_url..."
        ${pkgs.git}/bin/git clone "$node_url" "$node_name"
      fi

      # Install node-specific requirements if they exist
      if [ -f "$node_name/requirements.txt" ]; then
        echo "[$node_name] Installing Python dependencies..."
        source "$COMFYUI_DIR/.venv/bin/activate"
        ${pkgs-unstable.uv}/bin/uv pip install -r "$node_name/requirements.txt"
      fi

      echo "[$node_name] ✓ Done"
      echo ""
    done

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "All custom nodes installed successfully!"
    echo "Restart ComfyUI to load the new nodes."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  '';

in {
  # Multimedia AI tools - Image and video generation
  environment.systemPackages = [
    comfyui-launcher       # Launch ComfyUI with auto-configured GPU backend
    comfyui-update         # Update ComfyUI and dependencies
    comfyui-install-nodes  # Install custom nodes for ComfyUI
    pkgs-unstable.uv       # Modern Python package manager (replaces pip)
    pkgs.git               # Required for cloning repositories

    # Python and build dependencies
    pkgs.python312
    pkgs.python312Packages.pip

    # Build dependencies for Python packages with C extensions (pycairo, etc.)
    pkgs.pkg-config        # Required for building packages
    pkgs.cairo             # Cairo graphics library
    pkgs.glib              # GLib
    pkgs.freetype          # Font rendering
    pkgs.fontconfig        # Font configuration
    pkgs.libpng            # PNG support
    pkgs.pixman            # Low-level pixel manipulation
    pkgs.zlib              # Compression library
    pkgs.xorg.libxcb       # XCB library (required by Cairo)
    pkgs.xorg.libX11       # X11 library (required by Cairo)
    pkgs.xorg.xorgproto    # X11 protocol headers
    pkgs.libglvnd          # OpenGL vendor-neutral dispatch (provides libGL.so.1 for opencv)

    # Future multimedia AI tools:
    # - Stable Diffusion WebUI
    # - Automatic1111
    # - Fooocus
    # - InvokeAI
  ];

  # Environment variables for ComfyUI
  environment.variables = {
    # Default ComfyUI installation path
    COMFYUI_HOME = "$HOME/.local/share/comfyui";
  };

  # Future expansion:
  # - Systemd service for ComfyUI server
  # - Automatic model downloads
  # - Custom node management
  # - Multi-GPU configuration
  # - WebUI for video generation (AnimateDiff, etc.)
  # - Audio generation tools (AudioLDM, MusicGen, etc.)
}
