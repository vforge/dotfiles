#!/bin/zsh
# tty-reset — fix a corrupted terminal (Ctrl-C, scroll, PageUp/down broken)
# Usage: tty-reset

printf '\ec'  # Full terminal reset
stty sane     # Restore line discipline settings

echo "Terminal reset."
