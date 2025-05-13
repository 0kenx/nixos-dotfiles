{ pkgs, pkgs-unstable, config, ... }:

{
  # Ollama service for local LLM inference
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

  # Add proper shutdown timeout for open-webui service
  systemd.services.open-webui = {
    serviceConfig = {
      TimeoutStopSec = "10s";
    };
  };
  
  # Local LLM tools and clients
  environment.systemPackages = [
    pkgs.oterm
    pkgs.alpaca
    #framepack

    # Other local LLM tools (commented out but available)
    # tgpt
    # smartcat
    # nextjs-ollama-llm-ui
    # open-webui
  ];
}