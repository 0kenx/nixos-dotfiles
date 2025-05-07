{ pkgs, pkgs-unstable, config, ... }:

{

  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama;
    loadModels = [ "llama3.2:3b" "llama3.2-vision:11b" "phi4:14b" "deepseek-r1:7b" "dolphin3:8b" "smallthinker:3b" "nomic-embed-text" "gemma3:12b" "gemma3:27b" "deepcoder:14b" ];
    acceleration = "cuda";
  };


  services.open-webui = {
    enable = true;
    port = 18888;
    host = "127.0.0.1";
  };
  
  environment.systemPackages = with pkgs; [
    oterm
    alpaca
    aichat
    aider-chat

    # tgpt
    # smartcat
    # nextjs-ollama-llm-ui
    # open-webui
  ];
}
