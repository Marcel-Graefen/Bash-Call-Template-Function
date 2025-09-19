# 📋 Bash Function: Function Call Manager

[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.01-blue.svg)](./Versions/v1.0.0-beta.01/README.md)

`function_call_manager` is a Bash function for **dynamic function invocation with parameter passing**, error handling, and global JSON-based result storage.

> ⚠️ Version **1.0.0-beta.01** is **not backward compatible** with previous implementations.

---

## 🚀 Table of Contents

* [🛠️ Features](#-features)
* [⚙️ Requirements](#-requirements)
* [📦 Installation](#-installation)
* [📌 Usage](#-usage)

  * [💡 Single Function Call](#-single-function-call)
  * [📦 Multiple Functions](#-multiple-functions)
  * [📊 Output & jq Extraction](#-output--jq-extraction)
* [📌 API Reference](#-api-reference)
* [🗂️ Changelog](#-changelog)
* [🤖 Generation Note](#-generation-note)

---

## 🛠️ Features

* 🎯 **Dynamic Function Calls:** Call functions with parameters in JSON format.
* ⚡ **Error Handling:** Abort on function error if `--on-func-error` is set.
* 💾 **Global Storage:** Results stored as JSON in a global variable.
* 🔄 **Multiple Functions:** Call multiple functions sequentially in one execution.
* 💡 **Parameter Parsing:** Supports flags, positional arguments, and boolean flags.
* 🔧 **jq Integration:** Parameters and outputs automatically converted to JSON.

---

## ⚙️ Requirements

* 🐚 Bash ≥ 4.3
* `jq` installed

---

## 📦 Installation

```bash
#!/usr/bin/env bash
source "/path/to/function_call_manager.sh"
```

---

## 📌 Usage

### 💡 Single Function Call

```bash
function_call_manager -f "my_function --param1 value1 --flag" -o result_var
```

**Explanation:**
Calls `my_function` with parameters. The output is stored as JSON in the global variable `result_var`.

---

### 📦 Multiple Functions

```bash
function_call_manager \
  -f "func_a --x 1" \
  -f "func_b --y 2 --z 3" \
  -o results
```

**Explanation:**
Calls `func_a` and `func_b` sequentially. The global variable `results` contains JSON results of all functions.

---

### 📊 Output & jq Extraction

Suppose `results` contains:

```json
{
  "func_a": {
    "callback": [
      {
        "arg0": "1",
        "--flag": true
      }
    ],
    "return": 0
  },
  "func_b": {
    "callback": [
      {
        "arg0": "2",
        "arg1": "3"
      }
    ],
    "return": 0
  }
}
```

**Extract values using `jq -r`:**

```bash
# Single value from func_a
echo "$results" | jq -r '.func_a.callback[0].arg0'
# Output: 1

# Boolean flag from func_a
echo "$results" | jq -r '.func_a.callback[0]["--flag"]'
# Output: true

# Return code from func_b
echo "$results" | jq -r '.func_b.return'
# Output: 0

# All callback objects from func_b
echo "$results" | jq -r '.func_b.callback[] | @json'
# Output: {"arg0":"2","arg1":"3"}
```

---

## 📌 API Reference

| Description                | Argument / Alias         | Optional | Multiple | Type   |
| -------------------------- | ------------------------ | -------- | -------- | ------ |
| Function(s) to call        | `-f` / `--function`      | ❌        | ✅        | String |
| Target variable for output | `-o` / `--output`        | ❌        | ❌        | String |
| Enable error abort         | `-e` / `--on-func-error` | ✅        | ❌        | Flag   |
| Parameter JSON             | automatic                | –        | –        | JSON   |

**Output:** JSON object stored in the global variable, e.g., `results_var`.

---

## 🗂️ Changelog

**v1.0.0-beta.01**

* New function `function_call_manager` replaces `call_template_funktion`.
* JSON-based parameter parsing and output.
* Support for boolean flags, multiple functions, and sequential execution.
* jq-based result extraction.
* ⚠️ **Not backward compatible**.

---

## 🤖 Generation Note

This document was generated with AI assistance and manually reviewed for correctness.
