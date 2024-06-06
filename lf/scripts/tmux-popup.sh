#!/usr/bin/env bash
# Usage: lmux-popup.sh [-w WIDTH] [-h HEIGHT] [-E] [ARGS] -- COMMAND
#
# Display tmux popup running COMMAND centered in currently active pane
#
# WIDTH and HEIGHT can end with %, in this case they are treated
# as percentage of pane size
#
# It is IMPORTANT to separate command from args with -- 
# that's just how my stupid aah parser works

export _script_name="tmux-popup"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh

if [ -z "$TMUX" ]; then
  die "TMUX envvar is not set, not running in tmux?"
fi

height="70%"
width="70%"
e_count="0"
extra_args=""

# Parse command line options
while true; do
  case "$1" in
    '-w')
      shift 1
      if [[ $1 =~ ^[1-9][0-9]*%?$ ]]; then
        width="$1"
      else
        die "wrong argument: $1"
      fi
      ;;
    '-h')
      shift 1
      if [[ "$1" =~ ^[1-9][0-9]*%?$ ]]; then
        height="$1"
      else
        die "wrong argument: $1"
      fi
      ;;
    '-E')
      e_count="$(( e_count + 1 ))"
      ;;
    '-EE')
      e_flag="-EE"
      ;;
    '--')
      shift 1
      break
      ;;
    *)
      die "wrong option: $1"
      ;;
  esac

  shift 1
done

if [ -z "$e_flag" ]; then
  if [ "$e_count" -ge "2" ]; then
    e_flag="-EE"
  elif [ "$e_count" -eq "1" ]; then
    e_flag="-E"
  fi
fi

popup_border_lines="$(tmux show-options -Apv popup-border-lines)"

if [[ "$width" =~ %$ ]]; then w_percent=1; else
  if [ ! "$popup_border_lines" = "none" ]; then width=$(( width + 2 )); fi
  w_percent=0;
fi
if [[ "$height" =~ %$ ]]; then h_percent=1; else
  if [ ! "$popup_border_lines" = "none" ]; then height=$(( height + 2 )); fi
  h_percent=0;
fi

IFS=' ' read x y w h < <(tmux display-message -p \
  "scale = 2; 
  pane_center_x = ((#{pane_left} + #{pane_right}) / 2); 
  pane_center_y = ((#{pane_top} + #{pane_bottom}) / 2);

  if ( $w_percent ) {
    popup_width = (${width%\%} / 100 * #{pane_width});
  } else {
    popup_width = ${width%\%}
  }
  if ( $h_percent ) {
    popup_height = (${height%\%} / 100 * #{pane_height});
  } else {
    popup_height = ${height%\%}
  }
  
  print pane_center_x - popup_width / 2;
  print \" \";
  print pane_center_y + popup_height / 2;
  print \" \";
  print popup_width;
  print \" \";
  print popup_height" | bc)
x="${x%.*}"; y="${y%.*}"; w="${w%.*}"; h="${h%.*}"

tmux display-popup \
  -e id="$id" \
  -e LF_DATA_HOME="$LF_DATA_HOME" \
  -x "$x" \
  -y "$y" \
  -w "$w" \
  -h "$h" \
  $e_flag -- \
  "$@"

