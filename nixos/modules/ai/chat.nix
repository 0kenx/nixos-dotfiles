{ pkgs, pkgs-unstable, config, ... }:

{
  # General-purpose AI chat clients and interfaces
  # These tools provide interactive chat experiences with various AI models
  environment.systemPackages = [
    pkgs.aichat  # Multi-provider AI chat CLI (supports OpenAI, Claude, Gemini, local models)
    pkgs.oterm   # Terminal UI for Ollama models
    pkgs.alpaca  # GTK-based Ollama client with graphical interface

    # Other available chat clients (commented out but ready to enable):
    # pkgs.tgpt              # Terminal GPT - ChatGPT in terminal without API key
    # pkgs.smartcat          # AI-powered cat command alternative
  ];

  # Future expansion possibilities:
  # - Web-based chat interfaces (Open WebUI, etc.)
  # - Voice-enabled assistants
  # - Multi-modal chat clients (text + image)
  # - Custom chat UIs for specific models
}
