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

    AI="$HOME/AI/Models"
    WMODEL=''${WHISPER_DMODEL:-"$AI/whisper/ggml-base.en.bin"}

    LHOST="127.0.0.1"
    LPORT="58090"
    LLMODEL="$AI/gemma-3-4b-it-Q6_K_L.gguf"
    LIGHTLMODEL="$AI/gemma-3-1b-it-Q6_K_L.gguf"
    HEAVYMODEL="$AI/gemma-3-27b-it-IQ3_XXS.gguf"
    CODEMODEL="$AI/Qwen2.5-Coder-14B-Instruct-Q5_K_L.gguf"
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

    # Transcribe
    str="$(transcribe -t $NTHR -nt -m $WMODEL -f $ramf 2>/dev/null)"

    # Clean up audio file for next use
    rm -f "$ramf"

    # Trim whitespace and remove line breaks
    str="''${str##[[:space:]]#}"
    str="''${str%%[[:space:]]#}"
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

    # Transcribe
    str="$(transcribe -t $NTHR -nt -m $WMODEL -f $ramf 2>/dev/null)"

    # Clean up audio file for next use
    rm -f "$ramf"

    # Trim whitespace and remove line breaks
    str="''${str##[[:space:]]#}"
    str="''${str%%[[:space:]]#}"
    str="''${str//$'\n'/ }"
    str="''${str//$'\r'/}"

    # Skip if empty or just noise markers
    if [[ -z "$str" || "$str" == *"[BLANK_AUDIO]"* ]]; then
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(no speech detected)"
        exit 0
    fi

    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Sanitizing..."

    # Use LLM to clean up verbal stutters, filler words, repetitions
    cleaned=$(llama-cli -m "$LIGHTLMODEL" -ngl 99 -c 2048 -n 512 --temp 0.1 -p "Clean up this transcribed speech by removing verbal stutters (like 'uh', 'um', 'er'), repeated words, false starts, and filler phrases. Keep the original meaning and wording intact - only remove the speech disfluencies. Output ONLY the cleaned text with no explanation or commentary:

$str" 2>/dev/null | tail -n +2)

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

    # Transcribe
    str="$(transcribe -t $NTHR -nt -m $WMODEL -f $ramf 2>/dev/null)"

    # Clean up audio file for next use
    rm -f "$ramf"

    # Trim whitespace and remove line breaks
    str="''${str##[[:space:]]#}"
    str="''${str%%[[:space:]]#}"
    str="''${str//$'\n'/ }"
    str="''${str//$'\r'/}"

    # Skip if empty or just noise markers
    if [[ -z "$str" || "$str" == *"[BLANK_AUDIO]"* ]]; then
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(no speech detected)"
        exit 0
    fi

    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Rewriting..."

    # Use LLM to rewrite the text professionally
    rewritten=$(llama-cli -m "$LLMODEL" -ngl 99 -c 2048 -n 512 --temp 0.3 -p "Rewrite this transcribed speech into clear, professional, and well-structured text. Fix grammar, improve clarity, and make it sound polished while preserving the original meaning and intent. Output ONLY the rewritten text with no explanation or commentary:

$str" 2>/dev/null | tail -n +2)

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

  # Create symlinks to whisper.cpp binaries
  home.file.".local/bin/transcribe".source = "${pkgs.whisper-cpp}/bin/whisper-cli";
  home.file.".local/bin/whserver".source = "${pkgs.whisper-cpp}/bin/whisper-server";
}
