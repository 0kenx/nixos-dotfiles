{ pkgs, lib, hostHardwareFlags ? {}, ... }:

# BlahST - Speech-to-Text input tool for Linux
# https://github.com/QuantiusBenignus/BlahST
# All scripts embedded directly for fully declarative NixOS setup

let
  # Detect GPU availability for CUDA-accelerated whisper
  hasNvidia = hostHardwareFlags.hasNvidia or false;
  whisperPackage = if hasNvidia
    then pkgs.whisper-cpp.override { cudaSupport = true; }
    else pkgs.whisper-cpp;
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

    # PTT-specific configuration (can be overridden via environment variables)
    # PTT_MIN_SIZE: Minimum audio file size in bytes to consider valid (default: 8192)
    # PTT_TRANSCRIBE_TIMEOUT: Timeout for transcription API calls (default: 30s)
    # PTT_LLM_TIMEOUT: Timeout for LLM API calls (default: 15s)
    # Audio files are kept in /dev/shm/wfile for debugging - check with: mpv /dev/shm/wfile

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

  # Push-to-talk: start recording (toggle behavior)
  pttStartScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"

    # Source config with error handling
    if [[ ! -f "$HOME/.local/bin/blahst.cfg" ]]; then
        notify-send -t 3000 "PTT Error" "Configuration file not found"
        exit 1
    fi
    source $HOME/.local/bin/blahst.cfg

    # Toggle: if already recording, stop and transcribe
    if [[ -f /tmp/ptt-rec.pid ]]; then
        pid=$(cat /tmp/ptt-rec.pid 2>/dev/null)
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            exec ptt-stop
        fi
    fi

    # Clean up any stale state more thoroughly
    pkill -TERM -f "rec.*$ramf" 2>/dev/null
    sleep 0.1
    pkill -KILL -f "rec.*$ramf" 2>/dev/null
    rm -f "$ramf" /tmp/ptt-rec.pid 2>/dev/null

    # Ensure temp directory exists
    mkdir -p "$TEMPD" 2>/dev/null || {
        notify-send -t 3000 "PTT Error" "Cannot create temp directory: $TEMPD"
        exit 1
    }

    # Start recording in background
    rec -q -t wav "$ramf" rate 16k channels 1 2>/dev/null &
    rec_pid=$!

    # Save PID immediately
    echo $rec_pid > /tmp/ptt-rec.pid

    # Verify recording process started successfully
    sleep 0.3
    if ! kill -0 "$rec_pid" 2>/dev/null; then
        notify-send -t 3000 "PTT Error" "Failed to start recording (no audio device?)"
        rm -f /tmp/ptt-rec.pid
        exit 1
    fi

    # Persistent notification (0 = no timeout, stays until dismissed)
    notify-send -t 0 -h string:x-canonical-private-synchronous:ptt "Recording..." "Press Super+T to stop and transcribe"
  '';

  # Push-to-talk: stop recording and transcribe
  pttStopScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"
    export YDOTOOL_SOCKET="/run/user/$(id -u)/.ydotool_socket"

    # Source config with error handling
    if [[ ! -f "$HOME/.local/bin/blahst.cfg" ]]; then
        notify-send -t 3000 "PTT Error" "Configuration file not found"
        exit 1
    fi
    source $HOME/.local/bin/blahst.cfg

    MIN_AUDIO_SIZE=''${PTT_MIN_SIZE:-8192}

    # Stop recording gracefully - send SIGINT to rec process
    # rec (sox) handles SIGINT by flushing buffers and finalizing the WAV file
    recording_stopped=false
    if [[ -f /tmp/ptt-rec.pid ]]; then
        pid=$(cat /tmp/ptt-rec.pid 2>/dev/null)
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            kill -INT "$pid" 2>/dev/null

            # Wait for process to exit and finalize file
            for i in {1..50}; do
                if ! kill -0 "$pid" 2>/dev/null; then
                    recording_stopped=true
                    break
                fi
                sleep 0.1
            done

            # Force kill if graceful shutdown fails
            if ! $recording_stopped; then
                kill -KILL "$pid" 2>/dev/null
                sleep 0.2
            fi
        fi
        rm -f /tmp/ptt-rec.pid
    fi

    # Fallback: ensure no stray recording processes
    pkill -INT -f "rec.*$ramf" 2>/dev/null
    sleep 0.5
    pkill -KILL -f "rec.*$ramf" 2>/dev/null

    # Dismiss recording notification by replacing it
    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Processing..."

    # Check if audio file exists and has content
    if [[ ! -f "$ramf" ]]; then
        notify-send -t 2000 "PTT Error" "No audio file created"
        exit 1
    fi

    # Verify audio file size (must be at least MIN_AUDIO_SIZE bytes)
    audio_size=$(stat -c%s "$ramf" 2>/dev/null || echo "0")
    if [[ $audio_size -lt $MIN_AUDIO_SIZE ]]; then
        rm -f "$ramf"
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(recording too short)"
        exit 0
    fi

    # Transcribe and type progressively (streams chunks as they're ready)
    full_text=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        [[ -n "$full_text" ]] && line=" $line"
        full_text="$full_text$line"
        ydotool type --key-delay 0 -- "$line" 2>/dev/null || {
            echo -n "$line" | wl-copy 2>/dev/null
        }
    done < <(ptt-transcribe "$ramf")

    if [[ -z "$full_text" ]]; then
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(no speech detected)"
        exit 0
    fi

    notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "Voice Input" "$full_text"
  '';

  # Push-to-talk: stop recording, transcribe, and sanitize (remove stutters, filler words, etc.)
  pttStopSanitizeScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"
    export YDOTOOL_SOCKET="/run/user/$(id -u)/.ydotool_socket"

    # Source config with error handling
    if [[ ! -f "$HOME/.local/bin/blahst.cfg" ]]; then
        notify-send -t 3000 "PTT Error" "Configuration file not found"
        exit 1
    fi
    source $HOME/.local/bin/blahst.cfg

    MIN_AUDIO_SIZE=''${PTT_MIN_SIZE:-8192}
    LLM_TIMEOUT=''${PTT_LLM_TIMEOUT:-15}

    # Stop recording gracefully - send SIGINT to rec process
    # rec (sox) handles SIGINT by flushing buffers and finalizing the WAV file
    recording_stopped=false
    if [[ -f /tmp/ptt-rec.pid ]]; then
        pid=$(cat /tmp/ptt-rec.pid 2>/dev/null)
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            kill -INT "$pid" 2>/dev/null

            # Wait for process to exit and finalize file
            for i in {1..50}; do
                if ! kill -0 "$pid" 2>/dev/null; then
                    recording_stopped=true
                    break
                fi
                sleep 0.1
            done

            # Force kill if graceful shutdown fails
            if ! $recording_stopped; then
                kill -KILL "$pid" 2>/dev/null
                sleep 0.2
            fi
        fi
        rm -f /tmp/ptt-rec.pid
    fi

    # Fallback: ensure no stray recording processes
    pkill -INT -f "rec.*$ramf" 2>/dev/null
    sleep 0.5
    pkill -KILL -f "rec.*$ramf" 2>/dev/null

    # Dismiss recording notification by replacing it
    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Processing..."

    # Check if audio file exists and has content
    if [[ ! -f "$ramf" ]]; then
        notify-send -t 2000 "PTT Error" "No audio file created"
        exit 1
    fi

    # Verify audio file size
    audio_size=$(stat -c%s "$ramf" 2>/dev/null || echo "0")
    if [[ $audio_size -lt $MIN_AUDIO_SIZE ]]; then
        rm -f "$ramf"
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(recording too short)"
        exit 0
    fi

    # Transcribe (handles chunking for >30s recordings)
    str=$(ptt-transcribe "$ramf")
    str="''${str//$'\n'/ }"

    if [[ -z "$str" ]]; then
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(no speech detected)"
        exit 0
    fi

    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Sanitizing..."

    # Check if llama-server is running with better timeout
    if ! curl -s --connect-timeout 2 --max-time 5 "http://$LHOST:$LPORT/health" >/dev/null 2>&1; then
        notify-send -t 3000 -h string:x-canonical-private-synchronous:ptt "PTT Warning" "LLM server unavailable, using raw transcription"
        if ! ydotool type --key-delay 0 -- "$str" 2>/dev/null; then
            echo -n "$str" | wl-copy 2>/dev/null || true
            notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "Voice Input (copied)" "$str"
        else
            notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "Voice Input" "$str"
        fi
        exit 0
    fi

    # Use LLM server to clean up verbal stutters, filler words, repetitions
    cleaned=$(curl -s --max-time $LLM_TIMEOUT "http://$LHOST:$LPORT/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg text "$str" '{
            model: "qwen",
            max_tokens: 256,
            temperature: 0.3,
            messages: [
                {role: "system", content: "You are a text cleaner. Remove filler words (uh, um, er, like, you know), stutters, repeated words, and false starts. Output ONLY the cleaned text. Never add explanations or extra content. /no_think"},
                {role: "user", content: $text}
            ]
        }')" 2>/dev/null \
        | jq -r '.choices[0].message.content // empty' 2>/dev/null \
        | perl -0777 -pe 's/<think>.*?<\/think>//gs' 2>/dev/null \
        | tr '\n' ' ' \
        | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/  */ /g')

    # Fall back to original if LLM fails or returns empty
    if [[ -z "$cleaned" ]]; then
        cleaned="$str"
        notify_type="Voice Input (raw)"
    else
        notify_type="Voice Input (Sanitized)"
    fi

    # Strip leading/trailing whitespace
    cleaned=$(echo "$cleaned" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Type the text with error handling
    if ! ydotool type --key-delay 0 -- "$cleaned" 2>/dev/null; then
        echo -n "$cleaned" | wl-copy 2>/dev/null || true
        notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "$notify_type (copied)" "$cleaned"
    else
        notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "$notify_type" "$cleaned"
    fi
  '';

  # Push-to-talk: stop recording, transcribe, and complete (rewrite professionally)
  pttCompleteScript = ''
    #!/usr/bin/env zsh
    export PATH="$HOME/.local/bin:$PATH"
    export YDOTOOL_SOCKET="/run/user/$(id -u)/.ydotool_socket"

    # Source config with error handling
    if [[ ! -f "$HOME/.local/bin/blahst.cfg" ]]; then
        notify-send -t 3000 "PTT Error" "Configuration file not found"
        exit 1
    fi
    source $HOME/.local/bin/blahst.cfg

    MIN_AUDIO_SIZE=''${PTT_MIN_SIZE:-8192}
    LLM_TIMEOUT=''${PTT_LLM_TIMEOUT:-15}

    # Stop recording gracefully - send SIGINT to rec process
    # rec (sox) handles SIGINT by flushing buffers and finalizing the WAV file
    recording_stopped=false
    if [[ -f /tmp/ptt-rec.pid ]]; then
        pid=$(cat /tmp/ptt-rec.pid 2>/dev/null)
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            kill -INT "$pid" 2>/dev/null

            # Wait for process to exit and finalize file
            for i in {1..50}; do
                if ! kill -0 "$pid" 2>/dev/null; then
                    recording_stopped=true
                    break
                fi
                sleep 0.1
            done

            # Force kill if graceful shutdown fails
            if ! $recording_stopped; then
                kill -KILL "$pid" 2>/dev/null
                sleep 0.2
            fi
        fi
        rm -f /tmp/ptt-rec.pid
    fi

    # Fallback: ensure no stray recording processes
    pkill -INT -f "rec.*$ramf" 2>/dev/null
    sleep 0.5
    pkill -KILL -f "rec.*$ramf" 2>/dev/null

    # Dismiss recording notification by replacing it
    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Processing..."

    # Check if audio file exists and has content
    if [[ ! -f "$ramf" ]]; then
        notify-send -t 2000 "PTT Error" "No audio file created"
        exit 1
    fi

    # Verify audio file size
    audio_size=$(stat -c%s "$ramf" 2>/dev/null || echo "0")
    if [[ $audio_size -lt $MIN_AUDIO_SIZE ]]; then
        rm -f "$ramf"
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(recording too short)"
        exit 0
    fi

    # Transcribe (handles chunking for >30s recordings)
    str=$(ptt-transcribe "$ramf")
    str="''${str//$'\n'/ }"

    if [[ -z "$str" ]]; then
        notify-send -t 2000 -h string:x-canonical-private-synchronous:ptt "PTT" "(no speech detected)"
        exit 0
    fi

    notify-send -t 1 -h string:x-canonical-private-synchronous:ptt "Rewriting..."

    # Check if llama-server is running with better timeout
    if ! curl -s --connect-timeout 2 --max-time 5 "http://$LHOST:$LPORT/health" >/dev/null 2>&1; then
        notify-send -t 3000 -h string:x-canonical-private-synchronous:ptt "PTT Warning" "LLM server unavailable, using raw transcription"
        if ! ydotool type --key-delay 0 -- "$str" 2>/dev/null; then
            echo -n "$str" | wl-copy 2>/dev/null || true
            notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "Voice Input (copied)" "$str"
        else
            notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "Voice Input" "$str"
        fi
        exit 0
    fi

    # Use LLM server to rewrite the text professionally
    rewritten=$(curl -s --max-time $LLM_TIMEOUT "http://$LHOST:$LPORT/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg text "$str" '{
            model: "qwen",
            max_tokens: 256,
            temperature: 0.3,
            messages: [
                {role: "system", content: "You are a text editor. Rewrite the input to be clear, professional, and grammatically correct. Preserve the original meaning. Output ONLY the rewritten text. Never add explanations or extra content. /no_think"},
                {role: "user", content: $text}
            ]
        }')" 2>/dev/null \
        | jq -r '.choices[0].message.content // empty' 2>/dev/null \
        | perl -0777 -pe 's/<think>.*?<\/think>//gs' 2>/dev/null \
        | tr '\n' ' ' \
        | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/  */ /g')

    # Fall back to original if LLM fails or returns empty
    if [[ -z "$rewritten" ]]; then
        rewritten="$str"
        notify_type="Voice Input (raw)"
    else
        notify_type="Voice Input (Rewritten)"
    fi

    # Strip leading/trailing whitespace
    rewritten=$(echo "$rewritten" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Type the text with error handling
    if ! ydotool type --key-delay 0 -- "$rewritten" 2>/dev/null; then
        echo -n "$rewritten" | wl-copy 2>/dev/null || true
        notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "$notify_type (copied)" "$rewritten"
    else
        notify-send -t 4000 -h string:x-canonical-private-synchronous:ptt "$notify_type" "$rewritten"
    fi
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

  # Shared transcription helper - handles chunking for recordings >30s
  pttTranscribeScript = ''
    #!/usr/bin/env zsh
    # Transcribe audio file, chunking with overlap for recordings >30s
    # Usage: ptt-transcribe <audio_file>
    # Outputs transcribed text to stdout (empty if no speech detected)

    export PATH="$HOME/.local/bin:$PATH"
    source $HOME/.local/bin/blahst.cfg

    audio_file="$1"
    [[ -f "$audio_file" ]] || exit 1

    transcribe_timeout=''${PTT_TRANSCRIBE_TIMEOUT:-30}

    # Transcribe a single audio chunk via whisper-server or CLI fallback
    transcribe_one() {
        local f="$1"
        local result=""

        if curl -s --connect-timeout 2 --max-time 5 "http://$WHOST:$WPORT/health" >/dev/null 2>&1; then
            result=$(curl -s --max-time $transcribe_timeout "http://$WHOST:$WPORT/inference" \
                -H "Content-Type: multipart/form-data" \
                -F file="@$f" \
                -F temperature="0.0" \
                -F response_format="text" 2>/dev/null)
            if [[ -z "$result" || "$result" == "error"* ]]; then
                result="$(transcribe -t $NTHR -nt -m $WMODEL -f $f 2>/dev/null)"
            fi
        else
            result="$(transcribe -t $NTHR -nt -m $WMODEL -f $f 2>/dev/null)"
        fi

        echo "$result"
    }

    # Clean raw transcription output
    clean_text() {
        local t="$1"
        t=$(echo "$t" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        t="''${t//$'\n'/ }"
        t="''${t//$'\r'/}"
        [[ "$t" == *"[BLANK_AUDIO]"* ]] && t=""
        echo "$t"
    }

    duration=$(soxi -D "$audio_file" 2>/dev/null)
    [[ -z "$duration" ]] && exit 1

    if (( duration <= 30.0 )); then
        # Short recording: pad with silence and transcribe directly
        padded="$TEMPD/wfile_padded.wav"
        sox "$audio_file" "$padded" pad 0 3 2>/dev/null && mv "$padded" "$audio_file"
        clean_text "$(transcribe_one "$audio_file")"
    else
        # Long recording: split into 27s chunks with 3s overlap
        # Pipeline: output each chunk as it's transcribed, start next in background
        chunk_dur=27
        overlap=3
        step=$((chunk_dur - overlap))

        typeset -a chunk_files=()
        offset=0
        idx=0

        while (( offset < duration )); do
            cf="$TEMPD/wchunk_''${idx}.wav"
            sox "$audio_file" "$cf" trim $offset $chunk_dur pad 0 3 2>/dev/null
            chunk_files+=("$cf")
            offset=$((offset + step))
            idx=$((idx + 1))
        done

        prev_text=""
        bg_pid=""
        bg_result="$TEMPD/wchunk_bg_result"

        for (( i=1; i<=''${#chunk_files}; i++ )); do
            # Get current chunk's transcription
            if [[ -n "$bg_pid" ]]; then
                wait $bg_pid 2>/dev/null
                curr_text=$(cat "$bg_result" 2>/dev/null)
                bg_pid=""
            else
                curr_text=$(clean_text "$(transcribe_one "''${chunk_files[$i]}")")
            fi

            # Start next chunk transcription in background immediately
            if (( i < ''${#chunk_files} )); then
                ( clean_text "$(transcribe_one "''${chunk_files[$((i+1))]}")" > "$bg_result" ) &
                bg_pid=$!
            fi

            rm -f "''${chunk_files[$i]}"

            # Trim overlap from start of current chunk
            if [[ -n "$prev_text" && -n "$curr_text" ]]; then
                typeset -a prev_words=(''${(s: :)prev_text})
                typeset -a next_words=(''${(s: :)curr_text})

                best=0
                max_check=''${#prev_words}
                (( max_check > 25 )) && max_check=25
                (( max_check > ''${#next_words} )) && max_check=''${#next_words}

                for (( n=1; n<=max_check; n++ )); do
                    suffix="''${(L)''${(j: :)prev_words[-$n,-1]}}"
                    prefix="''${(L)''${(j: :)next_words[1,$n]}}"
                    [[ "$suffix" == "$prefix" ]] && best=$n
                done

                if (( best > 0 )); then
                    output="''${next_words[$((best+1)),-1]}"
                else
                    output="$curr_text"
                fi
            else
                output="$curr_text"
            fi

            # Output this chunk's text immediately
            [[ -n "$output" ]] && echo "$output"

            prev_text="$curr_text"
        done

        rm -f "$bg_result"
    fi
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
    ".local/bin/ptt-transcribe" = { text = pttTranscribeScript; executable = true; };
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
  # Uses CUDA-accelerated whisper.cpp when Nvidia GPU is available
  systemd.user.services.whisper-server = {
    Unit = {
      Description = "whisper.cpp server for speech-to-text";
      After = [ "network.target" ];
    };
    Service = {
      Environment = "HOME=%h";
      # GPU is used automatically when whisper-cpp is built with CUDA support
      ExecStart = "${whisperPackage}/bin/whisper-server -m %h/.ai/models/whisper/ggml-large-v3-turbo-q5_0.bin --host 127.0.0.1 --port 58080 -t 8";
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

  # Create symlinks to whisper.cpp binaries (GPU-accelerated when available)
  home.file.".local/bin/transcribe".source = "${whisperPackage}/bin/whisper-cli";
  home.file.".local/bin/whserver".source = "${whisperPackage}/bin/whisper-server";

  # Required packages for PTT scripts
  home.packages = with pkgs; [
    sox              # Provides 'rec' command for audio recording
    wl-clipboard     # Provides 'wl-copy' for clipboard fallback
    llama-cpp
    jq
    curl
    perl
  ];
}
