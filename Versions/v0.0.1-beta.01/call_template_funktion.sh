#!/usr/bin/env bash

# ========================================================================================
#  Bash Function Call Manager
#
# This Bash function dynamically determines a template function’s name (using either a full name or a base name plus suffix), passes along any extra arguments, and invokes it if it exists, otherwise showing an optional warning.
#
# @author      : Marcel Gräfen
# @version     : 1.0.0-Beta.01
# @date        : 2025-09-19
#
# @requires    : Bash 4.0+
# @requires    : jq
#
# @see         : https://github.com/Marcel-Graefen/Bash-Call-Template-Function.git
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================



#---------------------- FUNCTION: function_call_manager ----------------------
#
# @version 1.0.0-beta.01
#
# Dynamically executes one or more Bash functions with structured parameter parsing.
# Supports optional immediate exit on function error and captures output as JSON.
#
# Features:
#   - Executes multiple functions sequentially
#   - Parses parameters including flags and positional arguments
#   - Builds JSON objects for function parameters and outputs
#   - Optionally exits immediately if a function returns non-zero
#   - Stores all results in a global JSON variable
#
# GLOBAL VARIABLES:
#   None
#
# External programs used:
#   jq
#
# Internal functions used:
#   None (all handled internally)
#
# Arguments (OPTIONS):
#   -f|--function <FUNC_STRING>      Function name plus optional parameters (multiple allowed)
#   -o|--output <VAR_NAME>           Name of global variable to store JSON results
#   -e|--on-func-error               Exit immediately if a function returns non-zero
#
# Requirements:
#   Bash version >= 4.0
#   jq installed and available in PATH
#
# Returns:
#   0  on success
#   1  if required parameters are missing or invalid
#
# Notes:
#   - Designed to wrap and monitor function calls dynamically
#   - Captures both function output and return codes
#   - JSON output is structured for further programmatic use

function_call_manager() {

  # --------- Check jq installation ---------
  if ! command -v jq >/dev/null 2>&1; then
    echo "❌ Error: jq is not installed!" >&2
    return 1
  fi

  # --------- Check parameters ---------
  if [[ $# -eq 0 ]]; then
    echo "❌ [ERROR] No parameters provided"
    return 1
  fi

  # --------- Default values ---------
  local output_var=""
  local function_strings=()
  local on_func_error=false

  # --------- Parse CLI arguments ---------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--function) function_strings+=("$2"); shift 2 ;;
      -o|--output) output_var="$2"; shift 2 ;;
      -e|--on-func-error) on_func_error=true; shift ;;
      *) echo "❌ Unknown option: $1" >&2; return 1 ;;
    esac
  done

  # --------- Validate required options ---------
  if [[ ${#function_strings[@]} -eq 0 ]]; then
    echo "❌ Error: No function(s) provided!" >&2
    return 1
  fi

  if [[ -z "$output_var" ]]; then
    echo "❌ Error: No output variable specified!" >&2
    return 1
  fi

  # --------- Initialize results JSON ---------
  local results_json='{}'

  # --------- Execute each provided function ---------
  for func_string in "${function_strings[@]}"; do
    local func_name="${func_string%% *}"
    local func_params="${func_string#$func_name}"
    func_params="${func_params#" "}"

    # --------- Check if function exists ---------
    if ! declare -f "$func_name" > /dev/null 2>&1; then
      echo "❌ Error: Function '$func_name' does not exist!" >&2
      continue
    fi

    # --------- Build parameter JSON ---------
    declare -A param_json=()
    read -r -a params <<< "$func_params"
    local arg_index=0
    local idx=0
    while [[ $idx -lt ${#params[@]} ]]; do
      token="${params[$idx]}"
      if [[ "$token" == -* ]]; then
        key="$token"
        next_idx=$((idx+1))
        if [[ $next_idx -lt ${#params[@]} && "${params[$next_idx]}" != -* ]]; then
          param_json["$key"]="${params[$next_idx]}"
          idx=$((idx+1))  # skip value
        else
          param_json["$key"]=true  # boolean flag
        fi
      else
        param_json["arg$arg_index"]="$token"
        arg_index=$((arg_index+1))
      fi
      idx=$((idx+1))
    done

    # --------- Convert parameter array to JSON ---------
    local param_json_str="{}"
    for k in "${!param_json[@]}"; do
      val="${param_json[$k]}"
      param_json_str=$(echo "$param_json_str" | jq --arg k "$k" --argjson v "$(jq -n --arg vv "$val" '$vv')" '. + {($k): $v}')
    done

    # --------- Execute function ---------
    func_output=$("$func_name" "$param_json_str")
    func_return=$?

    # --------- Parse function output JSON ---------
    func_output_json=$(echo "$func_output" | jq . 2>/dev/null || jq -n --arg out "$func_output" '$out')

    # --------- Add callback to results ---------
    results_json=$(jq --arg fn "$func_name" \
      'if .[$fn]==null then .[$fn]={"callback":[],"return":0} else . end' <<< "$results_json")
    results_json=$(jq --arg fn "$func_name" --argjson obj "$param_json_str" --argjson rc "$func_return" \
      '.[$fn].callback = [$obj] | .[$fn].return = $rc' <<< "$results_json")

    # --------- Handle function error if enabled ---------
    if [[ $func_return -ne 0 && "$on_func_error" == "true" ]]; then
      error_obj=$(jq -n \
        --arg func "$func_name" \
        --argjson payload "$param_json_str" \
        --argjson output "$func_output_json" \
        --argjson rc "$func_return" \
        '{
          function: $func,
          payload: $payload,
          output: $output,
          return: $rc
        }')

      [[ -n "$output_var" ]] && declare -g "$output_var"="$results_json"
      echo "$error_obj" >&2
      exit $func_return
    fi

  done

  # --------- Store results in output variable ---------
  if [[ -n "$output_var" ]]; then
    declare -g "$output_var"="$results_json"
  fi

  return 0
}
