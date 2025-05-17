{ config, lib, pkgs, ... }:

{
  # AITerm configuration
  xdg.configFile."aiterm/config.yaml" = {
    text = ''
      allowed_commands:
      - pwd
      - ls
      - echo
      - date
      - cat
      - grep
      - find
      - which
      - whoami
      - hostname
      - uname
      - df
      - du
      - ps
      - top
      - free
      - uptime
      default_models:
      - ollama
      - o4-mini
      history_file: ~/.local/share/aiterm/history.json
      models:
        claude:
          history_context_size: 500
          include_history_context: false
          include_path_commands: false
          model: claude-3-sonnet-20240229
          provider: anthropic
        o4-mini:
          history_context_size: 500
          include_history_context: false
          include_path_commands: false
          model: o4-mini
          provider: openai
        gpt4:
          history_context_size: 500
          include_history_context: false
          include_path_commands: false
          model: gpt-4o
          provider: openai
          temperature: 0.7
        ollama:
          history_context_size: 500
          include_history_context: true
          include_path_commands: true
          model: gemma3:12b
          provider: ollama
      providers:
        anthropic: {}
        ollama:
          base_url: http://localhost:11434
        openai: {}
        test: {}
    '';
  };

  # Ensure the aiterm data directory exists
  home.file.".local/share/aiterm/.keep".text = "";
}
