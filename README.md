# ⚙️ Bash Template Function Caller

![Version](https://img.shields.io/badge/version-0.0.1-blue.svg)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
![GitHub last commit](https://img.shields.io/github/last-commit/Marcel-Graefen/Bash-Template-Function-Caller)
[![Author](https://img.shields.io/badge/author-Marcel%20Gr%C3%A4fen-green.svg)](#-author--contact)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
![](https://komarev.com/ghpvc/?username=Marcel-Graefen)

A lightweight Bash utility for dynamically resolving and executing "template" functions based on a given base name or a complete function name, with optional suffix handling and argument forwarding.

---

## 📚 Table of Contents

  * [✨ Features](#-features)
  * [⚙️ Requirements](#%EF%B8%8F-requirements)
  * [📦 Installation](#-installation)
  * [🚀 Usage](#-usage)
      * [Full template name](#1-full-template-name)
      * [Base name + suffix](#2-base-name--suffix)
      * [Passing multiple arguments](#3-passing-multiple-arguments)
      * [Template not found warning](#4-template-not-found-warning)
      * [Suppressing warnings](#5-suppressing-warnings)
  * [📌 API Reference](#-api-reference)
      * [`call_template_funktion`](#call_template_funktion)
  * [👤 Author & Contact](#-author--contact)
  * [🤖 Generation Notice](#-generation-notice)
  * [📜 License](#-license)

---

## ✨ Features

* **Dynamic Template Resolution:** Automatically detects whether the provided name is a complete template function or needs a suffix appended.
* **Argument Forwarding:** Passes all additional arguments directly to the resolved function.
* **Optional Warnings:** Warns when a template is missing, with the ability to suppress warnings via a global flag.
* **Minimal Overhead:** Simple Bash-only solution with no external dependencies.
* **Plugin-Friendly:** Ideal for modular or pluggable Bash architectures.

---

## ⚙️ Requirements

* **Bash** version 4.0 or newer.

---

## 📦 Installation

Simply source the file containing the function into your Bash script:

```bash
#!/usr/bin/env bash

# Load the template function caller
source "/path/to/template_function_caller.sh"

# Your script logic here...
````

---

## 🚀 Usage

> [!note] If `$1` already contains the full function name including `__temp_ (e.g., hello__temp_upper)`, all other arguments ($@ from the second parameter onward) are passed unchanged to that function.

### **1. Full template name**

```bash
hello__temp_upper() {
  echo "${1^^}"
}

call_template_funktion "hello__temp_upper" "world"
# Output: WORLD
```

---

### **2. Base name + suffix**

```bash
greet__temp_formal() {
  echo "Good day, $1."
}

call_template_funktion "greet" "formal" "Marcel"
# Output: Good day, Marcel.
```

---

### **3. Passing multiple arguments**

```bash
sum__temp_calc() {
  local total=0
  for num in "$@"; do
    (( total += num ))
  done
  echo "$total"
}

call_template_funktion "sum" "calc" 3 5 7
# Output: 15
```

---

### **4. Template not found warning**

```bash
SHOW_WARNING=true
call_template_funktion "unknown" "template" "test"
# Output: ⚠️ WARNING: The Template: unknown__temp_template not found!
# Exit code: 2
```

---

### **5. Suppressing warnings**

```bash
SHOW_WARNING=false
call_template_funktion "unknown" "template" "test"
# No output
# Exit code: 2
```

---

## 📌 API Reference

### `call_template_funktion`

Dynamically resolves and calls a template function.

**Arguments:**

* `$1` — Template name (full name including `__temp_` or base name without suffix)
* `$2` — Template suffix (used only if `$1` does not already contain `__temp_`)
* `$@` — Additional arguments passed to the template function

**Output:**

* Prints the output of the template function to stdout
* Returns the exit code of the template function if found
* Returns `2` if the function does not exist

**Notes:**

* If `$1` already contains `__temp_`, it is treated as the complete function name
* If not, the function name is constructed as `<base_name>__temp_<suffix>`
* Set `SHOW_WARNING="false"` to suppress warnings

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Notice

This project was developed with the help of an Artificial Intelligence (AI). The AI assisted in creating the script, comments, and documentation (README.md). The final result was reviewed and adjusted by me.

---

## 📜 License

[MIT License](LICENSE)
