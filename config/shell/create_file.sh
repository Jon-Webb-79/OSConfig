#!/usr/bin/bash
# create_file file
# ================================================================================
# ================================================================================
# - Purpose: This file contains zsh scripts that are used to create formatted
#            code files for Python, C, C++, and Arduino
#
# Source Metadata
# - Author:  Jonathan A. Webb
# - Date:    February 26, 2022
# - Version: 1.0
# - Copyright: Copyright 2022, Jon Webb Inc.
# ================================================================================
# ================================================================================
# - Read the language to be created as a command line_ardument.  The languages
#   can be Python, C, C++, Python_Test, C_Test, C++_Test, or Arduino

set -euo pipefail

readonly AUTHOR='Jonathan A. Webb'
readonly COMPANY='Jon Webb'

usage() {
    cat <<'EOF'
Usage: create_file.sh <type>

Supported types:
  Python
  Python_Test
  C
  C_Test
  C_Lib
  C_Main
  C++
  C++_Test
  C++_Lib
  C++_Main
  Arduino
EOF
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

replace_tokens() {
    local file="$1"
    local base_name="$2"
    local day month year
    day="$(date +%d)"
    month="$(date +%B)"
    year="$(date +%Y)"

    [[ -f "$file" ]] || return 0

    sed -i \
        -e "s/Day/${day}/g" \
        -e "s/Month/${month}/g" \
        -e "s/Year/${year}/g" \
        -e "s/Name/${AUTHOR}/g" \
        -e "s/Company/${COMPANY}/g" \
        -e "s/filename/${base_name}/g" \
        "$file"
}

copy_template() {
    local src="$1"
    local dst="$2"
    [[ -f "$src" ]] || die "Template not found: $src"
    cp "$src" "$dst"
}

prompt_name() {
    local prompt="$1"
    printf '%s\n' "$prompt" >&2
    local value
    IFS= read -r value
    [[ -n "$value" ]] || die "Name cannot be empty."
    printf '%s\n' "$value"
}

main() {
    [[ $# -eq 1 ]] || { usage; exit 1; }

    local language="$1"
    case "$language" in
        Python|Python_Test|C|C_Test|C_Lib|C_Main|C++|C++_Test|C++_Lib|C++_Main|Arduino) ;;
        *) usage; exit 1 ;;
    esac

    local dir py_dir c_dir cpp_dir ard_dir
    dir="$(pwd)"
    py_dir="${HOME}/.config/py_files"
    c_dir="${HOME}/.config/c_files"
    cpp_dir="${HOME}/.config/c++_files"
    ard_dir="${HOME}/.config/arduino_files"

    local file_name target

    case "$language" in
        Python)
            file_name="$(prompt_name 'Enter the filename without the .py extension')"
            target="${dir}/${file_name}.py"
            copy_template "${py_dir}/main.py" "$target"
            replace_tokens "$target" "$file_name"
            ;;
        Python_Test)
            file_name="$(prompt_name 'Enter the filename without the .py extension')"
            target="${dir}/${file_name}.py"
            copy_template "${py_dir}/test.py" "$target"
            replace_tokens "$target" "$file_name"
            ;;
        C)
            file_name="$(prompt_name 'Enter the filename without the .c or .h extension')"
            copy_template "${c_dir}/additional_file.c" "${dir}/${file_name}.c"
            copy_template "${c_dir}/additional_file.h" "${dir}/${file_name}.h"
            replace_tokens "${dir}/${file_name}.c" "$file_name"
            replace_tokens "${dir}/${file_name}.h" "$file_name"
            ;;
        C_Test)
            file_name="$(prompt_name 'Enter the filename without the .c or .h extension')"
            copy_template "${c_dir}/test.c" "${dir}/${file_name}.c"
            copy_template "${c_dir}/test.h" "${dir}/${file_name}.h"
            replace_tokens "${dir}/${file_name}.c" "$file_name"
            replace_tokens "${dir}/${file_name}.h" "$file_name"
            ;;
        C_Lib)
            file_name="$(prompt_name 'Enter the library name')"
            mkdir -p "${dir}/${file_name}"
            copy_template "${c_dir}/CMake2.txt" "${dir}/${file_name}/CMakeLists.txt"
            sed -i "s/prjct_name/${file_name}/g" "${dir}/${file_name}/CMakeLists.txt"
            replace_tokens "${dir}/${file_name}/CMakeLists.txt" "$file_name"
            ;;
        C_Main)
            file_name="$(prompt_name 'Enter the main file name without the .c extension')"
            copy_template "${c_dir}/main.c" "${dir}/${file_name}.c"
            replace_tokens "${dir}/${file_name}.c" "$file_name"
            ;;
        C++)
            file_name="$(prompt_name 'Enter the filename without the .cpp or .hpp extension')"
            copy_template "${cpp_dir}/additional_file.cpp" "${dir}/${file_name}.cpp"
            copy_template "${cpp_dir}/additional_file.hpp" "${dir}/${file_name}.hpp"
            replace_tokens "${dir}/${file_name}.cpp" "$file_name"
            replace_tokens "${dir}/${file_name}.hpp" "$file_name"
            ;;
        C++_Test)
            file_name="$(prompt_name 'Enter the filename without the .cpp extension')"
            copy_template "${cpp_dir}/test.cpp" "${dir}/${file_name}.cpp"
            replace_tokens "${dir}/${file_name}.cpp" "$file_name"
            ;;
        C++_Lib)
            file_name="$(prompt_name 'Enter the library name')"
            mkdir -p "${dir}/${file_name}"
            copy_template "${cpp_dir}/CMake2.txt" "${dir}/${file_name}/CMakeLists.txt"
            sed -i "s/prjct_name/${file_name}/g" "${dir}/${file_name}/CMakeLists.txt"
            replace_tokens "${dir}/${file_name}/CMakeLists.txt" "$file_name"
            ;;
        C++_Main)
            file_name="$(prompt_name 'Enter the main file name without the .cpp extension')"
            copy_template "${cpp_dir}/main.cpp" "${dir}/${file_name}.cpp"
            replace_tokens "${dir}/${file_name}.cpp" "$file_name"
            ;;
        Arduino)
            file_name="$(prompt_name 'Enter the filename without the .ino extension')"
            target="${dir}/${file_name}.ino"
            copy_template "${ard_dir}/main.ino" "$target"
            replace_tokens "$target" "$file_name"
            ;;
    esac

    printf 'Created %s template successfully.\n' "$language"
}

main "$@"
# ================================================================================
# ================================================================================
# eof

