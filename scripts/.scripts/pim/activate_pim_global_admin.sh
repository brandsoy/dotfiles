
TOKEN=$(az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv) && \
curl -X POST https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignmentScheduleRequests \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{
  "action": "selfActivate",
  "principalId": "'"$(az ad signed-in-user show --query id -o tsv)"'",
  "roleDefinitionId": "62e90394-69f5-4237-9190-012177145e10",
  "directoryScopeId": "/",
  "justification": "Activating Global Admin via script",
  "scheduleInfo": {
    "startDateTime": "'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'",
    "expiration": { "type": "AfterDuration", "duration": "PT2H" }
  }
}'

