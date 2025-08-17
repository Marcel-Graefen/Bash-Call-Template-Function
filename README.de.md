# ⚙️ Bash Template Funktionsaufrufer

![Version](https://img.shields.io/badge/version-0.0.1-blue.svg)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
![GitHub last commit](https://img.shields.io/github/last-commit/Marcel-Graefen/Bash-Call-Template-Function)
[![Autor](https://img.shields.io/badge/Autor-Marcel%20Gr%C3%A4fen-green.svg)](#-autor--kontakt)
[![Lizenz](https://img.shields.io/badge/Lizenz-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Ein leichtgewichtiges Bash-Tool zum dynamischen Ermitteln und Ausführen von „Template“-Funktionen – entweder anhand eines vollständigen Funktionsnamens oder durch Kombination eines Basisnamens mit einem Suffix – inklusive Argumentweitergabe.

---

## 📚 Inhaltsverzeichnis

* [✨ Funktionen](#-funktionen)
* [⚙️ Voraussetzungen](#%EF%B8%8F-voraussetzungen)
* [📦 Installation](#-installation)
* [🚀 Verwendung](#-verwendung)

  * [Vollständiger Template-Name](#1-vollständiger-template-name)
  * [Basisname + Suffix](#2-basisname--suffix)
  * [Mehrere Argumente übergeben](#3-mehrere-argumente-%C3%BCbergeben)
  * [Warnung bei fehlendem Template](#4-warnung-bei-fehlendem-template)
  * [Warnungen unterdrücken](#5-warnungen-unterdr%C3%BCcken)
* [📌 API-Referenz](#-api-referenz)

  * [`call_template_funktion`](#call_template_funktion)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Hinweis zur Generierung](#-hinweis-zur-generierung)
* [📜 Lizenz](#-lizenz)

---

## ✨ Funktionen

* **Dynamische Template-Erkennung:** Erkennt automatisch, ob ein vollständiger Funktionsname übergeben wurde oder ob ein Suffix ergänzt werden muss.
* **Argumentweitergabe:** Alle weiteren Argumente werden direkt an die aufgerufene Template-Funktion übergeben.
* **Optionale Warnungen:** Gibt eine Warnung aus, wenn das Template fehlt (abschaltbar über globale Variable).
* **Minimaler Overhead:** Reine Bash-Lösung ohne externe Abhängigkeiten.
* **Plugin-freundlich:** Ideal für modulare oder pluggable Bash-Architekturen.

---

## ⚙️ Voraussetzungen

* **Bash** Version 4.0 oder neuer.

---

## 📦 Installation

Einfach die Datei mit der Funktion in dein Bash-Skript einbinden:

```bash
#!/usr/bin/env bash

# Template Funktionsaufrufer laden
source "/pfad/zu/template_function_caller.sh"

# Dein Skriptcode...
```

---

## 🚀 Verwendung

> [!NOTE] Falls `$1` bereits den vollständigen Funktionsnamen einschließlich `__temp_` enthält `(z. B. hello__temp_upper)`, werden alle weiteren übergebenen Argumente ($@ ab dem zweiten Parameter) unverändert an diese Funktion weitergeleitet.

### **1. Vollständiger Template-Name**

```bash
hello__temp_upper() {
  echo "${1^^}"
}

call_template_funktion "hello__temp_upper" "world"
# Ausgabe: WORLD
```

---

### **2. Basisname + Suffix**

```bash
greet__temp_formal() {
  echo "Guten Tag, $1."
}

call_template_funktion "greet" "formal" "Marcel"
# Ausgabe: Guten Tag, Marcel.
```

---

### **3. Mehrere Argumente übergeben**

```bash
sum__temp_calc() {
  local total=0
  for num in "$@"; do
    (( total += num ))
  done
  echo "$total"
}

call_template_funktion "sum" "calc" 3 5 7
# Ausgabe: 15
```

---

### **4. Warnung bei fehlendem Template**

```bash
SHOW_WARNING=true
call_template_funktion "unknown" "template" "test"
# Ausgabe: ⚠️ WARNUNG: Das Template: unknown__temp_template wurde nicht gefunden!
# Exit-Code: 2
```

---

### **5. Warnungen unterdrücken**

```bash
SHOW_WARNING=false
call_template_funktion "unknown" "template" "test"
# Keine Ausgabe
# Exit-Code: 2
```

---

## 📌 API-Referenz

### `call_template_funktion`

Ermittelt dynamisch und ruft eine Template-Funktion auf.

**Argumente:**

* `$1` — Template-Name (vollständiger Name inkl. `__temp_` oder Basisname ohne Suffix)
* `$2` — Template-Suffix (nur genutzt, wenn `$1` nicht bereits `__temp_` enthält)
* `$@` — Weitere Argumente, die an die Template-Funktion übergeben werden

**Ausgabe:**

* Gibt die Ausgabe der Template-Funktion auf `stdout` aus
* Gibt den Exit-Code der Template-Funktion zurück, falls gefunden
* Gibt `2` zurück, wenn die Funktion nicht existiert

**Hinweise:**

* Falls `$1` bereits `__temp_` enthält, wird er als vollständiger Funktionsname behandelt
* Ansonsten wird der Funktionsname als `<basisname>__temp_<suffix>` aufgebaut
* Mit `SHOW_WARNING="false"` lassen sich Warnungen unterdrücken

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Hinweis zur Generierung

Dieses Projekt wurde mit Unterstützung einer Künstlichen Intelligenz (KI) erstellt. Die KI half bei Skript, Kommentaren und Dokumentation (README.md). Das Endergebnis wurde von mir geprüft und angepasst.

---

## 📜 Lizenz

[MIT Lizenz](LICENSE)
