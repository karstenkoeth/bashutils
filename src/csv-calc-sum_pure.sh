#!/bin/bash
# ------------------------------------------------------------------
# zahlsumme.sh – Summe ganzer Zahlen aus einer CSV-Spalte
#
# Aufruf:   ./zahlsumme.sh <datei.csv> <trennzeichen> <spalte>
# Beispiel: ./zahlsumme.sh Liste.csv ";" 3
#           -> 1234
# Einen Tabulator als Trennzeichen gibst du als "\t" an.
#
# - Spaltenzählung beginnt bei 1.
# - Erlaubt sind ganze Zahlen, auch mit Vorzeichen (z. B. -12, +7).
# - Zeilen, deren Feld keine ganze Zahl enthält (z. B. die
#   Kopfzeile, leere Felder, 3,5 oder 1.000), werden übersprungen.
# - Anführungszeichen um das Feld werden entfernt.
# ------------------------------------------------------------------

set -euo pipefail

if [ $# -ne 3 ]; then
  echo "Aufruf: $0 <datei.csv> <trennzeichen> <spalte>" >&2
  exit 1
fi

datei="$1"
trenner="$2"
spalte="$3"

if [ ! -f "$datei" ]; then
  echo "Datei nicht gefunden: $datei" >&2
  exit 1
fi

case "$spalte" in
  ''|*[!0-9]*|0) echo "Spalte muss eine Zahl ab 1 sein: $spalte" >&2; exit 1 ;;
esac

tr -d '\r' < "$datei" | awk -v t="$trenner" -v s="$spalte" '
  {
    if (NR == 1) sub(/^\xEF\xBB\xBF/, "")          # UTF-8-Kennung entfernen
    anzahl = split($0, feld, t)
    if (s > anzahl) next
    w = feld[s]
    gsub(/^[ \t"]+|[ \t"]+$/, "", w)
    if (w !~ /^[+-]?[0-9]+$/) next
    summe += w
  }
  END { printf "%.0f\n", summe }
'
