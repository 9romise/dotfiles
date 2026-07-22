#!/bin/bash
set -euo pipefail

DOTFILES="$HOME/Documents/GitHub/dotfiles"
MODE="${1:-help}"

BOLD=$(tput bold)
DIM=$(tput dim)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NC=$(tput sgr0)

pairs=(
  ".zshrc"
  ".zprofile"
  ".gitconfig"
  ".config/ghostty/config"
  ".config/mise/config.toml"
  ".config/AGENTS.md"
  ".config/starship.toml"
  ".cargo/config.toml"
  "Library/Developer/Xcode/UserData/KeyBindings/vscode.idekeybindings"
)

repo_path() { echo "$DOTFILES/$1"; }
home_path() { echo "$HOME/$1"; }
dir_of()    { dirname "$(home_path "$1")"; }

pick_files() {
  local label="$1"
  local n=${#pairs[@]}
  local sel=()
  local i
  for ((i=0; i<n; i++)); do sel[$i]="0"; done

  # calc box width
  local max=0 len
  for f in "${pairs[@]}"; do
    len=${#f}
    [ "$len" -gt "$max" ] && max=$len
  done
  local lbl_len=${#label}
  local hint="↑↓ move  space select  enter confirm"
  local hint_len=${#hint}
  local box_w=$(( max + 6 ))
  [ "$box_w" -lt "$((lbl_len + 2))" ] && box_w=$((lbl_len + 2))
  [ "$box_w" -lt "$((hint_len + 2))" ] && box_w=$((hint_len + 2))

  local cur=0 key
  local hide_cursor=$(tput civis 2>/dev/null || echo "")
  local show_cursor=$(tput cnorm 2>/dev/null || echo "")

  printf "\n${BOLD}%s${NC}\n" "$label"
  printf "${DIM}↑↓ move  space select  enter confirm${NC}\n"
  printf "%s" "$hide_cursor"

  while true; do
    for ((i=0; i<n; i++)); do
      if [ "$i" -eq "$cur" ]; then
        printf "${CYAN}${BOLD}▸${NC}"
      else
        printf " "
      fi
      if [ "${sel[$i]}" = "1" ]; then
        printf " ${GREEN}[x]${NC}  ${BOLD}%s${NC}\033[K\n" "${pairs[$i]}"
      else
        printf " ${DIM}[ ]${NC}  %s\033[K\n" "${pairs[$i]}"
      fi
    done

    IFS= read -s -n1 key
    if [ "$key" = $'\x1b' ]; then
      read -s -n1 -t 1 skip
      if [ "$skip" = "[" ]; then
        read -s -n1 -t 1 rest
        if [ "$rest" = "A" ]; then
          cur=$((cur > 0 ? cur - 1 : n - 1))
        elif [ "$rest" = "B" ]; then
          cur=$((cur < n - 1 ? cur + 1 : 0))
        fi
      fi
    elif [ "$key" = " " ]; then
      if [ "${sel[$cur]}" = "1" ]; then
        sel[$cur]="0"
      else
        sel[$cur]="1"
      fi
    elif [ "$key" = "a" ] || [ "$key" = "A" ]; then
      local all_sel=1
      for ((i=0; i<n; i++)); do [ "${sel[$i]}" = "0" ] && { all_sel=0; break; }; done
      for ((i=0; i<n; i++)); do sel[$i]="$((1 - all_sel))"; done
    elif [ -z "$key" ] || [ "$key" = $'\n' ] || [ "$key" = $'\r' ]; then
      break
    fi

    for ((i=0; i < n; i++)); do tput cuu1 2>/dev/null || true; done
  done

  printf "%s" "$show_cursor"
  tput ed 2>/dev/null || true
  echo

  selected=()
  for ((i=0; i<n; i++)); do
    [ "${sel[$i]}" = "1" ] && selected+=("${pairs[$i]}")
  done
  [ ${#selected[@]} -eq 0 ] && selected=("${pairs[@]}")
}

status() {
  local same=0 diffc=0 only_repo=0 only_home=0 missing=0
  local r h

  echo
  printf "${BOLD}Status: repo vs ~${NC}\n"

  for f in "${pairs[@]}"; do
    r=$(repo_path "$f"); h=$(home_path "$f")
    if [ ! -f "$r" ] && [ ! -f "$h" ]; then
      printf "  ${DIM}?${NC}  %s\n" "$f"
      ((missing++))
    elif [ ! -f "$r" ]; then
      printf "  ${DIM}%s${NC}\n" "──── $f ────"
      printf "  ${DIM}${RED}only in ~${NC}\n\n"
      ((only_home++))
    elif [ ! -f "$h" ]; then
      printf "  ${DIM}%s${NC}\n" "──── $f ────"
      printf "  ${DIM}${YELLOW}only in repo${NC}\n\n"
      ((only_repo++))
    elif ! diff -q "$r" "$h" >/dev/null 2>&1; then
      printf "  ${DIM}%s${NC}\n" "──── $f ────"
      git diff --no-index --color=always "$r" "$h" 2>/dev/null | tail -n +5 | sed 's/^/    /' || true
      echo
      ((diffc++))
    else
      printf "  ${GREEN}✓${NC}  %s\n" "$f"
      ((same++))
    fi
  done

  echo
  printf "  ${GREEN}%d same${NC}" "$same"
  [ "$diffc" -gt 0 ]     && printf "  ${CYAN}%d diff${NC}" "$diffc"
  [ "$only_repo" -gt 0 ] && printf "  ${YELLOW}%d only in repo${NC}" "$only_repo"
  [ "$only_home" -gt 0 ] && printf "  ${RED}%d only in ~${NC}" "$only_home"
  [ "$missing" -gt 0 ]   && printf "  ${DIM}%d missing${NC}" "$missing"
  echo
}

update() {
  local targets=("${pairs[@]}")
  if [ $# -eq 0 ]; then
    pick_files "Select files to update"
    targets=("${selected[@]}")
  fi

  local count=0
  echo
  printf "${BOLD}Update: ~ → repo${NC}\n"

  for f in "${targets[@]}"; do
    if [ -f "$(home_path "$f")" ]; then
      mkdir -p "$(dirname "$(repo_path "$f")")"
      cp "$(home_path "$f")" "$(repo_path "$f")"
      printf "  ${GREEN}✓${NC}  %s\n" "$f"
      ((count++))
    fi
  done

  echo "  ${DIM}Updated ${count} files${NC}"
}

link() {
  local force=0
  local args=()
  for arg in "$@"; do
    if [ "$arg" = "--force" ] || [ "$arg" = "-f" ]; then
      force=1
    else
      args+=("$arg")
    fi
  done

  local targets=("${pairs[@]}")
  if [ ${#args[@]} -eq 0 ]; then
    pick_files "Select files to link"
    targets=("${selected[@]}")
  else
    targets=("${args[@]}")
  fi

  local linked=0 skipped=0 conflict=0
  echo
  printf "${BOLD}Link: symlink ~ → repo${NC}\n"

  for f in "${targets[@]}"; do
    local r h
    r=$(repo_path "$f"); h=$(home_path "$f")

    if [ ! -f "$r" ]; then
      printf "  ${DIM}?${NC}  %s  ${DIM}(missing in repo)${NC}\n" "$f"
      ((skipped++))
      continue
    fi

    if [ -L "$h" ]; then
      if [ "$(readlink "$h")" = "$r" ]; then
        printf "  ${GREEN}✓${NC}  %s\n" "$f"
        printf "       ${DIM}%s → %s${NC}\n" "$h" "$r"
      else
        printf "  ${YELLOW}~${NC}  %s\n" "$f"
        printf "       ${DIM}%s → %s${NC}\n" "$h" "$(readlink "$h")"
        printf "       ${DIM}target: %s${NC}\n" "$r"
      fi
      ((linked++))
      continue
    fi

    if [ -f "$h" ]; then
      if [ "$force" -eq 1 ]; then
        local bakdir="$DOTFILES/.backup"
        mkdir -p "$bakdir"
        local bak="$bakdir/$f.$(date +%Y%m%d%H%M%S)"
        mkdir -p "$(dirname "$bak")"
        mv "$h" "$bak"
        mkdir -p "$(dir_of "$f")"
        ln -sf "$r" "$h" || { printf "  ${RED}✗${NC}  %s  ${DIM}(link failed)${NC}\n" "$f"; continue; }
        printf "  ${YELLOW}→${NC}  %s\n" "$f"
        printf "       ${DIM}%s → %s${NC}\n" "$h" "$r"
        printf "       ${DIM}backup: %s${NC}\n" "$bak"
        ((linked++))
      else
        printf "  ${RED}✗${NC}  %s  ${DIM}(plain file exists, use -f to backup and link)${NC}\n" "$f"
        ((conflict++))
      fi
      continue
    fi

    mkdir -p "$(dir_of "$f")"
    ln -s "$r" "$h"
    printf "  ${CYAN}→${NC}  %s\n" "$f"
    printf "       ${DIM}%s → %s${NC}\n" "$h" "$r"
    ((linked++))
  done

  echo
  printf "  ${GREEN}%d linked${NC}" "$linked"
  [ "$conflict" -gt 0 ] && printf "  ${RED}%d conflicts${NC}" "$conflict"
  [ "$skipped" -gt 0 ]  && printf "  ${DIM}%d skipped${NC}" "$skipped"
  echo
}

usage() {
  echo "Usage: $(basename "$0") <status|update|link> [file...]"
  echo
  echo "  ${BOLD}status${NC}  show diff status between repo and ~"
  echo "  ${BOLD}update${NC}  copy from ~ to repo"
  echo "  ${BOLD}link${NC}    symlink ~ → repo  ${DIM}(-f backup existing files)${NC}"
  echo
  echo "  Interactive picker when no files specified"
  exit 1
}

shift 1 2>/dev/null || true

case "$MODE" in
  status)  status "$@"  ;;
  update)  update "$@"  ;;
  link)    link "$@"    ;;
  *)       usage        ;;
esac
