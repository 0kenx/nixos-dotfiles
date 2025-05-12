{ pkgs, pkgs-unstable, config, ... }:

{
  # Local LLM services (Ollama, requires CUDA)
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama;
    loadModels = [ "llama3.2-vision:11b" "deepseek-r1:14b" "gemma3:12b" "deepcoder:14b" "qwen3:14b" ];
    acceleration = "cuda";
  };

  # Web UI for Ollama
  services.open-webui = {
    enable = true;
    port = 18888;
    host = "127.0.0.1";
  };
  
  # Local LLM CLI tools
  environment.systemPackages = [
    pkgs.oterm
    pkgs.alpaca
    # framepack (uncommented in original)
  ];
}