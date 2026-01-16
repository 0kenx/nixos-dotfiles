{ pkgs, lib, ... }:

# BlahST - Speech-to-Text input tool for Linux
# https://github.com/QuantiusBenignus/BlahST
# All scripts embedded directly for fully declarative NixOS setup

let
  # BlahST configuration for NixOS
  blahstConfig = ''
    #X11 or Wayland
    wm="$XDG_SESSION_TYPE"

    #---USER CONFIGURATION BLOCK----------------------------------------------------------------------
    TEMPD='/dev/shm'
    ramf="$TEMPD/wfile"
    NTHR=8
    PRIMESEL=0
    AUTOPASTE=1
    CHATMODE=0

    WHOST="127.0.0.1"
    WPORT="58080"

    AI="$HOME/.ai/models"
    WMODEL=''${WHISPER_DMODEL:-"$AI/whisper/ggml-large-v3-turbo-q5_0.bin"}

    LHOST="127.0.0.1"
    LPORT="58090"
    LLMODEL="$AI/Qwen3-4B-IQ4_NL.gguf"
    LIGHTLMODEL="$AI/Qwen3-0.6B-Q8_0.gguf"
    REWRITEMODEL="$AI/Qwen3-0.6B-Q8_0.gguf"
    llamf="llam"

    BOTMODEL="$AI/Mistral-Small-3.2-24B-Instruct-2506-UD-IQ3_XXS.gguf"
    BMOPTIONS="-ngl 99 -fa -c 8192 -nkvo -ctk q8_0 -ctv q8_0 --min-p 0.01 --top-k 64 --top-p 0.95 --no-webui --no-mmap --mlock --log-file $TEMPD/blahstlog "

    typeset -A BMPROMPT=(
    ["SHUTDOWN"]=''\'\'
    ["Science Assistant"]='You are a helpful science assistant who answers briefly and precisely.'
    ["Multilingual Assistant"]='You are a helpful assistant who answers briefly and precisely.'
    )

    BOTGREETING="I am ready. What shall we chat about?"

    TTSMODEL="$AI/piper/en_US-lessac-low.onnx"
    rtts="16000"
    TRANSMODEL="$AI/piper/zh_CN-huayan-medium.onnx"
    rtrans="22050"

    PPRMDIR=$AI/piper
    typeset -A TTSM=(
    ["en"]="en_US-lessac-low.onnx"
    ["es"]="es_ES-mls_9972-low.onnx"
    ["fr"]="fr_FR-gilles-low.onnx"
    ["de"]="de_DE-kerstin-low.onnx"
    ["zh"]="zh_CN-huayan-medium.onnx"
    )

    typeset -A modrate=(
    ["en"]=16000
    ["es"]=16000
    ["fr"]=16000
    ["de"]=16000
    ["zh"]=22050
    )

    blahst_deps=1

    select_role () {
        local keys=("''${(@k)BMPROMPT}")
        local role=$(zenity --title="BlahstBot Prompt" --height=$((''${#keys} * 50)) --width=256 --list --text="Select an LLM Role:" --column="Role" "''${keys[@]}")
        BOTPROMPT="''${BMPROMPT[$role]}"
    }

    desknote() {
        local title="$1"
        local message="$2"
        if command -v zenity &> /dev/null; then
            zenity --info --text="''${title}.\n$message"
        elif command -v notify-send &> /dev/null; then
            notify-send "$title" "$message"
        else
            echo "Notification: $message" >&2
        fi
    }

    blahst_depends() { return 0; }
  '';

  # Push-to-talk: start recording
  pttStartScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"
    source $HOME/.local/bin/blahst.cfg

    # Clean up any previous recording
    pkill -f "rec.*$ramf" 2>/dev/null
    rm -f "$ramf" /tmp/ptt-rec.pid 2>/dev/null

    # Start recording in background
    rec -q -t wav "$ramf" rate 16k channels 1 &
    echo $! > /tmp/ptt-rec.pid

    # Persistent notification (0 = no timeout, stays until dismissed)
    notify-send -t 0 -h string:x-canonical-private-synchronous:ptt "Recording..." "Press Super+G to stop and transcribe"
  '';

  # Push-to-talk: stop recording and transcribe
  pttStopScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"
    source $HOME/.local/bin/blahst.cfg

    # Wait for audio buffer to capture final speech
    sleep 1

    # Stop recording gracefully with SIGINT to allow buffer flush
    if [[ -f /tmp/ptt-rec.pid ]]; then
        pid=$(cat /tmp/ptt-rec.pid)
        kill -INT $pid 2>/dev/null
        # Wait for process to exit (max 3 seconds)
        for i in {1..30}; do
            kill -0 $pid 2>/dev/null || break
            sleep 0.1
        done
        rm -f /tmp/ptt-rec.pid
    fi
    pkill -INT -f "rec.*$ramf" 2>/dev/null
    sleep 0.3

    # Dismiss recording notification by replacing it
    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Processing..."

    # Check if we have audio
    if [[ ! -f "$ramf" ]]; then
        notify-send -t 2000 "PTT Error" "No audio recorded"
        exit 1
    fi

    # Transcribe via whisper-server
    if curl -s --connect-timeout 1 "http://$WHOST:$WPORT/health" >/dev/null 2>&1; then
        str=$(curl -s "http://$WHOST:$WPORT/inference" \
            -H "Content-Type: multipart/form-data" \
            -F file="@$ramf" \
            -F temperature="0.0" \
            -F response_format="text")
    else
        # Fallback to CLI if server not running
        str="$(transcribe -t $NTHR -nt -m $WMODEL -f $ramf 2>/dev/null)"
    fi

    # Clean up audio file for next use
    rm -f "$ramf"

    # Trim whitespace and remove line breaks
    str=$(echo "$str" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    str="''${str//$'\n'/ }"
    str="''${str//$'\r'/}"

    # Skip if empty or just noise markers
    if [[ -z "$str" || "$str" == *"[BLANK_AUDIO]"* ]]; then
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(no speech detected)"
        exit 0
    fi

    # Type the text directly (works in both GUI and terminal) - 0ms delay for speed
    ydotool type --key-delay 0 -- "$str"

    # Show result notification for 4 seconds
    notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "Voice Input" "$str"
  '';

  # Push-to-talk: stop recording, transcribe, and sanitize (remove stutters, filler words, etc.)
  pttStopSanitizeScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"
    source $HOME/.local/bin/blahst.cfg

    # Wait for audio buffer to capture final speech
    sleep 1

    # Stop recording gracefully with SIGINT to allow buffer flush
    if [[ -f /tmp/ptt-rec.pid ]]; then
        pid=$(cat /tmp/ptt-rec.pid)
        kill -INT $pid 2>/dev/null
        # Wait for process to exit (max 3 seconds)
        for i in {1..30}; do
            kill -0 $pid 2>/dev/null || break
            sleep 0.1
        done
        rm -f /tmp/ptt-rec.pid
    fi
    pkill -INT -f "rec.*$ramf" 2>/dev/null
    sleep 0.3

    # Dismiss recording notification by replacing it
    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Processing..."

    # Check if we have audio
    if [[ ! -f "$ramf" ]]; then
        notify-send -t 2000 "PTT Error" "No audio recorded"
        exit 1
    fi

    # Transcribe via whisper-server
    if curl -s --connect-timeout 1 "http://$WHOST:$WPORT/health" >/dev/null 2>&1; then
        str=$(curl -s "http://$WHOST:$WPORT/inference" \
            -H "Content-Type: multipart/form-data" \
            -F file="@$ramf" \
            -F temperature="0.0" \
            -F response_format="text")
    else
        # Fallback to CLI if server not running
        str="$(transcribe -t $NTHR -nt -m $WMODEL -f $ramf 2>/dev/null)"
    fi

    # Clean up audio file for next use
    rm -f "$ramf"

    # Trim whitespace and remove line breaks
    str=$(echo "$str" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    str="''${str//$'\n'/ }"
    str="''${str//$'\r'/}"

    # Skip if empty or just noise markers
    if [[ -z "$str" || "$str" == *"[BLANK_AUDIO]"* ]]; then
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(no speech detected)"
        exit 0
    fi

    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Sanitizing..."

    # Check if llama-server is running
    if ! curl -s --connect-timeout 1 "http://$LHOST:$LPORT/health" >/dev/null 2>&1; then
        notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "PTT Error" "llama-server not running on $LHOST:$LPORT"
        ydotool type --key-delay 0 -- "$str"
        exit 1
    fi

    # Use LLM server to clean up verbal stutters, filler words, repetitions
    cleaned=$(curl -s "http://$LHOST:$LPORT/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg text "$str" '{
            model: "qwen",
            max_tokens: 256,
            temperature: 0.3,
            messages: [
                {role: "system", content: "You are a text cleaner. Remove filler words (uh, um, er, like, you know), stutters, repeated words, and false starts. Output ONLY the cleaned text. Never add explanations or extra content. /no_think"},
                {role: "user", content: $text}
            ]
        }')" \
        | jq -r '.choices[0].message.content // empty' \
        | perl -0777 -pe 's/<think>.*?<\/think>//gs' \
        | tr '\n' ' ' \
        | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/  */ /g')

    # Fall back to original if LLM fails
    if [[ -z "$cleaned" ]]; then
        cleaned="$str"
    fi

    # Strip leading/trailing whitespace (sed is more reliable than zsh glob)
    cleaned=$(echo "$cleaned" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Type the text directly (works in both GUI and terminal) - 0ms delay for speed
    ydotool type --key-delay 0 -- "$cleaned"

    # Show result notification for 4 seconds
    notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "Voice Input (Sanitized)" "$cleaned"
  '';

  # Push-to-talk: stop recording, transcribe, and complete (rewrite professionally)
  pttCompleteScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"
    source $HOME/.local/bin/blahst.cfg

    # Wait for audio buffer to capture final speech
    sleep 1

    # Stop recording gracefully with SIGINT to allow buffer flush
    if [[ -f /tmp/ptt-rec.pid ]]; then
        pid=$(cat /tmp/ptt-rec.pid)
        kill -INT $pid 2>/dev/null
        # Wait for process to exit (max 3 seconds)
        for i in {1..30}; do
            kill -0 $pid 2>/dev/null || break
            sleep 0.1
        done
        rm -f /tmp/ptt-rec.pid
    fi
    pkill -INT -f "rec.*$ramf" 2>/dev/null
    sleep 0.3

    # Dismiss recording notification by replacing it
    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Processing..."

    # Check if we have audio
    if [[ ! -f "$ramf" ]]; then
        notify-send -t 2000 "PTT Error" "No audio recorded"
        exit 1
    fi

    # Transcribe via whisper-server
    if curl -s --connect-timeout 1 "http://$WHOST:$WPORT/health" >/dev/null 2>&1; then
        str=$(curl -s "http://$WHOST:$WPORT/inference" \
            -H "Content-Type: multipart/form-data" \
            -F file="@$ramf" \
            -F temperature="0.0" \
            -F response_format="text")
    else
        # Fallback to CLI if server not running
        str="$(transcribe -t $NTHR -nt -m $WMODEL -f $ramf 2>/dev/null)"
    fi

    # Clean up audio file for next use
    rm -f "$ramf"

    # Trim whitespace and remove line breaks
    str=$(echo "$str" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    str="''${str//$'\n'/ }"
    str="''${str//$'\r'/}"

    # Skip if empty or just noise markers
    if [[ -z "$str" || "$str" == *"[BLANK_AUDIO]"* ]]; then
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(no speech detected)"
        exit 0
    fi

    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Rewriting..."

    # Check if llama-server is running
    if ! curl -s --connect-timeout 1 "http://$LHOST:$LPORT/health" >/dev/null 2>&1; then
        notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "PTT Error" "llama-server not running on $LHOST:$LPORT"
        ydotool type --key-delay 0 -- "$str"
        exit 1
    fi

    # Use LLM server to rewrite the text professionally
    rewritten=$(curl -s "http://$LHOST:$LPORT/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg text "$str" '{
            model: "qwen",
            max_tokens: 256,
            temperature: 0.3,
            messages: [
                {role: "system", content: "You are a text editor. Rewrite the input to be clear, professional, and grammatically correct. Preserve the original meaning. Output ONLY the rewritten text. Never add explanations or extra content. /no_think"},
                {role: "user", content: $text}
            ]
        }')" \
        | jq -r '.choices[0].message.content // empty' \
        | perl -0777 -pe 's/<think>.*?<\/think>//gs' \
        | tr '\n' ' ' \
        | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/  */ /g')

    # Fall back to original if LLM fails
    if [[ -z "$rewritten" ]]; then
        rewritten="$str"
    fi

    # Strip leading/trailing whitespace (sed is more reliable than zsh glob)
    rewritten=$(echo "$rewritten" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Type the text directly (works in both GUI and terminal) - 0ms delay for speed
    ydotool type --key-delay 0 -- "$rewritten"

    # Show result notification for 4 seconds
    notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "Voice Input (Rewritten)" "$rewritten"
  '';

  # Legacy wsi script (silence detection mode)
  wsiScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"
    pidof -q wsi && exit 0
    source $HOME/.local/bin/blahst.cfg

    rec -q -t wav $ramf rate 16k silence 1 0.1 1% 1 2.0 5% 2>/dev/null
    str="$(transcribe -t $NTHR -nt -m $WMODEL -f $ramf 2>/dev/null)"
    str="''${str/\(*\)}"; str="''${str/\[*\]}"; str="''${str#$'\n'}"; str="''${str#$'\n'}"
    str="''${str#*([[:space:]])}"; [[ -n "$str" ]] && str="''${(C)str:0:1}''${str#?}"
    [[ -z "$str" ]] && exit 0
    echo -n "$str" | wl-copy
    ydotool key 29:1 47:1 47:0 29:0
  '';

  # wsiml script (multilingual)
  wsimlScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"
    source $HOME/.local/bin/blahst.cfg
    lang="en"
    model=''${WHISPER_DMODEL:-"$AI/whisper/ggml-small.bin"}

    while [ $# -gt 0 ]; do
        case "$1" in
            -p|--primary) PRIMESEL=1; shift ;;
            -c|--clipboard) shift ;;
            -w|--whisperfile) whf="$WHISPERFILE"; shift ;;
            -t|--translate) TRANSLATING="true"; shift ;;
            -l|--language) shift; lang=$1; shift ;;
            -n|--netapi)
                IPnPORT="$WHOST:$WPORT"
                [[ "$(curl -s -f -o /dev/null -w '%{http_code}' $IPnPORT)" != "200" ]] && exit 1
                shift ;;
            -h|--help) echo "Usage: $0 [-p] [-l lang] [-n] [-t] [-w]"; exit 0 ;;
            *) break ;;
        esac
    done
    rem_args=("$@")
    (( $blahst_deps )) || blahst_depends
    set -e

    rec -q -t wav $ramf rate 16k silence 1 0.1 1% 1 2.0 5% 2>/dev/null

    if [ -n "$IPnPORT" ]; then
        str=$(curl -S -s $IPnPORT/inference -H "Content-Type: multipart/form-data" -F file="@$ramf" -F language="$lang" -F translate="''${TRANSLATING:-false}" -F temperature="0.0" -F temperature_inc="0.2" -F response_format="text")
    elif [[ "$whf" == *.llamafile ]]; then
        str="$($whf -t $NTHR -nt -f $ramf -l $lang ''${TRANSLATING:+-tr} ''${rem_args[@]} 2>/dev/null)"
    else
        str="$(transcribe -t $NTHR -nt -m $model -f $ramf -l $lang ''${TRANSLATING:+-tr} ''${rem_args[@]} 2>/dev/null)"
    fi

    str="''${str/\(*\)}"; str="''${str/\[*\]}"; str="''${str#$'\n'}"; str="''${str#$'\n'}"
    str="''${str#*([[:space:]])}"; str="''${(u)str}"

    if [[ -z "''${DISPLAY}" ]] || [[ -z "''${XDG_CURRENT_DESKTOP}" ]]; then echo $str; exit 0; fi
    case "$wm" in
        "x11")
            if (( $PRIMESEL )); then echo $str | xsel -ip; (( $AUTOPASTE )) && xdotool click 2
            else echo $str | xsel -ib; (( $AUTOPASTE )) && xdotool key ctrl+v; fi ;;
        "wayland")
            if (( $PRIMESEL )); then echo $str | wl-copy -p; (( $AUTOPASTE )) && ydotool click 0xC2
            else echo $str | wl-copy; (( $AUTOPASTE )) && ydotool key 29:1 47:1 47:0 29:0; fi ;;
        *) echo $str ;;
    esac
  '';

  # blooper script (continuous dictation)
  blooperScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"
    pidof -q blooper && exit 0
    source $HOME/.local/bin/blahst.cfg
    (( $blahst_deps )) || blahst_depends

    while [ $# -gt 0 ]; do
        case "$1" in
            -w|--whisperfile) whf="$WHISPERFILE"; shift ;;
            -n|--netapi) IPnPORT="$WHOST:$WPORT"; shift ;;
            -h|--help) echo "Usage: $0 [-n|--netapi] [-w|--whisperfile]"; exit 0 ;;
            *) IPnPORT=$1; shift ;;
        esac
    done

    set -e
    silecount=0
    while [[ $silecount -lt 4 ]]; do
        rec -q -t wav $ramf rate 16k silence 1 0.1 1% 1 1.0 3% channels 1 2>/dev/null

        if [ -n "$IPnPORT" ]; then
            str=$(curl -S -s $IPnPORT/inference -H "Content-Type: multipart/form-data" -F file="@$ramf" -F temperature="0.0" -F temperature_inc="0.2" -F response_format="text")
        elif [[ "$whf" == *.llamafile ]]; then
            str="$($whf -t $NTHR -nt --gpu auto -f $ramf 2>/dev/null)"
        else
            str="$(transcribe -t $NTHR -nt -fa -m $WMODEL -f $ramf 2>/dev/null)"
        fi

        str="''${str/\(*\)}"; str="''${str/\[*\]}"; str="''${str#$'\n'}"; str="''${str#$'\n'}"
        [[ "''${#str}" -lt 4 ]] && { silecount=$((silecount + 1)); continue; } || silecount=0
        str="''${str#*([[:space:]])}"; str="''${(C)str:0:1}''${str#?}"

        case "$wm" in
            "x11") echo $str | xsel -ib; xdotool key ctrl+v ;;
            "wayland") echo $str | wl-copy; ydotool key 29:1 47:1 47:0 29:0 ;;
            *) echo $str ;;
        esac
    done
  '';

