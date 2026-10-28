#!/bin/bash
set -e
set -x

GITHUB_TOKEN="$1"
REPOSITORY="$2"
ISSUE_NUMBER="$3"
OPENAI_API_KEY="$4"

fetch_issue_details() {
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
         "https://api.github.com/repos/$REPOSITORY/issues/$ISSUE_NUMBER"
}

send_prompt_to_chatgpt() {
curl -s -X POST "https://models.github.ai/inference/chat/completions" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"model\": \"openai/gpt-4o-mini\", \"messages\": $MESSAGES_JSON, \"max_tokens\": 2000, \"response_format\": {\"type\": \"json_object\"}}"
}

save_to_file() {
    local filename="autocoder-bot/$1"
    local code_snippet="$2"
    mkdir -p "$(dirname "$filename")"
    echo -e "$code_snippet" > "$filename"
    echo "The code has been written to $filename"
}

RESPONSE=$(fetch_issue_details)
ISSUE_BODY=$(echo "$RESPONSE" | jq -r .body)

if [[ -z "$ISSUE_BODY" ]]; then
    echo 'Issue body is empty or not found in the response.'
    exit 1
fi

INSTRUCTIONS="Based on the description below, please generate a JSON object where the keys represent file paths and the values are the corresponding code snippets for a production-ready application. The response should be a valid strictly JSON object without any additional formatting, markdown, or characters outside the JSON structure."

FULL_PROMPT="$INSTRUCTIONS\n\n$ISSUE_BODY"

MESSAGES_JSON=$(jq -n --arg body "$FULL_PROMPT" '[{"role": "user", "content": $body}]')

RESPONSE=$(send_prompt_to_chatgpt)

if [[ -z "$RESPONSE" ]]; then
    echo "No response received from the API."
    exit 1
fi

FILES_JSON=$(echo "$RESPONSE" | jq -e '.choices[0].message.content | fromjson' 2> /dev/null)

if [[ -z "$FILES_JSON" ]]; then
    echo "No valid JSON dictionary found in the response or the response was not valid JSON. Please rerun the job."
    exit 1
fi

for key in $(echo "$FILES_JSON" | jq -r 'keys[]'); do
    FILENAME=$key
    CODE_SNIPPET=$(echo "$FILES_JSON" | jq -r --arg key "$key" '.[$key]')
    CODE_SNIPPET=$(echo "$CODE_SNIPPET" | sed 's/\r$//')
    save_to_file "$FILENAME" "$CODE_SNIPPET"
done

echo "All files have been processed successfully."
