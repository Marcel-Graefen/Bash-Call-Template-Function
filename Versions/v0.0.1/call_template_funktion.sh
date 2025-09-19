#!/usr/bin/env bash

# ========================================================================================
# Bash-Call-Template-Function
#
# This Bash function dynamically determines a template function’s name (using either a full name or a base name plus suffix), passes along any extra arguments, and invokes it if it exists, otherwise showing an optional warning.
#
# @author      : Marcel Gräfen
# @version     : 0.0.1
# @date        : 2025-08-10
#
# @requires    : Bash 4.0+
#
# @see         : https://github.com/Marcel-Graefen/Bash-Call-Template-Function.git
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================

#----------------------- EXTERNAL GLOBAL VARIABLES --------------------------------------

# SHOW_WARNING          : treu or false (default: true)

: "${SHOW_WARNING:=true}"

#----------------------------------------------------------------------------------------

# FUNCTION: call_template_funktion
# Dynamically resolves and calls a template function based on a given name and optional suffix.
#
# Arguments:
#   $1 - Template name (full name including "__temp_" or base name without suffix)
#   $2 - Template suffix (only used if $1 does not already contain "__temp_")
#   $@ - Additional arguments to pass to the template function
#
# Output:
#   - Prints the output of the called template function to stdout
#   - Returns the exit status of the template function if found
#   - Returns 2 and optionally prints a warning if the template function does not exist
#
# Notes:
#   - If $1 already contains "__temp_", it is treated as the complete function name
#   - If not, the function name is constructed as "<base_name>__temp_<suffix>"
#   - The global variable SHOW_WARNING can be set to "false" to suppress the not-found warning
#   - Function lookup is case-sensitive

call_template_funktion() {

  local all_args=("$@")
  local temp_name="$1"
  local temp_suffix="$2"
  local args_to_pass=()
  local template=""

  if [[ "$temp_name" =~ __temp_ ]]; then
    args_to_pass=("${all_args[@]:1}")
    template="$temp_name"
  else
    args_to_pass=("${all_args[@]:2}")
    template="${temp_name}__temp_${temp_suffix}"
  fi

  if declare -f "$template" >/dev/null 2>&1; then
    echo "$("$template" "${args_to_pass[@]}")"
    return $?
  else
    [[ "$SHOW_WARNING" != "false" ]] && echo "⚠️ WARNING: The Template: ${template} not found!"
    return 2
  fi

}

#----------------------------------------------------------------------------------------
# Only execute the following code if the script is run directly.
# $0 is the name of the script.
# The first argument of the script is used here to check if the script was included via `source`.
# The script recognizes that it was included via `source` because `$BASH_SOURCE` does not match `$0`.
# The environment variable `$BASH_SOURCE` contains the path to the current script, even when called with `source`.
# `$0` always contains the name of the script that is executing the current shell.
# In a standard shell, `$0` and `$BASH_SOURCE` are the same when you execute the script directly.
# When you include the script via `source`, `$BASH_SOURCE` is the script you are including, and `$0` is the main script.
#----------------------------------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "⚠️ WARNING: This script is a library designed to be sourced." >&2
  echo "       It is not intended for direct execution." >&2
  echo "       Please refer to the documentation for proper usage." >&2
  echo "       --> [README.md]" >&2
  exit 1
fi

#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------

# EXAMPLE


# # 1. Template function name already complete

# hello__temp_upper() {
#   echo "${1^^}"
# }

# # Call with full template name
# call_template_funktion "hello__temp_upper" "" "world"
# # Output: WORLD

#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------

# # 2. Template function built from base name + suffix

# greet__temp_formal() {
#   echo "Good day, $1."
# }

# # Call with base name and suffix
# call_template_funktion "greet" "formal" "Marcel"
# # Output: Good day, Marcel.

#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------

# # 3. Passing multiple arguments

# sum__temp_calc() {
#   local total=0
#   for num in "$@"; do
#     (( total += num ))
#   done
#   echo "$total"
# }

# # 3 + 5 + 7 = 15
# call_template_funktion "sum" "calc" 3 5 7
# # Output: 15

#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------

# # 4. Template not found → Warning

# SHOW_WARNING=true
# call_template_funktion "unknown" "template" "test"
# # Output: ⚠️ WARNING: The Template: unknown__temp_template not found!
# # Return code: 2

#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------

# # 5. Suppressing the warning

# SHOW_WARNING=false
# call_template_funktion "unknown" "template" "test"
# # No output
# # Return code: 2
