#!/usr/bin/env bash

# ========================================================================================
#  Bash Function Call Manager
#
# This Bash function dynamically determines a template function’s name (using either a full name or a base name plus suffix), passes along any extra arguments, and invokes it if it exists, otherwise showing an optional warning.
#
# @author      : Marcel Gräfen
# @version     : 1.0.0-Beta.02
# @date        : 2025-09-19
#
# @requires    : Bash 4.0+
# @requires    : jq
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Call-Manager.git
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================



#---------------------- FUNCTION: function_call_manager ----------------------
#
# @version 1.0.0-beta.02
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
    echo "❌ [ERROR] No parameters provided" >&2
    return 1
  fi

  # --------- Default values ---------
  local output_var=""
  local function_strings=()
  local on_func_error=false

  # --------- Parse CLI arguments ---------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--function)      function_strings+=("$2"); shift 2 ;;
      -o|--output)        output_var="$2";          shift 2 ;;
      -e|--on-func-error) on_func_error=true;       shift   ;;
      *)  echo "❌ Unknown option: $1" >&2; return 1        ;;
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
    # Extract function name and parameters
    local func_name="${func_string%% *}"
    local func_params="${func_string#$func_name}"
    func_params="${func_params#" "}"

    # --------- Check if function exists ---------
    if ! declare -f "$func_name" > /dev/null 2>&1; then
      echo "❌ Error: Function '$func_name' does not exist!" >&2
      continue
    fi

    # --------- Build parameter JSON ---------
    local param_json_str='{}'
    if [[ -n "$func_params" ]]; then
      read -r -a params <<< "$func_params"
      local arg_index=0
      local idx=0

      # Parse each parameter token
      while [[ $idx -lt ${#params[@]} ]]; do
        token="${params[$idx]}"

        # Handle flags (starting with -)
        if [[ "$token" == -* ]]; then
          # Keep original flag name including all dashes
          key="$token"
          next_idx=$((idx+1))

          # Check if next token is a value (not another flag)
          if [[ $next_idx -lt ${#params[@]} && "${params[$next_idx]}" != -* ]]; then
            value="${params[$next_idx]}"

            # Handle numeric values vs strings
            if [[ "$value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
              param_json_str=$(jq --arg k "$key" --argjson v "$value" '. + {($k): $v}' <<< "$param_json_str")
            else
              param_json_str=$(jq --arg k "$key" --arg v "$value" '. + {($k): $v}' <<< "$param_json_str")
            fi
            idx=$((idx+1)) # Skip value token
          else
            # Boolean flag (no value following)
            param_json_str=$(jq --arg k "$key" '. + {($k): true}' <<< "$param_json_str")
          fi
        else
          # Positional argument (not a flag)
          if [[ "$token" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            param_json_str=$(jq --arg k "arg$arg_index" --argjson v "$token" '. + {($k): $v}' <<< "$param_json_str")
          else
            param_json_str=$(jq --arg k "arg$arg_index" --arg v "$token" '. + {($k): $v}' <<< "$param_json_str")
          fi
          arg_index=$((arg_index+1))
        fi
        idx=$((idx+1))
      done
    fi

    # --------- Execute function with JSON parameters ---------
    func_output=$("$func_name" "$param_json_str" 2>&1)
    func_return=$?

    # --------- Parse function output ---------
    local func_output_json
    if func_output_json=$(echo "$func_output" | jq . 2>/dev/null); then
      # Output is valid JSON, keep as is
      :
    else
      # Output is not JSON, wrap as string
      func_output_json=$(jq -n --arg out "$func_output" '$out')
    fi

    # --------- Update results JSON ---------
    # Check if function already exists in results
    if ! echo "$results_json" | jq --arg fn "$func_name" '.[$fn]' | grep -q "null"; then
      # Append to existing callback array
      results_json=$(jq --arg fn "$func_name" --argjson obj "$param_json_str" \
        '.[$fn].callback += [$obj]' <<< "$results_json")
    else
      # Create new function entry
      results_json=$(jq --arg fn "$func_name" --argjson obj "$param_json_str" \
        '.[$fn] = {"callback": [$obj], "return": 0}' <<< "$results_json")
    fi

    # Update return code
    results_json=$(jq --arg fn "$func_name" --argjson rc "$func_return" \
      '.[$fn].return = $rc' <<< "$results_json")

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

      declare -g "$output_var"="$results_json"
      echo "$error_obj" >&2
      return $func_return
    fi
  done

  # --------- Store final results in output variable ---------
  declare -g "$output_var"="$results_json"
  return 0
}




# # Test function
# test_func() {
#   local params="$1"
#   echo "Received: $params" >&2
#   echo '{"status": "success", "params": '"$params"'}'
#   return 0
# }

# # Test function
# test_func2() {
#   local params="$1"
#   echo "Received: $params" >&2
#   echo '{"status": "success", "params": '"$params"'}'
#   return 0
# }

# # Test call with 2-space indentation
# function_call_manager \
#   -f "test_func -v --verbose file.txt -n 42 hallo" \
#   -f "test_func2 -v --verbose file.txt -n 42 hallo" \
#   -o result

# echo "Test result:"
# echo "$result" | jq .
