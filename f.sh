#!/usr/bin/env bash
# f.sh — ASCII F with matrix/glitch animation
# GitHub'a koy, sonra:
#   curl -fsSL https://raw.githubusercontent.com/KULLANICI/REPO/main/f.sh | bash
# ya da alias ekle ~/.zshrc veya ~/.bashrc'e:
#   alias f='bash <(curl -fsSL https://raw.githubusercontent.com/KULLANICI/REPO/main/f.sh)'

# ─── Terminal boyutunu al ───────────────────────────────────
COLS=$(tput cols 2>/dev/null || echo 80)
ROWS=$(tput lines 2>/dev/null || echo 24)

# ─── Renkler ───────────────────────────────────────────────
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
BLINK='\033[5m'
RESET='\033[0m'

# Matrix yeşilleri
M0='\033[0;32m'   # koyu yeşil
M1='\033[1;32m'   # parlak yeşil
M2='\033[0;36m'   # cyan

# ─── Cursor gizle/göster ───────────────────────────────────
hide_cursor() { tput civis 2>/dev/null; }
show_cursor() { tput cnorm 2>/dev/null; }
clear_screen() { tput clear 2>/dev/null || printf '\033[2J\033[H'; }
move_to()     { tput cup "$1" "$2" 2>/dev/null; }  # row col

# ─── Cleanup trap ──────────────────────────────────────────
cleanup() {
  show_cursor
  tput rmcup 2>/dev/null
  exit 0
}
trap cleanup INT TERM EXIT

# ─── Alt ekran buffer ──────────────────────────────────────
tput smcup 2>/dev/null

hide_cursor
clear_screen

# ─── F harfi (büyük ASCII art, 9 satır) ───────────────────
F_ART=(
  "███████╗"
  "██╔════╝"
  "█████╗  "
  "██╔══╝  "
  "██║     "
  "██║     "
  "╚═╝     "
)

F_WIDTH=8
F_HEIGHT=${#F_ART[@]}

# F'i ortala
START_ROW=$(( (ROWS - F_HEIGHT) / 2 ))
START_COL=$(( (COLS - F_WIDTH) / 2 ))

# ─── Matrix karakter seti ──────────────────────────────────
MATRIX_CHARS='ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789'
MLEN=${#MATRIX_CHARS}

rand_char() {
  local idx=$(( RANDOM % MLEN ))
  echo "${MATRIX_CHARS:$idx:1}"
}

rand_color() {
  local r=$(( RANDOM % 3 ))
  case $r in
    0) echo "$M0" ;;
    1) echo "$M1" ;;
    2) echo "$M2" ;;
  esac
}

# ─── FAZI 1: Matrix yağmuru (1.5 sn) ─────────────────────
matrix_rain() {
  local duration=20  # frame sayısı
  for ((frame=0; frame<duration; frame++)); do
    # Her frame'de 15 rastgele karakter bas
    for ((drop=0; drop<15; drop++)); do
      local row=$(( RANDOM % ROWS ))
      local col=$(( RANDOM % COLS ))
      local ch
      ch=$(rand_char)
      local color
      color=$(rand_color)
      move_to $row $col
      printf "${color}${ch}${RESET}"
    done
    sleep 0.07
  done
}

# ─── FAZI 2: Glitch efekti — F harfini gürültüyle bas ─────
glitch_reveal() {
  local passes=12
  for ((p=0; p<passes; p++)); do
    for ((i=0; i<F_HEIGHT; i++)); do
      local row=$(( START_ROW + i ))
      move_to $row $START_COL

      if (( p < 6 )); then
        # Glitch: gerçek harfle rastgele karış
        local line="${F_ART[$i]}"
        local out=""
        for ((c=0; c<${#line}; c++)); do
          if (( RANDOM % 3 == 0 )); then
            local gc
            gc=$(rand_char)
            out+="${M0}${gc}"
          else
            out+="${M1}${line:$c:1}"
          fi
        done
        printf "${out}${RESET}"
      else
        # Son passlar: temiz F
        local intensity=$(( p - 5 ))
        if (( intensity >= 3 )); then
          printf "${WHITE}${BOLD}${F_ART[$i]}${RESET}"
        else
          printf "${M1}${F_ART[$i]}${RESET}"
        fi
      fi
    done
    sleep 0.06
  done
}

# ─── FAZI 3: F'in scan-line ile parlayıp sabitlenmesi ─────
scanline_finalize() {
  local colors=("$CYAN" "$M2" "$M1" "$WHITE" "$WHITE")
  for color in "${colors[@]}"; do
    for ((i=0; i<F_HEIGHT; i++)); do
      local row=$(( START_ROW + i ))
      move_to $row $START_COL
      printf "${color}${BOLD}${F_ART[$i]}${RESET}"
    done
    sleep 0.08
  done
}

# ─── FAZI 4: Alt yazı ─────────────────────────────────────
show_subtitle() {
  local msg="[ press any key to exit ]"
  local msg_col=$(( (COLS - ${#msg}) / 2 ))
  local msg_row=$(( START_ROW + F_HEIGHT + 2 ))
  move_to $msg_row $msg_col
  printf "${DIM}${msg}${RESET}"
}

# ─── ANIMASYONU ÇALIŞTIR ───────────────────────────────────
matrix_rain
glitch_reveal
scanline_finalize
show_subtitle

# ─── Tuşa basılana kadar bekle ─────────────────────────────
old_stty=$(stty -g 2>/dev/null)
stty -echo -icanon time 0 min 0 2>/dev/null
read -r -n1 -s 2>/dev/null || true
stty "$old_stty" 2>/dev/null
