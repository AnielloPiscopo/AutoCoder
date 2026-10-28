# AutoCoder

AutoCoder is a reusable GitHub Action that generates code from GitHub issues using ChatGPT and opens a pull request with the generated code for review.

## How it works

1. Someone opens an issue with the `autocoder-bot` label (or your custom label). The issue body describes the files to generate and their content.
2. The action reads the issue, sends its body as a prompt to ChatGPT and saves the returned files in the `autocoder-bot/` directory.
3. The generated files are committed by `autocoder-bot` and a pull request is opened on the branch `autocoder-branch-<issue number>`.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `GITHUB_TOKEN` | yes | | Token used to read issues and create pull requests |
| `REPOSITORY` | yes | | Repository in `owner/repo` format |
| `ISSUE_NUMBER` | yes | | Number of the issue that triggered the action |
| `OPENAI_API_KEY` | yes | | API key for the ChatGPT service |
| `SCRIPT_PATH` | yes | `scripts/script.sh` | Path to the script that calls ChatGPT |
| `LABEL` | yes | `autocoder-bot` | Label that triggers the action |

## Outputs

| Output | Description |
|---|---|
| `pull_request_url` | URL of the created pull request |

## Usage

1. Add your API key as a repository secret named `OPENAI_API_KEY`.
2. In **Settings → Actions → General → Workflow permissions**, select **Read and write permissions** and enable **Allow GitHub Actions to create and approve pull requests**.
3. Create `.github/workflows/autocoder.yml`:

```yaml
name: AutoCoder

on:
  issues:
    types: [opened, reopened, labeled]

jobs:
  generate_code:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: read
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: AutoCoder
        uses: AnielloPiscopo/AutoCoder@v1.0.0
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          REPOSITORY: ${{ github.repository }}
          ISSUE_NUMBER: ${{ github.event.issue.number }}
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          LABEL: 'autocoder-bot'
```

4. Open an issue with the `autocoder-bot` label describing the files you want, for example:

```markdown
Create `calculator.py` with functions add, subtract, multiply and divide,
and `test_calculator.py` with unittest tests for each function.
```

## Repository structure

```
AutoCoder/
├── .github/workflows/main.yml   # Example workflow using the action
├── scripts/script.sh            # Script that calls ChatGPT and saves the files
├── action.yml                   # Action metadata
└── README.md
```
