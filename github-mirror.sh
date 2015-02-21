#! /bin/sh
#
# Mirror all the public repos of a github user.
#
# Copyright 2015 by Karolin Varner.
#
# Licensed under CC-0, but you can still buy me a drink if
# you meet me.

# $ has_command COMMAND
#
# Check if a command is available on the system.
#
# Arguments:
#   COMMAND – The command to check
# Returns: success if the command is available
has_command() {
  which "$1" 2>/dev/null >/dev/null
}

# $ find_command [COMMAND]...
#
# Search for multiple commands, return the first one that
# exists.
# This is useful, when there are multiple possible names for
# a command. Node js for instance is sometimes named node or
# node.js or nodejs. To find the right one you could do this:
#
#   nodejs=`find_command node nodejs node.js`
#
# Arguments:
#   COMMAND 1 – The first candidate to use
#   COMMAND 2 – The second candidate, will be used if the
#               first can not be found.
# Prints: The name of the first command that could be found
#         or nothing if none exists.
find_command() {
  for cmd in "$@"; do
    if has_command "$cmd"; then
      echo "$cmd"
      return
    fi
  done
}

# $ api_call API_PATH
#
# Call a github api method and fix the json formatting if
# some form of $json_reformat is available.
#
# Arguments:
#   API_PATH – The api method to actually call, e.g. /user
# Prints:
#   The json the api returned
api_call() {
  curl "${api}/${1}" 2>/dev/null | "$json_reformat"
}

# $ ls_repos [USER]...
#
# List the public github repositories of all github users
# listed in the form "$USER/$REPO_NAME".
#
#   $ list_repos hello kitty
#   hello/greeting
#   hello/message
#   hello/bar
#   kitty/cat
#   kitty/bum
#   kitty/head
#
# ARGUMENTS:
#   USER 1 – List the repos of this user
#   USER 2 – List the repos of that user too
#   ...
# Prints:
#   The full name of one repository per line:
ls_repos() {
  for user in "$@"; do
    api_call "users/${user}/repos" \
        | grep -Fi 'full_name'     \
        | grep -o "${user}/[^\"]*"
  done
}

# $ clone_one_repo REPO
#
# Clones one repo "$user/$repo" into the corresponding
# directory: "./$user/$repo"
#
# ARGUMENTS:
#   REPO - The repository to clone in the form "$user/repo"
clone_one_repo() {
  echo >&2
  echo >&2 "======= CLONING: $1"
  git clone --bare "${clone_base}/$1" "$1"
}

# $ update_one_repo REPO
#
# Changes into the directory of repo "./$user/repo", updates
# the remotes and pulls the currently checked out branch.
update_one_repo() {
  echo >&2
  echo >&2 "======= UPDATING: $1"
  (
    cd "$1"
    git remote update
    git pull --mirror
  )
}

# $ mirror_one_repo REPO
#
# Updates the given repo or clones it, depending on whether
# it is already there.
mirror_one_repo() {
  test -d "$1" || clone_one_repo "$@"
  update_one_repo "$@"
}

# $ mirror [USER]...
mirror() {
  ls_repos "$@" | while read repo; do
    mirror_one_repo "$repo"
  done
}

api="https://api.github.com" # No slash!
clone_base="https://github.com"

json_reformat=`find_command json_reformat cat`
echo >&2 "Using '$json_reformat' to format json."

cmd="$1"; shift
$cmd "$@"
