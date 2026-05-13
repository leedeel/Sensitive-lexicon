# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Go-based HTTP service for detecting sensitive words in Chinese text. It uses a trie-based data structure (via the `fuzzy-patricia` library) for efficient substring and fuzzy matching of sensitive vocabulary.

## Architecture

- **`cmd/server/`** - Entry point: HTTP server with endpoints for detection, contains check, and lexicon reloading
- **`internal/detect/`** - Detection logic with both substring and fuzzy matching capabilities using n-grams
- **`internal/lexicon/`** - Thread-safe trie store that loads `.txt` vocabulary files from `Vocabulary/` directory

### Key Components

The `detect.Service` combines two matching strategies:
1. **Substring matching**: Finds any lexicon word that appears as a substring in the input text
2. **Fuzzy matching**: Generates n-grams from input text and finds lexicon words within edit distance (configurable)

The `lexicon.Store` wraps the `patricia.Trie` with:
- Concurrent-safe operations using `sync.RWMutex`
- Bulk loading from directory with UTF-8 safe line reading
- Substring and fuzzy search visitors

## Development Commands

### Build and Run
```bash
go mod tidy
go build -o bin/server ./cmd/server
./bin/server
```

### Test
```bash
go test ./...
```

### Run with environment variables
```bash
export PORT=8080
export LEXICON_DIR=Vocabulary
export FUZZY_MIN_NGRAM=2
export FUZZY_MAX_NGRAM=10
export FUZZY_MAX_DISTANCE=1
./bin/server
```

### Docker
```bash
docker build -t sensitive-lexicon .
docker run -p 8080:8080 sensitive-lexicon
```

## HTTP API

- **POST /detect** - Detect sensitive words with optional fuzzy matching
  ```json
  {"text": "待检测文本", "enable_fuzzy": true}
  ```

- **POST /contains** - Quick check if text contains any sensitive word
  ```json
  {"text": "待检测文本"}
  ```

- **POST /reload** - Reload lexicon from `LEXICON_DIR`

- **GET /health** - Health check endpoint

## Vocabulary Files

The `Vocabulary/` directory contains `.txt` files with Chinese sensitive words, one per line. Lines starting with `#` are ignored. Files are loaded recursively on startup and via `/reload`.

## CI/CD

- GitHub Actions (`.github/workflows/server.yml`): Multi-platform builds (linux/amd64, linux/arm64) and releases to GHCR
- Jenkins pipeline builds Docker images and deploys via docker-compose to production

## Important Notes

- The code operates on rune boundaries for proper CJK character handling
- Fuzzy matching uses n-grams; configure `FUZZY_MIN_NGRAM`, `FUZZY_MAX_NGRAM`, and `FUZZY_MAX_DISTANCE` based on performance vs accuracy requirements
- The trie is rebuilt atomically on reload to avoid service interruption
