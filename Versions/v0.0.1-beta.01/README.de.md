# 📋 Bash-Funktion: Function Call Manager

[![Aktuellste Version](https://img.shields.io/badge/Aktuellste-Version-blue.svg)](../../README.md)
[![Englisch](https://img.shields.io/badge/Sprache-Englich-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.01-blue.svg)](./Versions/v1.0.0-beta.01/README.md)

`function_call_manager` ist eine Bash-Funktion zum **dynamischen Aufruf von Funktionen mit Parameterübergabe**, Fehlerbehandlung und globaler Rückgabe via JSON.

> ⚠️ Version **1.0.0-beta.01** ist **nicht abwärtskompatibel** zu vorherigen Implementierungen.

---

## 🚀 Inhaltsverzeichnis

* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Anforderungen](#-anforderungen)
* [📦 Installation](#-installation)
* [📌 Nutzung](#-nutzung)

  * [💡 Einzelner Funktionsaufruf](#-einzelner-funktionsaufruf)
  * [📦 Mehrere Funktionen](#-mehrere-funktionen)
  * [📊 Ausgabe & jq-Auslesung](#-ausgabe--jq-auslesung)
* [📌 API-Referenz](#-api-referenz)
* [🗂️ Changelog](#-changelog)
* [🤖 Hinweis zur Erstellung](#-hinweis-zur-erstellung)

---

## 🛠️ Funktionen & Features

* 🎯 **Dynamische Funktionsaufrufe:** Funktionen mit Parametern im JSON-Format aufrufen.
* ⚡ **Fehlerbehandlung:** Abbruch bei Fehlern, wenn `--on-func-error` gesetzt ist.
* 💾 **Globale Speicherung:** Ergebnisse werden als JSON in einer globalen Variable gespeichert.
* 🔄 **Mehrere Funktionen:** Mehrere Funktionen in einer Ausführung aufrufen.
* 💡 **Parameter Parsing:** Unterstützt Flags, Positionsargumente und Boolean-Flags.
* 🔧 **jq-Integration:** Parameter und Ausgaben werden automatisch in JSON konvertiert.

---

## ⚙️ Anforderungen

* 🐚 Bash ≥ 4.3
* `jq` installiert

---

## 📦 Installation

```bash
#!/usr/bin/env bash
source "/path/to/function_call_manager.sh"
```

---

## 📌 Nutzung

### 💡 Einzelner Funktionsaufruf

```bash
function_call_manager -f "meine_funktion --param1 wert1 --flag" -o ergebnis_var
```

**Erklärung:**
Ruft `meine_funktion` mit Parametern auf. Das Ergebnis wird als JSON in der globalen Variable `ergebnis_var` gespeichert.

---

### 📦 Mehrere Funktionen

```bash
function_call_manager \
  -f "func_a --x 1" \
  -f "func_b --y 2 --z 3" \
  -o ergebnisse
```

**Erklärung:**
Ruft `func_a` und `func_b` nacheinander auf. Die globale Variable `ergebnisse` enthält die JSON-Ergebnisse aller Funktionen.

---

### 📊 Ausgabe & jq-Auslesung

Angenommen, `ergebnisse` enthält:

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

**Werte auslesen mit `jq -r`:**

```bash
# Einzelner Wert aus func_a
echo "$ergebnisse" | jq -r '.func_a.callback[0].arg0'
# Ausgabe: 1

# Boolean-Flag aus func_a
echo "$ergebnisse" | jq -r '.func_a.callback[0]["--flag"]'
# Ausgabe: true

# Rückgabecode von func_b
echo "$ergebnisse" | jq -r '.func_b.return'
# Ausgabe: 0

# Alle Callback-Objekte von func_b
echo "$ergebnisse" | jq -r '.func_b.callback[] | @json'
# Ausgabe: {"arg0":"2","arg1":"3"}
```

---

## 📌 API-Referenz

| Beschreibung                | Argument / Alias         | Optional | Mehrfach | Typ    |
| --------------------------- | ------------------------ | -------- | -------- | ------ |
| Funktion(en) aufrufen       | `-f` / `--function`      | ❌        | ✅        | String |
| Zielvariable für Ergebnisse | `-o` / `--output`        | ❌        | ❌        | String |
| Fehlerabbruch aktivieren    | `-e` / `--on-func-error` | ✅        | ❌        | Flag   |
| Parameter als JSON          | automatisch              | –        | –        | JSON   |

**Ausgabe:** JSON-Objekt in der globalen Variable, z.B. `ergebnisse_var`.

---

## 🗂️ Changelog

**v1.0.0-beta.01**

* Neue Funktion `function_call_manager` ersetzt `call_template_funktion`.
* JSON-basiertes Parameter-Parsing und Ausgabe.
* Unterstützung von Boolean-Flags, mehreren Funktionen und sequentieller Ausführung.
* jq-basierte Ergebnis-Auslesung.
* ⚠️ **Nicht abwärtskompatibel**.

---

## 🤖 Hinweis zur Erstellung

Dieses Dokument wurde mit AI-Unterstützung erstellt und manuell auf Richtigkeit geprüft.
