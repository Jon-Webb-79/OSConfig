#!/usr/bin/bash 
# ================================================================================
# Git Aliases and Workflow Utilities
# ================================================================================
#
# Description:
#   This file provides a comprehensive set of Git aliases and helper functions
#   designed to streamline common version control workflows and improve
#   developer productivity.
#
#   It includes:
#     - Short, consistent aliases for core Git operations
#     - Intelligent helper functions for branch detection and repository context
#     - Workflow automation (e.g., WIP commits, safe branch cleanup)
#     - Enhanced logging and history visualization
#     - Utilities for repository management and navigation
#
#   The design emphasizes:
#     - Efficiency (reduced typing for common operations)
#     - Safety (guards against destructive operations where possible)
#     - Context-awareness (dynamic branch and repo detection)
#     - Consistency (uniform alias naming conventions)
#
#   Helper functions extend Git by providing:
#     - Automatic detection of main/develop branch names
#     - Repository-aware commands (current branch, repo root)
#     - Safer cleanup of merged branches
#     - Simplified clone-and-enter workflows
#
# Usage:
#   Source this file in your shell configuration:
#
#       source ~/.config/shell/git_aliases.sh
#
#   Requires Git to be installed and available in PATH.
#
# Source Metadata:
#   Author:    Jonathan A. Webb
#   Created:   February 22, 2022
#   Updated:   March 26, 2026
#   Version:   2.0
#
# ================================================================================
# ================================================================================ 

# ------------------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------------------

# Return success if the current directory is inside a Git work tree.
is_git_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Print the current branch name, or short commit hash when detached.
git_current_branch_name() {
    git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
}

# Print the repository root, or "." when not in a Git repository.
git_repo_root() {
    git rev-parse --show-toplevel 2>/dev/null || printf '.\n'
}

# Print the preferred main branch name.
# The function checks common names in local and remote refs and falls back to
# "master" if none are found.
git_main_branch() {
    is_git_repo || return 1

    for ref in \
        refs/heads/main \
        refs/remotes/origin/main \
        refs/remotes/upstream/main \
        refs/heads/trunk \
        refs/remotes/origin/trunk \
        refs/remotes/upstream/trunk
    do
        if git show-ref --quiet --verify "$ref"; then
            printf '%s\n' "${ref##*/}"
            return 0
        fi
    done

    printf 'master\n'
}

# Print the preferred development branch name.
# Checks common development branch variants and falls back to "develop".
git_develop_branch() {
    is_git_repo || return 1

    for branch in dev devel development develop; do
        if git show-ref --quiet --verify "refs/heads/$branch" || \
           git show-ref --quiet --verify "refs/remotes/origin/$branch" || \
           git show-ref --quiet --verify "refs/remotes/upstream/$branch"; then
            printf '%s\n' "$branch"
            return 0
        fi
    done

    printf 'develop\n'
}

# Show a custom pretty git log format.
# Usage:
#   glp '%h %s'
git_log_prettily() {
    if [ -n "$1" ]; then
        git log --pretty="$1"
    else
        printf 'Usage: git_log_prettily <pretty-format>\n' >&2
        return 1
    fi
}

# Print "WIP!!" if the latest commit message contains the conventional --wip-- tag.
git_work_in_progress() {
    git -c log.showSignature=false log -n 1 2>/dev/null | grep -q -- '--wip--' && printf 'WIP!!\n'
}

