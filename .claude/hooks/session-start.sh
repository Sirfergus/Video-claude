#!/bin/bash
# Install HyperFrames video tooling in Claude Code cloud sessions.
set -uo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

HF_VERSION=0.8.134
LOG="$HOME/.cache/hyperframes/session-start.log"
mkdir -p "$(dirname "$LOG")"

# HyperFrames CLI + headless Chrome for rendering.
command -v hyperframes >/dev/null 2>&1 || npm install -g "hyperframes@$HF_VERSION" >>"$LOG" 2>&1
hyperframes browser ensure >>"$LOG" 2>&1

# Kokoro local text-to-speech (voice files download from GitHub on first use).
python3 -c "import kokoro_onnx, soundfile" 2>/dev/null \
  || pip install -q kokoro-onnx soundfile >>"$LOG" 2>&1

# whisper.cpp for transcription/captions, built where HyperFrames looks for it.
# Takes ~2 minutes, so run in the background.
WHISPER_DIR="$HOME/.cache/hyperframes/whisper/whisper.cpp"
if [ ! -x "$WHISPER_DIR/build/bin/whisper-cli" ]; then
  nohup bash -c "
    rm -rf '$WHISPER_DIR' &&
    git clone -q --depth 1 https://github.com/ggml-org/whisper.cpp '$WHISPER_DIR' &&
    cd '$WHISPER_DIR' &&
    cmake -B build -DCMAKE_BUILD_TYPE=Release &&
    cmake --build build --config Release -j\$(nproc) --target whisper-cli
  " >>"$LOG" 2>&1 &
fi

exit 0
