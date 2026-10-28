# AutoCoder

AutoCoder è un progetto che usa GitHub Actions e ChatGPT per generare codice in automatico.

Un workflow di GitHub Actions esegue uno script che invia una richiesta all'API di ChatGPT, riceve il codice generato e lo salva nel repository.

## Struttura

- `.github/workflows/` – contiene i file dei workflow di GitHub Actions
- `scripts/` – contiene gli script che comunicano con ChatGPT
