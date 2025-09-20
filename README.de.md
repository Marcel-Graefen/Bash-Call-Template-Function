# 📋 Bash-Funktion: Function Call Manager

[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.02-blue.svg)](./Versions/v1.0.0-beta.01/README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-≥4.3-green.svg)]()
[![jq](https://img.shields.io/badge/jq-required-orange.svg)]()

`function_call_manager` ist eine Bash-Funktion zum **dynamischen Aufruf von Funktionen mit Parameterübergabe**, Fehlerbehandlung und globaler Rückgabe via JSON.

---

## 📖 Inhaltsverzeichnis

* [✨ Funktionen & Features](#-funktionen--features)
* [⚙️ Anforderungen](#-anforderungen)
* [📦 Installation](#-installation)
* [🚀 Schnellstart](#-schnellstart)
  * [📚 Detaillierte Nutzung](#-detaillierte-nutzung)
  * [⚡ API-Referenz](#-api-referenz)
  * [🔧 Parameter-Format](#-parameter-format)
  * [❌ Fehlerbehandlung](#-fehlerbehandlung)
  * [🔄 Return-Codes](#-return-codes)
  * [⚠️ Einschränkungen](#-einschränkungen)
  * [💡 Best Practices](#-best-practices)
  * [🐛 Troubleshooting](#-troubleshooting)
* [🤖 Hinweis zur Erstellung](#-hinweis-zur-erstellung)
* [📜 Lizenz](#-lizenz)

---

## ✨ Funktionen & Features

| Icon | Feature | Beschreibung |
|------|---------|-------------|
| 🎯 | Dynamische Aufrufe | Funktionen mit JSON-Parametern aufrufen |
| ⚡ | Fehlerbehandlung | Optionaler Abbruch bei Funktionsfehlern |
| 💾 | Globale Speicherung | Ergebnisse als JSON in Variable speichern |
| 🔄 | Mehrere Funktionen | Mehrere Funktionen in einem Aufruf |
| 🏷️ | Parameter Parsing | Flags, Positionsargumente, Boolean-Flags |
| 🔧 | jq-Integration | Automatische JSON-Verarbeitung |
| 📊 | Detaillierte Rückgabe | Return-Codes, Parameter, Output |

---

## ⚙️ Anforderungen

**Voraussetzungen:**
- 🐚 **Bash ≥ 4.3**
- 📦 **jq** installiert:

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

**Option 1: Direkt im Script definieren**
```bash
#!/usr/bin/env bash

# Funktion einfügen
function_call_manager() {
  # [Hier den kompletten Funktionscode einfügen]
}
```

**Option 2: Als separate Datei einbinden**
```bash
source "/pfad/zu/function_call_manager.sh"
```

---

## 🚀 Schnellstart

**1. Funktion definieren:**
```bash
hello_world() {
  local params="$1"
  local name=$(echo "$params" | jq -r '.name // .arg0 // "Welt"')
  echo "{\"message\": \"Hallo, $name!\"}"
  return 0
}
```

**2. Funktion aufrufen:**
```bash
function_call_manager -f "hello_world --name Bash" -o result
```

**3. Ergebnis anzeigen:**
```bash
echo "$result" | jq .
```

---

## 📚 Detaillierte Nutzung

### 💡 Einzelner Funktionsaufruf
```bash
function_call_manager -f "meine_funktion --param1 wert1 --flag" -o ergebnis
```

### 📦 Mehrere Funktionen
```bash
function_call_manager \
  -f "funktion_a --x 1" \
  -f "funktion_b --y 2" \
  -o ergebnisse
```

### 🎯 Komplexes Beispiel
```bash
# Funktionen definieren
calculate() {
  local params="$1"
  local a=$(echo "$params" | jq -r '.a // .arg0 // 0')
  local b=$(echo "$params" | jq -r '.b // .arg1 // 0')
  echo "{\"result\": $((a + b))}"
  return 0
}

# Aufruf mit verschiedenen Parametern
function_call_manager \
  -f "calculate --a 10 --b 5" \
  -f "calculate 20 30" \
  -o results

# Ergebnisse auslesen
echo "$results" | jq .
```

---

## ⚡ API-Referenz

### 📋 Kommandozeilen-Parameter

| Parameter | Alias | Beschreibung | Optional | Mehrfach |
|-----------|-------|-------------|----------|----------|
| `-f` | `--function` | Funktion aufrufen | ❌ | ✅ |
| `-o` | `--output` | Zielvariable | ❌ | ❌ |
| `-e` | `--on-func-error` | Fehlerabbruch | ✅ | ❌ |

### 🏷️ Funktions-Syntax
```
"funktionsname [parameter]"
```

**Beispiele:**
- `"meine_funktion"`
- `"meine_funktion arg1 arg2"`
- `"meine_funktion --param wert --flag"`
- `"meine_funktion -a value -b"`

---

## 🔧 Parameter-Format

### 📋 Unterstützte Parameter-Typen

| Typ | Beispiel | JSON-Output |
|-----|----------|-------------|
| 🔹 Positionell | `"func arg1 arg2"` | `{"arg0": "arg1", "arg1": "arg2"}` |
| 🔧 Named mit Wert | `"func --param wert"` | `{"--param": "wert"}` |
| ✅ Boolean Flag | `"func --flag"` | `{"--flag": true}` |
| 🔢 Numerische Werte | `"func --number 42"` | `{"--number": 42}` |

### 🎯 Gemischte Parameter
```bash
# Wird zu: {"arg0": "file.txt", "--output": "result.json", "--force": true}
"process file.txt --output result.json --force"
```

---

## ❌ Fehlerbehandlung

### 🔄 Standard-Verhalten
```bash
function_call_manager -f "fehlerhafte_funktion" -o result
# Läuft weiter, Return-Code 0
```

### ⚡ Mit Fehlerabbruch
```bash
function_call_manager -f "fehlerhafte_funktion" -e -o result
# Brich bei Fehler ab, Return-Code = Funktions-Return-Code
```

### 📋 Fehler-Output Format
```json
{
  "function": "funktionsname",
  "payload": {"parameter": "wert"},
  "output": "Fehlermeldung",
  "return": 127
}
```

---

## 🔄 Return-Codes

| Code | Bedeutung | Beschreibung |
|------|-----------|-------------|
| 🟢 0 | Erfolg | Alles erfolgreich |
| 🔴 1 | Allgemeiner Fehler | jq fehlt, keine Parameter |
| 🔴 2 | Funktion existiert nicht | Funktion nicht gefunden |
| 🔴 N | Funktions-Fehler | Return-Code der fehlgeschlagenen Funktion |

---

## ⚠️ Einschränkungen

| Einschränkung | Beschreibung |
|---------------|-------------|
| 🔄 Globale Funktionen | Nur global verfügbare Funktionen |
| 📏 Parameter-Limits | Bash-übliche Limits |
| 📊 JSON-Output | Empfohlen für beste Ergebnisse |
| 🌍 Globale Variablen | Überschreibt Zielvariable |
| ⏩ Sequential | Keine Parallelverarbeitung |

---

## 💡 Best Practices

### 🏗️ Empfohlene Funktions-Struktur
```bash
beispiel_funktion() {
  local params="$1"

  # Parameter extrahieren
  local param1=$(echo "$params" | jq -r '.param1 // .arg0 // "default"')

  # Immer JSON ausgeben
  echo "{\"status\": \"success\", \"data\": \"$param1\"}"

  return 0
}
```

### 🛡️ Fehlerbehandlung
```bash
sichere_funktion() {
  local params="$1"

  # Validierung
  if ! validate_input "$params"; then
    echo "{\"error\": \"Ungültige Eingabe\"}"
    return 1
  fi

  # Logik
  echo "{\"success\": true}"
  return 0
}
```

---

## 🐛 Troubleshooting

### ❌ Häufige Probleme

**1. jq nicht installiert**
```bash
sudo apt-get install jq
```

**2. Funktion nicht gefunden**
```bash
declare -f funktionsname  # Prüfen ob Funktion existiert
```

**3. Parameter werden nicht erkannt**
- Flags müssen mit `-` beginnen
- Positionelle Parameter ohne `-`

**4. JSON-Parsing Fehler**
- Immer valides JSON ausgeben
- Nicht-JSON wird als String gewrapped

### 🔍 Debugging
```bash
# Debug-Modus
set -x
function_call_manager -f "test" -o result
set +x

# JSON validieren
echo "$result" | jq . >/dev/null && echo "✅ Valides JSON" || echo "❌ Ungültiges JSON"
```

---

## 🤖 Hinweis zur Erstellung

Dieses Projekt wurde mit Unterstützung einer Künstlichen Intelligenz (KI) erstellt. Die KI half bei Skript, Kommentaren und Dokumentation (README.md). Das Endergebnis wurde von mir geprüft und angepasst.

---

## 📜 Lizenz

[MIT Lizenz](LICENSE)
