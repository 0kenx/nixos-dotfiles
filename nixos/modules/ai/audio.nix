{ pkgs, pkgs-unstable, config, lib, resolvedHostDotfilesConfig, ... }:

let
  hasNvidia = resolvedHostDotfilesConfig.hardware.hasNvidia or false;

  # Select whisper.cpp package based on GPU availability
  whisperPackage =
    if hasNvidia then pkgs.whisper-cpp.override { cudaSupport = true; }
    else pkgs.whisper-cpp;

in {
  # Speech-to-text and text-to-speech system packages
  environment.systemPackages = [
    # Core speech recognition
    whisperPackage             # whisper.cpp for offline speech-to-text

    # Audio processing
    pkgs.sox                   # Sound processing for audio recording
    pkgs.ffmpeg                # Audio/video conversion

    # Clipboard and input automation (Wayland)
    pkgs.wl-clipboard          # wl-copy/wl-paste for clipboard
    pkgs.ydotool               # Input automation for Wayland (autopaste)

    # Clipboard and input automation (X11 fallback)
    pkgs.xsel                  # Clipboard for X11
    pkgs.xdotool               # Input automation for X11

    # Desktop notifications
    pkgs.libnotify             # notify-send for notifications
    pkgs.zenity                # Dialog boxes

    # Shell requirement for BlahST scripts
    pkgs.zsh                   # Scripts are written in zsh

    # Text-to-speech
    pkgs.piper-tts             # Neural text-to-speech

    # HTTP client for network mode
    pkgs.curl                  # API calls
    pkgs.jq                    # JSON processing
  ];

  # ydotool daemon runs as user service (defined in home/blahst.nix)
  # to avoid socket permission issues with the system-level service
}
