#!/bin/sh

# $1 - File descriptor. Your script should write paths, each ending with newline, to this fd.
# $2 - Request type. 0 is SaveFile, 1 is SaveFiles, 2 is OpenFile
# For SaveFile:
#   $3 - Suggested folder in which the file should be saved.
#   $4 - Suggested name of the file.
# For OpenFile:
#   $3 - Suggested folder from which the files should be opened.
#   $4 - 1 if multiple files can be selected, 0 otherwise.
#   $5 - 1 if folders should be selected instead of files, 0 otherwise.
#
# NOTE: in this script I use "fdmove" program.
# fdmove is a part of execline (https://skarnet.org/software/execline), and therefore
# an external dependency. There just isn't a way to redirect fds greater than 10
# in both bash and posix sh, and there's no guarantee pipe_fd will be smaller than 10.

die() {
    printf "$@" >&2
    exit 1
}

dummy_file="$(cat <<'EOF'
Saving files tutorial

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!        === WARNING! ===        !!!
!!! The contents of whatever file  !!!
!!! you select will be OVERWRITTEN !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Instructions:
1) Move this file wherever you want.
2) Rename the file if needed.
3) Press Enter to confirm selection.

Notes:
1) This file is provided only for your
   convenience. You can delete it and
   choose another file to overwrite.
2) If you quit without pressing Enter
   this file will be removed and save
   operation aborted.
EOF
)"

termcmd='foot -a xdg-desktop-portal-termfilechooser'

pipe_fd="$1"
type="$2"

case "$type" in
    (0) # SaveFile
        current_folder="$3"
        current_name="$4"

        suggested_file_path="${current_folder}/${current_name}"
        # keep appending _ to suggested file path if it already exists
        while [ -e "$suggested_file_path" ]; do
            suggested_file_path="${suggested_file_path}_"
        done
        echo "$dummy_file" >"$suggested_file_path"

        # This is what will be displayed at the top of lf window, see lf docs for details
        promptfmt=' \033[1;31mSaving file:\033[0m \033[1;34m%w/\033[1;37m%f\033[0m'

        # launch lf running in foot.
        # map enter key to execute echo with selected files as arguments,
        # with its output redirected to pipe file descriptor provided by portal,
        # and then quit lf.
        $termcmd \
            lf \
            -command "set promptfmt \"${promptfmt}\"" \
            -command 'cmd confirm $fdmove -c 1 '"${pipe_fd}"' echo "$fx"' \
            -command 'map <enter> :confirm; quit' \
            "$suggested_file_path"
        ;;
    (2) # OpenFile
        current_folder="$3"
        multiple="$4"
        directory="$5"

        if [ "$multiple" = "1" ]; then
            confirm_cmd='fdmove -c 1 '"${pipe_fd}"' echo "$fx"'
            promptfmt=' \033[1;32mOpening files:\033[0m \033[1;34m%w/\033[1;37m%f\033[0m'
        else
            confirm_cmd='fdmove -c 1 '"${pipe_fd}"' echo "$f"'
            promptfmt=' \033[1;32mOpening file:\033[0m \033[1;34m%w/\033[1;37m%f\033[0m'
        fi

        if [ "$directory" = "1" ]; then
            dironly_cmd='set dironly true'
            promptfmt=' \033[1;32mOpening directory:\033[0m \033[1;34m%w/\033[1;37m%f\033[0m'
        else
            dironly_cmd='set dironly false'
        fi

        $termcmd \
            lf \
            -command "$dironly_cmd" \
            -command "set promptfmt \"${promptfmt}\"" \
            -command 'cmd confirm $'"${confirm_cmd}" \
            -command 'map <enter> :confirm; quit' \
            "$current_folder"
        ;;
    (*)
        die "Invalid request type: %d\n" "$type"
esac


