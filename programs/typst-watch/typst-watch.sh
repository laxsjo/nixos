#!/usr/bin/env bash

if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
Usage: typst-watch <file.typ> [typst-options...]

Watches a Typst file and opens the resulting PDF in Zathura side by side.
The terminal moves to the left half of the screen, Zathura to the right.
Taskbar height is taken into account. Ctrl-C closes both typst and Zathura.
EOF
    exit 0
fi

INPUT="$1"
shift

if [[ ! -f "$INPUT" ]]; then
    echo "Error: '$INPUT' not found." >&2
    exit 1
fi

OUTPUT="${INPUT%.typ}.pdf"

# Query the available work area from KDE (excludes taskbar/panels)
SCREEN=$(qdbus org.kde.KWin /KWin org.kde.KWin.activeOutputName)
RECT=$(qdbus --literal org.kde.plasmashell /StrutManager \
    org.kde.PlasmaShell.StrutManager.availableScreenRect "$SCREEN")
# RECT format: [Argument: (iiii) x, y, width, height]
WA_X=$(echo "$RECT" | grep -oP '\d+' | sed -n '1p')
WA_Y=$(echo "$RECT" | grep -oP '\d+' | sed -n '2p')
WA_W=$(echo "$RECT" | grep -oP '\d+' | sed -n '3p')
WA_H=$(echo "$RECT" | grep -oP '\d+' | sed -n '4p')

HALF_W=$((WA_W / 2))

# Move the current terminal window to the left half before starting anything
TERM_WIN=$(kdotool getactivewindow)
kdotool windowsize "$TERM_WIN" "$HALF_W" "$WA_H"
kdotool windowmove "$TERM_WIN" "$WA_X" "$WA_Y"

TYPST_PID=
ZATHURA_PID=

cleanup() {
    [[ -n "$TYPST_PID" ]] && kill "$TYPST_PID" 2>/dev/null
    [[ -n "$ZATHURA_PID" ]] && kill "$ZATHURA_PID" 2>/dev/null
    exit 0
}
trap cleanup INT TERM

typst watch "$INPUT" "$@" &
TYPST_PID=$!

# Wait for the initial compile to produce a PDF
echo "Compiling '$INPUT'..."
while [[ ! -f "$OUTPUT" ]]; do
    sleep 0.1
    if ! kill -0 "$TYPST_PID" 2>/dev/null; then
        echo "Error: typst watch exited before producing output." >&2
        exit 1
    fi
done

# Snapshot existing Zathura window IDs before launching a new one
BEFORE=$(kdotool search --class zathura 2>/dev/null || true)

zathura "$OUTPUT" &
ZATHURA_PID=$!

# Poll for the new Zathura window (up to 10 seconds)
ZATHURA_WIN=
for ((i = 0; i < 100; i++)); do
    sleep 0.1
    while IFS= read -r win; do
        [[ -z "$win" ]] && continue
        if ! grep -qxF "$win" <<< "$BEFORE"; then
            ZATHURA_WIN=$win
            break 2
        fi
    done < <(kdotool search --class zathura 2>/dev/null || true)
done

if [[ -n "$ZATHURA_WIN" ]]; then
    # Poll until KDE accepts the windowmove (rejected during window initialization)
    TARGET_X=$((WA_X + HALF_W))
    PLACED=false
    for ((attempt = 0; attempt < 100; attempt++)); do
        sleep 0.1
        kdotool windowsize "$ZATHURA_WIN" "$HALF_W" "$WA_H" 2>/dev/null
        kdotool windowmove "$ZATHURA_WIN" "$TARGET_X" "$WA_Y" 2>/dev/null
        POS=$(kdotool getwindowgeometry "$ZATHURA_WIN" 2>/dev/null \
            | grep "Position:" | grep -oP '\d+,\d+')
        if [[ "$POS" == "${TARGET_X},${WA_Y}" ]]; then
            PLACED=true
            break
        fi
    done
    $PLACED || echo "Warning: could not position Zathura window." >&2
else
    echo "Warning: could not locate Zathura window to reposition." >&2
fi

# Block until Zathura closes, then kill typst and exit
wait "$ZATHURA_PID"
cleanup