in {
  # Place all BlahST scripts in ~/.local/bin
  home.file = {
    ".local/bin/blahst.cfg".text = blahstConfig;
    ".local/bin/ptt-start" = { text = pttStartScript; executable = true; };
    ".local/bin/ptt-stop" = { text = pttStopScript; executable = true; };
    ".local/bin/ptt-stop-sanitize" = { text = pttStopSanitizeScript; executable = true; };
    ".local/bin/ptt-complete" = { text = pttCompleteScript; executable = true; };
    ".local/bin/wsi" = { text = wsiScript; executable = true; };
    ".local/bin/wsiml" = { text = wsimlScript; executable = true; };
    ".local/bin/blooper" = { text = blooperScript; executable = true; };
  };

  # Ensure ~/.local/bin is in PATH
  home.sessionPath = [ "$HOME/.local/bin" ];

  # ydotool daemon for input simulation (needed for paste on Wayland)
  systemd.user.services.ydotool = {
    Unit.Description = "ydotool daemon";
    Service = {
      ExecStart = "${pkgs.ydotool}/bin/ydotoold";
      Restart = "always";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # whisper-server for fast speech-to-text (keeps model in memory)
  systemd.user.services.whisper-server = {
    Unit = {
      Description = "whisper.cpp server for speech-to-text";
      After = [ "network.target" ];
    };
    Service = {
      Environment = "HOME=%h";
      ExecStart = "${pkgs.whisper-cpp}/bin/whisper-server -m %h/.ai/models/whisper/ggml-large-v3-turbo-q5_0.bin --host 127.0.0.1 --port 58080 -t 8";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # llama-server for fast LLM inference (keeps model in memory)
  systemd.user.services.llama-server = {
    Unit = {
      Description = "llama.cpp server for PTT text processing";
      After = [ "network.target" ];
    };
    Service = {
      Environment = "HOME=%h";
      ExecStart = "${pkgs.llama-cpp}/bin/llama-server -m %h/.ai/models/Qwen3-0.6B-Q8_0.gguf --host 127.0.0.1 --port 58090 -ngl 99 -c 4096 --jinja --temp 0.7 --top-p 0.8 --top-k 20 --min-p 0 --repeat-penalty 1.5";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Create symlinks to whisper.cpp binaries
  home.file.".local/bin/transcribe".source = "${pkgs.whisper-cpp}/bin/whisper-cli";
  home.file.".local/bin/whserver".source = "${pkgs.whisper-cpp}/bin/whisper-server";

  # Required packages for PTT scripts
  home.packages = with pkgs; [
    llama-cpp
    jq
    curl
    perl
  ];
}
