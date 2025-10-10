{ pkgs, pkgs-unstable, config, lib, resolvedHostDotfilesConfig, ... }:

let
  # Determine GPU acceleration backend based on hardware configuration
  # Future: Support multiple GPU types (Intel, AMD) that can be configured per-profile
  hasNvidia = resolvedHostDotfilesConfig.hardware.hasNvidia or false;

  # Future expansion: Add more GPU backend detection
  # hasIntelGPU = resolvedHostDotfilesConfig.hardware.hasIntelGPU or false;
  # hasAMDGPU = resolvedHostDotfilesConfig.hardware.hasAMDGPU or false;

  # Determine acceleration method
  # Priority: CUDA > Intel > AMD > CPU
  acceleration =
    if hasNvidia then "cuda"
    # else if hasIntelGPU then "intel"  # Future: Intel GPU support
    # else if hasAMDGPU then "rocm"     # Future: AMD ROCm support
    else "cpu";  # Fallback to CPU-only inference

in {
  # Ollama service for local LLM inference
  # Provides REST API for model interaction and automatic model management
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama;

    # Pre-load models for immediate availability
    # Models are downloaded on first service start
    loadModels = [
      "deepseek-r1:14b"   # Reasoning model
      "gemma3:12b"        # General purpose
      "deepcoder:14b"     # Code-specialized model
      "qwen3:14b"         # Multi-lingual model
    ];

    # GPU acceleration backend (auto-detected based on hardware)
    acceleration = acceleration;

    # Future configuration options:
    # - Model-specific GPU allocation
    # - Quantization settings per model
    # - Memory limits and swap configuration
    # - Multi-GPU distribution strategies
  };

  # Web UI for Ollama (optional, can be enabled per-host)
  # Provides a browser-based interface for model interaction
  # services.open-webui = {
  #   enable = true;
  #   port = 18888;
  #   host = "127.0.0.1";
  # };

  # Add proper shutdown timeout for open-webui service
  # systemd.services.open-webui = {
  #   serviceConfig = {
  #     TimeoutStopSec = "10s";
  #   };
  # };

  # Future expansion possibilities:
  # - LocalAI for OpenAI-compatible API
  # - vLLM for high-performance inference
  # - Text-generation-webui for advanced features
  # - Stable Diffusion for image generation (multimedia AI)
  # - Whisper for speech-to-text
  # - XTTS for text-to-speech
  # - ComfyUI for advanced image/video workflows
  # - Multi-GPU orchestration and load balancing
}
