# Install required packages
sudo apt-get update
sudo apt-get install -y jq curl

echo "Fetching issues..."

# Filtering only open issue
ISSUES=$(curl -s -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" -G "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues" --data-urlencode 'state=open' --data-urlencode 'filter=all')

# No Open Issues
if [ -z "$ISSUES" ]; then
    echo "No open issues."
    exit 0
fi
# Iterate through the issues
echo "$ISSUES" | jq -r '.[] | select(.pull_request == null) | @base64' | while read -r issue_enc; do
    issue=$(echo "$issue_enc" | base64 --decode)

    # Check if the issue was updated within the last hour
    updated_at=$(echo "$issue" | jq -r ".updated_at")
    updated_ts=$(date -d "$updated_at" +%s)
    current_ts=$(date +%s)
    hour_past_ts=$((current_ts - 3600)) # In Seconds

    # Variables
    issue_number=$(echo "$issue" | jq -r ".number")
    assignee=$(echo "$issue" | jq -r ".assignee.login // \"unassigned\"")
    issue_title=$(echo "$issue" | jq -r ".title")
    issue_description=$(echo "$issue" | jq -r ".body")
    issue_url=$(echo "$issue" | jq -r ".html_url")
    issue_details="{\"issue_number\": \"$issue_number\", \"issue_title\": \"$issue_title\", \"issue_description\": \"$issue_description\", \"issue_url\": \"$issue_url\", \"updated_at\": \"$updated_at\", \"assignee\": \"$assignee\"}"

    # Updated Issues
    if [ $updated_ts -gt $hour_past_ts ]; then
        echo "Issue #${issue_number} is updated."
        continue
    fi

    # Non-Updated Issues
    echo "Issue #${issue_number} is not updated. Assignee: ${assignee}"
    echo $issue_details

    assignee=$(echo "$issue" | jq -r ".assignee.login | select(.!=null)")
    email=$(echo "$issue" | jq -r ".user.login")

    # Unassigned Issues
    if [ $email == "unassigned" ]; then
        echo "Issue #${issue_number} has no assignee."
    fi

    # Sending POST Request to Azure Logic App
    if [ $updated_ts -lt $hour_past_ts ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$issue_details" $EMAIL_NOTIFICATION_URL)
        echo "Response from Azure Logic App"
        echo $response
    else
        echo "No issue to send email."
    fi
done
