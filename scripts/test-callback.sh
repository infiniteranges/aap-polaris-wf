#!/bin/bash
# Test callback endpoint script

set -e

CALLBACK_URL="${1:-http://localhost:3000/api/orchestration/callbacks}"
ENDPOINT="${2:-plan_success}"

echo "Testing callback endpoint: ${CALLBACK_URL}/${ENDPOINT}"
echo ""

# Sample callback payload
PAYLOAD=$(cat <<EOF
{
  "deploymentId": "test-deployment-$(date +%s)",
  "executionId": "$(date +%s)",
  "aapWorkflowJobId": 1234,
  "phase": "plan",
  "status": "success",
  "outputs": {},
  "error": null,
  "planOutput": "Plan: 5 to add, 0 to change, 0 to destroy.",
  "terraformRunId": null,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)

echo "Payload:"
echo "$PAYLOAD" | jq .
echo ""

# Send callback
RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -X POST "${CALLBACK_URL}/${ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS/d')

echo "Response Status: $HTTP_STATUS"
echo "Response Body:"
echo "$BODY" | jq . 2>/dev/null || echo "$BODY"

if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 300 ]; then
    echo ""
    echo "✓ Callback test successful!"
    exit 0
else
    echo ""
    echo "✗ Callback test failed!"
    exit 1
fi
