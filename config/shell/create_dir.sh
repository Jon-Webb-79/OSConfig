#!/usr/bin/bash
# ================================================================================
# Project Creation Script
# ================================================================================
# - Purpose: This script automates the creation of software development projects
#            for Python, C, C++, and Arduino.
#
# Usage:
#   create_dir.sh <Python|C|C++|Arduino> [base_directory]
#
# Behavior:
# - If base_directory is omitted, projects are created under:
#     ~/Code_Dev/<language>/<project_name>
#   and the parent directory is created automatically if missing.
# - If base_directory is provided, it may be absolute or relative.
# - Relative base directories are resolved from the current working directory.
# - Custom base directories must already exist.
# ================================================================================
# ================================================================================

set -euo pipefail
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

readonly AUTHOR='Jonathan A. Webb'
readonly COMPANY='Jon Webb'
readonly SCRIPT_DIR="${HOME}/.config/shell"

usage() {
    cat <<'EOF'
Usage: create_dir.sh <Python|C|C++|Arduino> [base_directory]

Examples:
  create_dir.sh C
  create_dir.sh C temp
  create_dir.sh C ~/Work
  create_dir.sh Python /mnt/data/projects
EOF
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

replace_tokens() {
    local file="$1"
    local target_name="$2"
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
        -e "s/filename/${target_name}/g" \
        "$file"
}

get_cmake_version() {
    require_cmd cmake
    require_cmd awk
    cmake --version | awk 'NR == 1 { print $3 }'
}

replace_cmake_tokens() {
    local file="$1"
    local project_name="$2"
    local cmake_version="$3"

    [[ -f "$file" ]] || return 0

    sed -i \
        -e "s/prjct_name/${project_name}/g" \
        -e "s/X\\.YY\\.ZZ/${cmake_version}/g" \
        "$file"
}

replace_script_tokens() {
    local file="$1"
    local project_name="$2"

    [[ -f "$file" ]] || return 0

    sed -i \
        -e "s/prjct_name/${project_name}/g" \
        -e "s/PRJCT_NAME/${project_name^^}/g" \
        "$file"
}

copy_if_exists() {
    local src="$1"
    local dst="$2"
    [[ -e "$src" ]] || return 0
    cp -R "$src" "$dst"
}

resolve_base_dir() {
    local language="$1"
    local base_dir

    if [[ $# -ge 2 ]]; then
        base_dir="$2"

        if [[ ! "$base_dir" = /* ]]; then
            base_dir="${PWD}/${base_dir}"
        fi

        [[ -d "$base_dir" ]] || die "Base directory does not exist: $base_dir"
    else
        base_dir="${HOME}/Code_Dev/${language}"
        mkdir -p "$base_dir"
    fi

    printf '%s\n' "$base_dir"
}

write_sphinx_requirements() {
    local req_file="$1"

    cat > "$req_file" <<'EOF'
sphinx
breathe
sphinx-copybutton
sphinx-rtd-theme
EOF
}

install_doc_packages() {
    local venv_dir="$1"
    local req_file="$2"

    local py_bin="${venv_dir}/bin/python"
    local freeze_file
    freeze_file="$(dirname "$req_file")/requirements.txt"

    [[ -x "$py_bin" ]] || die "Virtual environment python not found: $py_bin"
    [[ -f "$req_file" ]] || die "Requirements file not found: $req_file"

    "$py_bin" -m pip install --upgrade pip setuptools wheel \
        || die "Failed to upgrade pip tooling in ${venv_dir}"

    "$py_bin" -m pip install -r "$req_file" \
        || die "Failed to install documentation packages in ${venv_dir}"

    "$py_bin" -m pip freeze > "$freeze_file" \
        || die "Failed to generate frozen requirements file: $freeze_file"
}

setup_python() {
    local project_root="$1"
    local project_name="$2"
    local py_dir="${HOME}/.config/templates/python"

    require_cmd python3
    require_cmd cp
    require_cmd sed

    mkdir -p \
        "${project_root}/${project_name}" \
        "${project_root}/tests" \
        "${project_root}/scripts/unix" \
        "${project_root}/scripts/Windows" \
        "${project_root}/data/test" \
        "${project_root}/docs/sphinx/source"

    if command -v poetry >/dev/null 2>&1; then
        (
            cd "${project_root}"
            poetry init -n --name "${project_name}" >/dev/null 2>&1 || true
            poetry config virtualenvs.in-project true >/dev/null 2>&1 || true
        )
    else
        python3 -m venv "${project_root}/.venv"
    fi

    copy_if_exists "${py_dir}/.pre-commit-config.yaml" "${project_root}/.pre-commit-config.yaml"
    copy_if_exists "${py_dir}/.readthedocs.yaml" "${project_root}/.readthedocs.yaml"
    copy_if_exists "${py_dir}/.flake8" "${project_root}/.flake8"
    copy_if_exists "${py_dir}/.gitignore" "${project_root}/.gitignore"
    copy_if_exists "${py_dir}/LICENSE" "${project_root}/LICENSE"
    copy_if_exists "${py_dir}/ci_install.txt" "${project_root}/ci_install.txt"
    copy_if_exists "${py_dir}/pyproject.toml" "${project_root}/pyproject.toml"
    copy_if_exists "${py_dir}/README.rst" "${project_root}/README.rst"
    copy_if_exists "${py_dir}/conftest.py" "${project_root}/conftest.py"
    copy_if_exists "${py_dir}/test.py" "${project_root}/tests/test.py"
    copy_if_exists "${py_dir}/main.py" "${project_root}/${project_name}/main.py"
    copy_if_exists "${py_dir}/conf.py" "${project_root}/docs/sphinx/source/conf.py"
    copy_if_exists "${py_dir}/index.rst" "${project_root}/docs/sphinx/source/index.rst"
    copy_if_exists "${py_dir}/module.rst" "${project_root}/docs/sphinx/source/module.rst"
    copy_if_exists "${py_dir}/sphinx_readme.txt" "${project_root}/docs/sphinx/readme.txt"
    copy_if_exists "${py_dir}/sphinx_make" "${project_root}/docs/sphinx/Makefile"
    copy_if_exists "${py_dir}/Makefile" "${project_root}/Makefile"
    copy_if_exists "${py_dir}/.github" "${project_root}/.github"

    : > "${project_root}/${project_name}/__init__.py"

    replace_tokens "${project_root}/${project_name}/main.py" "main"
    replace_tokens "${project_root}/tests/test.py" "test"
    replace_tokens "${project_root}/conftest.py" "conftest"

    if [[ -f "${project_root}/README.rst" ]]; then
        sed -i "s/Project_Name/${project_name}/g" "${project_root}/README.rst"
    fi

    if [[ -f "${project_root}/pyproject.toml" ]]; then
        sed -i \
            -e "s/README.md/README.rst/g" \
            -e "s/pyproject/${project_name}/g" \
            "${project_root}/pyproject.toml"
    fi
}

setup_c_family() {
    local language="$1"
    local project_root="$2"
    local project_name="$3"
    local c_dir="${HOME}/.config/templates/C"
    local cpp_dir="${HOME}/.config/templates/C++"
    local template_dir
    local src_root="${project_root}/${project_name}"
    local test_dir="${src_root}/test"
    local doc_venv="${project_root}/docs/doxygen/.venv"
    local req_file="${project_root}/docs/doxygen/sphinx.txt"
    local cmake_version

    require_cmd python3
    require_cmd cp
    require_cmd sed
    require_cmd chmod

    cmake_version="$(get_cmake_version)"

    mkdir -p \
        "${src_root}" \
        "${src_root}/include" \
        "${src_root}/simd" \
        "${src_root}/build" \
        "${test_dir}" \
        "${project_root}/scripts/unix" \
        "${project_root}/scripts/Windows" \
        "${project_root}/data/test" \
        "${project_root}/docs/doxygen/sphinx_docs"

    python3 -m venv "${doc_venv}"

    write_sphinx_requirements "${req_file}"
    install_doc_packages "${doc_venv}" "${req_file}"

    copy_if_exists "${c_dir}/Doxyfile" "${project_root}/docs/doxygen/Doxyfile"
    copy_if_exists "${c_dir}/mainpage.dox" "${project_root}/docs/doxygen/mainpage.dox"
    copy_if_exists "${c_dir}/README.rst" "${project_root}/README.rst"

    if [[ "$language" == "C" ]]; then
        template_dir="${c_dir}"

        copy_if_exists "${template_dir}/main.c" "${src_root}/main.c"
        copy_if_exists "${template_dir}/avrMakefile" "${src_root}/Makefile"
        copy_if_exists "${template_dir}/CMake1.txt" "${src_root}/CMakeLists.txt"
        copy_if_exists "${template_dir}/CMaketest.txt" "${test_dir}/CMakeLists.txt"

        copy_if_exists "${template_dir}/test.c" "${test_dir}/test.c"
        copy_if_exists "${template_dir}/test_suite.c" "${test_dir}/test_suite.c"
        copy_if_exists "${template_dir}/unit_test.c" "${test_dir}/unit_test.c"

        replace_tokens "${src_root}/main.c" "main"
        replace_tokens "${test_dir}/test.c" "test"
        replace_tokens "${test_dir}/test_suite.h" "test_suite"
        replace_tokens "${test_dir}/unit_test.c" "unit_test"

        replace_cmake_tokens "${src_root}/CMakeLists.txt" "${project_name}" "${cmake_version}"
        replace_cmake_tokens "${test_dir}/CMakeLists.txt" "${project_name}" "${cmake_version}"
    else
        template_dir="${cpp_dir}"

        copy_if_exists "${template_dir}/main.cpp" "${src_root}/main.cpp"
        copy_if_exists "${template_dir}/CMake1.txt" "${src_root}/CMakeLists.txt"
        copy_if_exists "${template_dir}/CMaketest.txt" "${test_dir}/CMakeLists.txt"
        copy_if_exists "${cpp_dir}/README.rst" "${project_root}/README.rst"

        # Test templates are stored under ~/.config/templates/C/
        copy_if_exists "${c_dir}/test.c" "${test_dir}/test.c"
        copy_if_exists "${c_dir}/test_suite.h" "${test_dir}/test_suite.h"
        copy_if_exists "${c_dir}/unit_test.c" "${test_dir}/unit_test.c"

        replace_tokens "${src_root}/main.cpp" "main"
        replace_tokens "${test_dir}/test.c" "test"
        replace_tokens "${test_dir}/test_suite.h" "test_suite"
        replace_tokens "${test_dir}/unit_test.c" "unit_test"

        replace_cmake_tokens "${src_root}/CMakeLists.txt" "${project_name}" "${cmake_version}"
        replace_cmake_tokens "${test_dir}/CMakeLists.txt" "${project_name}" "${cmake_version}"
    fi

    copy_if_exists "${c_dir}/debug.sh"   "${project_root}/scripts/unix/debug.sh"
    copy_if_exists "${c_dir}/install.sh" "${project_root}/scripts/unix/install.sh"
    copy_if_exists "${c_dir}/static.sh"  "${project_root}/scripts/unix/static.sh"

    copy_if_exists "${c_dir}/debug.bat"   "${project_root}/scripts/Windows/debug.bat"
    copy_if_exists "${c_dir}/install.bat" "${project_root}/scripts/Windows/install.bat"
    copy_if_exists "${c_dir}/static.bat"  "${project_root}/scripts/Windows/static.bat"

    replace_script_tokens "${project_root}/scripts/unix/debug.sh"   "${project_name}"
    replace_script_tokens "${project_root}/scripts/unix/install.sh" "${project_name}"
    replace_script_tokens "${project_root}/scripts/unix/static.sh"  "${project_name}"

    replace_script_tokens "${project_root}/scripts/Windows/debug.bat"   "${project_name}"
    replace_script_tokens "${project_root}/scripts/Windows/install.bat" "${project_name}"
    replace_script_tokens "${project_root}/scripts/Windows/static.bat"  "${project_name}"

    chmod +x \
        "${project_root}/scripts/unix/debug.sh" \
        "${project_root}/scripts/unix/install.sh" \
        "${project_root}/scripts/unix/static.sh"

    if [[ -f "${project_root}/README.rst" ]]; then
        sed -i "s/Project_Name/${project_name}/g" "${project_root}/README.rst"
    fi
}

setup_arduino() {
    local project_root="$1"
    mkdir -p "${project_root}"
}

main() {
    [[ $# -ge 1 && $# -le 2 ]] || { usage; exit 1; }

    local language="$1"
    case "$language" in
        Python|C|C++|Arduino) ;;
        *) usage; exit 1 ;;
    esac

    local base_dir
    if [[ $# -eq 2 ]]; then
        base_dir="$(resolve_base_dir "$language" "$2")"
    else
        base_dir="$(resolve_base_dir "$language")"
    fi

    printf 'Enter the Project Name:\n'
    local project_name
    IFS= read -r project_name
    [[ -n "$project_name" ]] || die "Project name cannot be empty."

    local project_root="${base_dir}/${project_name}"
    [[ ! -e "${project_root}" ]] || die "${project_root} already exists."

    mkdir -p "${project_root}"

    case "$language" in
        Python) setup_python "${project_root}" "${project_name}" ;;
        C|C++)  setup_c_family "${language}" "${project_root}" "${project_name}" ;;
        Arduino) setup_arduino "${project_root}" ;;
    esac

    printf 'Created project at: %s\n' "${project_root}"

    if [[ -x "${SCRIPT_DIR}/create_project_tmux.sh" ]]; then
        printf 'Open a tmux session now? [y/N] '
        local answer
        IFS= read -r answer
        case "$answer" in
            [Yy]|[Yy][Ee][Ss])
                "${SCRIPT_DIR}/create_project_tmux.sh" "${language}" "${project_root}"
                ;;
        esac
    fi
}

main "$@"
