
#!/bin/zsh

# --- CONFIG ---
DEFAULT_DURATION="PT2H"  # ISO 8601 duration (2 hours)
JUSTIFICATION="Activating via zsh script"
TICKET_NUMBER=""
TICKET_SYSTEM=""

# --- FUNCTIONS ---
get_token() {
  echo "Getting Microsoft Graph token..."
  az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv
}

get_principal_id() {
  az ad signed-in-user show --query id -o tsv
}

list_roles() {
  local token=$1
  echo "Fetching eligible roles..."
  curl -s -X GET "https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilitySchedules?\$expand=roleDefinition" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    | jq -r '.value[] | "\(.roleDefinition.displayName) | RoleDefinitionId: \(.roleDefinitionId) | DirectoryScopeId: \(.directoryScopeId)"'
}

activate_role() {
  local token=$1
  local principal_id=$2
  local role_def_id=$3
  local scope_id=$4
  local now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  echo "Activating role..."
  curl -s -X POST "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignmentScheduleRequests" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d "{
      \"action\": \"selfActivate\",
      \"principalId\": \"$principal_id\",
      \"roleDefinitionId\": \"$role_def_id\",
      \"directoryScopeId\": \"$scope_id\",
      \"justification\": \"$JUSTIFICATION\",
      \"scheduleInfo\": {
        \"startDateTime\": \"$now\",
        \"expiration\": { \"type\": \"AfterDuration\", \"duration\": \"$DEFAULT_DURATION\" }
      }
    }"
}

# --- MAIN ---
TOKEN=$(get_token)
PRINCIPAL_ID=$(get_principal_id)

echo "\nEligible Roles:"
list_roles $TOKEN

echo "\nEnter RoleDefinitionId:"
read ROLE_DEF_ID
echo "Enter DirectoryScopeId (usually /):"
read SCOPE_ID

activate_role $TOKEN $PRINCIPAL_ID $ROLE_DEF_ID $SCOPE_ID
echo "\n✅ Activation request submitted."
