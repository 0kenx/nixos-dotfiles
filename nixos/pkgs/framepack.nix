# /etc/nixos/framepack.nix
{ lib, pkgs, fetchFromGitHub, python310Packages, makeWrapper, ffmpeg-full, torchWithCuda }:

# Resolve specific Python packages from the python310Packages set
with python310Packages;

let
  # Define opencv with contrib for python310
  #opencv4WithContribAndPython310 = pkgs.opencv4.override {
  #  enableContrib = true;
  #  python = pkgs.python310; # Use the specific python interpreter from pkgs
    # If opencv's nix file for python bindings needs the python package set:
    # pythonPackages = python310Packages;
  #};

  # Define torchvision and torchaudio, ensuring they are compatible with torchWithCuda
  # If nixpkgs provides torchWithCuda, torchvision and torchaudio from the same
  # python3xPackages set are generally built to be compatible.
  # Explicitly enabling CUDA for them might look like:
  # torchvisionForFramePack = torchvision.override { cudaSupport = true; }; # If such an option exists
  # torchaudioForFramePack = torchaudio.override { cudaSupport = true; };  # If such an option exists
  # For simplicity, we'll assume standard torchvision/torchaudio from python310Packages
  # will work correctly when torchWithCuda is present and properly configured.
  # If issues arise, these would be the first candidates for overrides.

in
buildPythonApplication rec {
  pname = "framepack";
  version = "1b371ad"; # Corresponds to the commit used, or a chosen version string

  src = fetchFromGitHub {
    owner = "lllyasviel";
    repo = "FramePack";
    # Using a specific commit for reproducibility. Replace with a desired tag or commit.
    # This commit corresponds to the "Windows" release mentioned in [18] (1b371ad).
    rev = "1b371ad7923355f85bac5d904a138961fb19ea30";
    hash = "sha256-nLfbt9qiCaEcfrOya7mGEjPeetGD0koYWOV2XjQvT9w=";
  };

  # Propagate the Python interpreter to ensure scripts use it
  interpreter = "${pkgs.python310}/bin/python";

  preBuild = ''
    cat > setup.py << EOF
    from setuptools import setup, find_packages

    # Filter out dependencies managed explicitly by Nix or system dependencies
    with open('requirements.txt') as f:
        install_requires = [
            line.strip() for line in f 
            if line.strip() and not line.startswith((
                '#', 'torch', 'torchvision', 'torchaudio', 
                'opencv-contrib-python', 'accelerate', 'diffusers',
                'transformers', 'gradio', 'sentencepiece', 'pillow',
                'av', 'numpy', 'scipy', 'requests', 'torchsde',
                'einops', 'safetensors' 
            ))
        ]
    # Add back only those that are simple PyPI packages without complex Nix handling
    # For FramePack, most are handled by propagatedBuildInputs.
    # If any were simple, they could be parsed and added here.
    # For now, assume all significant ones are in propagatedBuildInputs.
    # An empty install_requires is fine if all deps are in propagatedBuildInputs.

    setup(
        name='FramePack',
        version='${version}',
        packages=find_packages(), # Likely empty if no actual Python modules
        install_requires=install_requires, # Can be empty if all handled by Nix
        scripts=['demo_gradio.py', 'demo_gradio_f1.py']
    )
    EOF

    # Patch requirements.txt to remove versions for packages Nix will provide,
    # to avoid potential conflicts if setup.py parsing were more complex.
    # Or, more simply, ensure install_requires in setup.py is minimal/empty
    # as Nix handles dependencies.
  '';

  # buildPythonApplication uses setuptools by default.
  # format = "setuptools"; # Explicitly, though default

  propagatedBuildInputs = with python310Packages; [
    torchWithCuda # Provides torch, torchvision, torchaudio with CUDA
    accelerate
    diffusers
    transformers
    gradio
    sentencepiece
    pillow
    av # Nixpkgs name for PyAV
    numpy
    scipy
    requests
    torchsde
    einops
    #opencv4WithContribAndPython310 
    opencv-python
    safetensors
    setuptools # For pkg_resources, good to include proactively
  ];

  # System-level dependencies
  buildInputs = [
    ffmpeg-full # For python-av and opencv-contrib-python video capabilities
    # pkgs.cudaPackages.cudatoolkit # torchWithCuda should handle CUDA runtime deps
  ];

  # Ensure scripts are executable
  postInstall = ''
    install -m 755 -D demo_gradio.py $out/bin/demo_gradio.py
    install -m 755 -D demo_gradio_f1.py $out/bin/demo_gradio_f1.py
    # The buildPythonApplication with `scripts` in setup.py should handle this,
    # but this is an explicit fallback if needed or if `format = "other"` were used.
    # If `scripts` in `setup.py` works, this postInstall for scripts is redundant.
  '';
  # buildPythonApplication should handle wrapping scripts listed in setup.py's `scripts` list automatically.

  meta = with lib; {
    description = "FramePack: Video diffusion practical implementation";
    homepage = "https://github.com/lllyasviel/FramePack";
    license = licenses.asl20;
    maintainers = with maintainers; [ ]; # Add your GitHub username
    platforms = platforms.linux;
    mainProgram = "framepack";
  };
}
