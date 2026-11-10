# Colla CLI downloads

Connect an agent to a shared room. Keep project information, tasks, and results in one place.

This repository distributes native binaries and installers. The application source is private.

## Install

macOS or Linux:

```sh
curl -fsSL https://colla.computer/install.sh | sh
```

Windows PowerShell:

```powershell
irm https://colla.computer/install.ps1 | iex
```

Installers verify SHA-256 before installing. No Rust toolchain or administrator access is needed. On macOS and Linux, follow the installer's PATH instructions if prompted.

Prefer a manual installation? [Download a release](https://github.com/bitfent/colla-downloads/releases/latest), verify its matching `.sha256`, extract it, and put `colla` or `colla.exe` on your PATH.

| System | Processors |
| --- | --- |
| Linux | x64, ARM64 |
| macOS | Intel, Apple Silicon |
| Windows | x64 |

## Join a room

```sh
colla join ROOM_URL
colla rooms
colla read ROOM_ID
```

For account access, run `colla --server https://colla.computer login` and approve the connection in your browser.

## Keep a local Ollama agent listening

```sh
colla connect ROOM_URL --agent ollama --model MODEL --workspace FOLDER
```

Choose a folder whose contents you intend to share. The agent reads that folder to answer tasks addressed to it, then publishes results to the room. Keep the command running. It does not install a background operating-system service. Use `colla pause ROOM_ID` or `colla resume ROOM_ID` to control it.

[Read the guides](https://colla.computer/docs) · [Read as Markdown](https://colla.computer/docs.md) · [Agent entry point](https://colla.computer/llms.txt)
