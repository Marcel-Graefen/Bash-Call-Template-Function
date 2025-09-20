# 📋 Bash Function: Function Call Manager

[![Deutsch](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.02-blue.svg)](./Versions/v1.0.0-beta.01/README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-≥4.3-green.svg)]()
[![jq](https://img.shields.io/badge/jq-required-orange.svg)]()

`function_call_manager` is a Bash function for **dynamically calling functions with parameter passing**, error handling, and global return via JSON.

---

## 📖 Table of Contents

* [✨ Features & Capabilities](#-features--capabilities)
* [⚙️ Requirements](#-requirements)
* [📦 Installation](#-installation)
* [🚀 Quick Start](#-quick-start)
  * [📚 Detailed Usage](#-detailed-usage)
  * [⚡ API Reference](#-api-reference)
  * [🔧 Parameter Format](#-parameter-format)
  * [❌ Error Handling](#-error-handling)
  * [🔄 Return Codes](#-return-codes)
  * [⚠️ Limitations](#-limitations)
  * [💡 Best Practices](#-best-practices)
  * [🐛 Troubleshooting](#-troubleshooting)
* [🤖 Creation Note](#-creation-note)
* [📜 License](#-license)

---

## ✨ Features & Capabilities

| Icon | Feature | Description |
|------|---------|-------------|
| 🎯 | Dynamic Calls | Call functions with JSON parameters |
| ⚡ | Error Handling | Optional abort on function errors |
| 💾 | Global Storage | Store results as JSON in variable |
| 🔄 | Multiple Functions | Multiple functions in one call |
| 🏷️ | Parameter Parsing | Flags, positional arguments, boolean flags |
| 🔧 | jq Integration | Automatic JSON processing |
| 📊 | Detailed Returns | Return codes, parameters, output |

---

## ⚙️ Requirements

**Prerequisites:**
- 🐚 **Bash ≥ 4.3**
- 📦 **jq** installed:

```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq

# CentOS/RHEL
sudo yum install jq
```

---

## 📦 Installation

**Option 1: Define directly in script**
```bash
#!/usr/bin/env bash

# Insert function
function_call_manager() {
  # [Insert complete function code here]
}
```

**Option 2: Include as separate file**
```bash
source "/path/to/function_call_manager.sh"
```

---

## 🚀 Quick Start

**1. Define function:**
```bash
hello_world() {
  local params="$1"
  local name=$(echo "$params" | jq -r '.name // .arg0 // "World"')
  echo "{\"message\": \"Hello, $name!\"}"
  return 0
}
```

**2. Call function:**
```bash
function_call_manager -f "hello_world --name Bash" -o result
```

**3. Show result:**
```bash
echo "$result" | jq .
```

---

## 📚 Detailed Usage

### 💡 Single Function Call
```bash
function_call_manager -f "my_function --param1 value1 --flag" -o result
```

### 📦 Multiple Functions
```bash
function_call_manager \
  -f "function_a --x 1" \
  -f "function_b --y 2" \
  -o results
```

### 🎯 Complex Example
```bash
# Define functions
calculate() {
  local params="$1"
  local a=$(echo "$params" | jq -r '.a // .arg0 // 0')
  local b=$(echo "$params" | jq -r '.b // .arg1 // 0')
  echo "{\"result\": $((a + b))}"
  return 0
}

# Call with different parameters
function_call_manager \
  -f "calculate --a 10 --b 5" \
  -f "calculate 20 30" \
  -o results

# Read results
echo "$results" | jq .
```

---

## ⚡ API Reference

### 📋 Command Line Parameters

| Parameter | Alias | Description | Optional | Multiple |
|-----------|-------|-------------|----------|----------|
| `-f` | `--function` | Call function | ❌ | ✅ |
| `-o` | `--output` | Target variable | ❌ | ❌ |
| `-e` | `--on-func-error` | Error abort | ✅ | ❌ |

### 🏷️ Function Syntax
```
"functionname [parameters]"
```

**Examples:**
- `"my_function"`
- `"my_function arg1 arg2"`
- `"my_function --param value --flag"`
- `"my_function -a value -b"`

---

## 🔧 Parameter Format

### 📋 Supported Parameter Types

| Type | Example | JSON Output |
|-----|----------|-------------|
| 🔹 Positional | `"func arg1 arg2"` | `{"arg0": "arg1", "arg1": "arg2"}` |
| 🔧 Named with value | `"func --param value"` | `{"--param": "value"}` |
| ✅ Boolean Flag | `"func --flag"` | `{"--flag": true}` |
| 🔢 Numeric values | `"func --number 42"` | `{"--number": 42}` |

### 🎯 Mixed Parameters
```bash
# Becomes: {"arg0": "file.txt", "--output": "result.json", "--force": true}
"process file.txt --output result.json --force"
```

---

## ❌ Error Handling

### 🔄 Default Behavior
```bash
function_call_manager -f "faulty_function" -o result
# Continues running, return code 0
```

### ⚡ With Error Abort
```bash
function_call_manager -f "faulty_function" -e -o result
# Aborts on error, return code = function return code
```

### 📋 Error Output Format
```json
{
  "function": "functionname",
  "payload": {"parameter": "value"},
  "output": "Error message",
  "return": 127
}
```

---

## 🔄 Return Codes

| Code | Meaning | Description |
|------|-----------|-------------|
| 🟢 0 | Success | Everything successful |
| 🔴 1 | General error | jq missing, no parameters |
| 🔴 2 | Function doesn't exist | Function not found |
| 🔴 N | Function error | Return code of failed function |

---

## ⚠️ Limitations

| Limitation | Description |
|---------------|-------------|
| 🔄 Global functions | Only globally available functions |
| 📏 Parameter limits | Bash-typical limits |
| 📊 JSON output | Recommended for best results |
| 🌍 Global variables | Overwrites target variable |
| ⏩ Sequential | No parallel processing |

---

## 💡 Best Practices

### 🏗️ Recommended Function Structure
```bash
example_function() {
  local params="$1"

  # Extract parameters
  local param1=$(echo "$params" | jq -r '.param1 // .arg0 // "default"')

  # Always output JSON
  echo "{\"status\": \"success\", \"data\": \"$param1\"}"

  return 0
}
```

### 🛡️ Error Handling
```bash
safe_function() {
  local params="$1"

  # Validation
  if ! validate_input "$params"; then
    echo "{\"error\": \"Invalid input\"}"
    return 1
  fi

  # Logic
  echo "{\"success\": true}"
  return 0
}
```

---

## 🐛 Troubleshooting

### ❌ Common Problems

**1. jq not installed**
```bash
sudo apt-get install jq
```

**2. Function not found**
```bash
declare -f functionname  # Check if function exists
```

**3. Parameters not recognized**
- Flags must start with `-`
- Positional parameters without `-`

**4. JSON parsing errors**
- Always output valid JSON
- Non-JSON gets wrapped as string

### 🔍 Debugging
```bash
# Debug mode
set -x
function_call_manager -f "test" -o result
set +x

# Validate JSON
echo "$result" | jq . >/dev/null && echo "✅ Valid JSON" || echo "❌ Invalid JSON"
```

---

## 🤖 Creation Note

This project was created with the assistance of Artificial Intelligence (AI). The AI helped with the script, comments, and documentation (README.md). The final result was reviewed and adapted by me.

---

## 📜 License

[MIT License](LICENSE)
