{inputs, username, host, channel, pkgs, lib, hostDisplayConfig, ...}: {
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_macchiato_transparent";
      
      editor = {
        shell = ["fish" "-c"];
        "line-number" = "relative";
        cursorline = true;
        "color-modes" = true;
        "auto-save" = false;
        "idle-timeout" = 0;
        bufferline = "multiple";
        "popup-border" = "popup";
        
        "cursor-shape" = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        "indent-guides" = {
          render = true;
        };
        
        statusline = {
          left = ["mode" "spinner" "file-name" "read-only-indicator" "file-modification-indicator" "separator" "total-line-numbers" "separator" "spacer" "version-control"];
          right = ["register" "spacer" "diagnostics" "separator" "selections" "separator" "position" "position-percentage" "spacer" "separator" "file-encoding" "file-line-ending" "separator" "file-type"];
          separator = "│";
        };
        
        lsp = {
          "display-messages" = true;
          "display-inlay-hints" = true;
        };

        "soft-wrap" = {
          enable = true;
        };
      };
      
      keys.normal = {
        backspace = { 
          w = ":w";
          d = ":bc";
          "S-d" = ":bca";
          q = ":q";
          "A-w" = ":w!";
          "A-q" = ":q!";
          "A-d" = ":bc!";
          "A-S-d" = ":bca!";
        };
        "S-l" = ":bn";
        "S-h" = ":bp";
        "S-right" = ":bn";
        "S-left" = ":bp";
        "A-w" = ":w";
      };
    };
    
    languages = {
      "language-server" = {
        hyprls = {
          command = "hyprls";
        };

        "emmet-lsp" = {
          command = "emmet-language-server";
          args = ["--stdio"];
        };
        
        copilot = {
          command = "helix-gpt";
          args = [
            "--handler" "copilot"
            # API key omitted for security
          ];
        };

        "lsp-ai" = {
          command = "lsp-ai";
          args = ["--stdio"];
        };
        
        "rust-analyzer.config" = {
          checkOnSave = { command = "clippy"; };
        };
      };
      
      language = [
        {
          name = "hyprlang";
          "language-servers" = [ "hyprls" ];
        }
        {
          name = "rust";
          "language-servers" = [ "rust-analyzer" "copilot" ];
        }
        {
          name = "html";
          "language-servers" = [ "emmet-lsp" "vscode-html-language-server" ];
        }
        {
          name = "javascript";
          "auto-format" = true;
          indent = { "tab-width" = 4; unit = "    "; };
          "language-servers" = [ "typescript-language-server" "copilot" ];
        }
        {
          name = "jsx";
          "auto-format" = true;
          indent = { "tab-width" = 4; unit = "    "; };
          "language-servers" = [ "typescript-language-server" "copilot" ];
        }
        {
          name = "typescript";
          "auto-format" = true;
          indent = { "tab-width" = 4; unit = "    "; };
          "language-servers" = [ "typescript-language-server" "copilot" ];
        }
        {
          name = "tsx";
          "auto-format" = true;
          indent = { "tab-width" = 4; unit = "   "; };
          "language-servers" = [ "typescript-language-server" "copilot" ];
        }
        {
          name = "config";
          scope = "source.conf";
          "file-types" = [ "conf" ];
          "comment-token" = "#";
          roots = [];
          indent = { "tab-width" = 4; unit = "    "; };
        }
      ];
    };
    
    themes = {
      catppuccin_macchiato_transparent = {
        inherits = "catppuccin_macchiato";
        "ui.background" = { bg = "transparent"; };
      };
    };
  };
}