# Clone a repository with submodules and cd into the cloned directory.
# Usage:
#   gccd <repo-url> [git clone options...]
gccd() {
    if [ $# -lt 1 ]; then
        printf 'Usage: gccd <repo-url> [git clone options...]\n' >&2
        return 1
    fi

    repo_url=$1
    if ! git clone --recurse-submodules "$@"; then
        return 1
    fi

    repo_name=${repo_url##*/}
    repo_name=${repo_name%.git}

    if [ -d "$repo_name" ]; then
        cd "$repo_name" || return 1
    fi
}

# Rename a branch locally and on origin.
# Usage:
#   grename <old-branch> <new-branch>
grename() {
    if [ $# -ne 2 ]; then
        printf 'Usage: grename <old-branch> <new-branch>\n' >&2
        return 1
    fi

    old_branch=$1
    new_branch=$2

    git branch -m "$old_branch" "$new_branch" || return 1
    if git push origin ":$old_branch"; then
        git push --set-upstream origin "$new_branch"
    fi
}

# Delete local branches already merged into main/develop, excluding the active
# branch and the detected main/develop branches.
gbda_safe() {
    is_git_repo || return 1

    current_branch=$(git_current_branch_name) || return 1
    main_branch=$(git_main_branch 2>/dev/null)
    develop_branch=$(git_develop_branch 2>/dev/null)

    git branch --merged 2>/dev/null | while IFS= read -r line; do
        branch=$(printf '%s' "$line" | sed 's/^[*[:space:]]*//')
        [ -z "$branch" ] && continue
        [ "$branch" = "$current_branch" ] && continue
        [ -n "$main_branch" ] && [ "$branch" = "$main_branch" ] && continue
        [ -n "$develop_branch" ] && [ "$branch" = "$develop_branch" ] && continue
        git branch -d "$branch"
    done
}

# Push the current branch to origin and set upstream.
gpsup() {
    branch=$(git_current_branch_name) || return 1
    git push --set-upstream origin "$branch"
}

# Pull the current branch from origin.
ggpull() {
    branch=$(git_current_branch_name) || return 1
    git pull origin "$branch"
}

# Push the current branch to origin.
ggpush() {
    branch=$(git_current_branch_name) || return 1
    git push origin "$branch"
}

# Set the current branch to track origin/<current-branch>.
ggsup() {
    branch=$(git_current_branch_name) || return 1
    git branch --set-upstream-to="origin/$branch"
}

# Undo the most recent WIP commit if the latest commit message contains --wip--.
gunwip() {
    if git log -n 1 2>/dev/null | grep -q -- '--wip--'; then
        git reset HEAD~1
    else
        printf 'gunwip: latest commit is not marked --wip--\n' >&2
        return 1
    fi
}

# Create a WIP commit from the current working tree.
gwip() {
    git add -A || return 1
    deleted_files=$(git ls-files --deleted 2>/dev/null)
    if [ -n "$deleted_files" ]; then
        printf '%s\n' "$deleted_files" | xargs git rm -- >/dev/null 2>&1
    fi
    git commit --no-verify --no-gpg-sign -m '--wip-- [skip ci]'
}

# ------------------------------------------------------------------------------
# Core aliases
# ------------------------------------------------------------------------------

alias g='git'

# Add / apply
alias ga='git add'
alias gaa='git add --all'
alias gap='git apply'
alias gapa='git add --patch'
alias gapt='git apply --3way'
alias gau='git add --update'
alias gav='git add --verbose'

# Branch
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbda='gbda_safe'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'

# Commit
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcam='git commit -a -m'
alias gcas='git commit -a -s'
alias gcasm='git commit -a -s -m'
alias gcmsg='git commit -m'
alias gcs='git commit -S'
alias gcss='git commit -S -s'
alias gcssm='git commit -S -s -m'
alias gcf='git config --list'

# Checkout / switch
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout "$(git_main_branch)"'
alias gcd='git checkout "$(git_develop_branch)"'
alias gsw='git switch'
alias gswc='git switch -c'
alias gswm='git switch "$(git_main_branch)"'
alias gswd='git switch "$(git_develop_branch)"'

# Clone / clean
alias gcl='git clone --recurse-submodules'
alias gclean='git clean -id'

# Diff
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdup='git diff @{upstream}'
alias gdw='git diff --word-diff'

# Fetch / pull / push
alias gl='git pull'
alias gpr='git pull --rebase'
alias gup='git pull --rebase'
alias gupa='git pull --rebase --autostash'
alias gupv='git pull --rebase -v'
alias gupav='git pull --rebase --autostash -v'
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease'
alias gpu='git push upstream'
alias gpv='git push -v'

# Log
alias glg='git log --stat'
alias glgp='git log --stat -p'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty=format:"%h - %d %s (%cr) <%an>"'
alias glols='git log --graph --pretty=format:"%h - %d %s (%cr) <%an>" --stat'
alias glod='git log --graph --pretty=format:"%h - %d %s (%ad) <%an>"'
alias glods='git log --graph --pretty=format:"%h - %d %s (%ad) <%an>" --date=short'
alias glola='git log --graph --pretty=format:"%h - %d %s (%cr) <%an>" --all'
alias glp='git_log_prettily'

# Merge / rebase
alias gm='git merge'
alias gma='git merge --abort'
alias gmom='git merge origin/"$(git_main_branch)"'
alias gmum='git merge upstream/"$(git_main_branch)"'
alias gmtl='git mergetool --no-prompt'
alias gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbd='git rebase "$(git_develop_branch)"'
alias grbi='git rebase -i'
alias grbm='git rebase "$(git_main_branch)"'
alias grbom='git rebase origin/"$(git_main_branch)"'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'

# Remote / reset / restore
alias gr='git remote'
alias gra='git remote add'
alias grh='git reset'
alias grm='git rm'
alias grmc='git rm --cached'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'
alias grt='cd "$(git_repo_root)"'
alias gru='git reset --'
alias grup='git remote update'
alias grv='git remote -v'

# Status / show / stash / tags
alias gsb='git status -sb'
alias gsh='git show'
alias gss='git status -s'
alias gst='git status'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gstall='git stash --all'
alias gstu='git stash --include-untracked'
alias gts='git tag -s'
alias gtv='git tag | sort -V'

# Misc
alias ghh='git help'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias gunignore='git update-index --no-assume-unchanged'

# ================================================================================ 
# ================================================================================ 
# eof
