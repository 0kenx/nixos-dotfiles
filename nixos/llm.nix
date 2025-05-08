{ pkgs, pkgs-unstable, config, ... }:

{

  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama;
    loadModels = [ "llama3.2-vision:11b" "deepseek-r1:14b" "gemma3:12b" "deepcoder:14b" "qwen3:14b" ];
    acceleration = "cuda";
  };


  services.open-webui = {
    enable = true;
    port = 18888;
    host = "127.0.0.1";
  };
  
  environment.systemPackages = [
    pkgs.oterm
    pkgs.alpaca
    pkgs.aichat
    pkgs.aider-chat
    #framepack

    pkgs-unstable.claude-code

    # tgpt
    # smartcat
    # nextjs-ollama-llm-ui
    # open-webui
  ];

}
