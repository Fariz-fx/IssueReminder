# Notify Inactive Issues

The Notify Inactive Issues is designed to help you stay updated by sending email notifications(Using Azure Logic App via POST Request) for inactive open issues in your GitHub repository.

Note: This action will post request, you can create Azure Logic app and use Send Email Action in it to send email or using the POST request you can setup notification in your own way.

## Features

- Sends email notifications for inactive open issues based on the specified update time interval.
- Allows customization of settings like cron schedule, consolidated email or separate emails, and label/milestone filters.
- Provides control over the update time interval based on issue severity.
- Works seamlessly with Azure Logic App or any other integration.

## Usage

To use this GitHub Action, follow these steps:

### Step 1: Set up Azure Logic App (or any other email integration)

Before using this action, you need to set up your email integration using Azure Logic App or any other solution. Obtain the email notification URL provided by your email integration service.

If you are using Azure Logic App, then create a trigger using the HTTP POST method and save it, you can see an URL, you can use that by going to your GitHub Repo -> Secret and Create Repository Secret and naming it ISSUE_LOGICAPP_URL and saving it.

### Step 2: Create a workflow file

In your repository, create a workflow file (e.g., `.github/workflows/notify_inactive_issues.yml`) and define the workflow using the Notify Inactive Issues GitHub Action.

#### Example workflow file

```yaml
name: Notify Inactive Issues

on:
    schedule:
        - cron: '*0 * * * *' # Specify the cron schedule for the workflow

env:
    GITHUBTOKEN: ${{ secrets.GITHUBTOKEN }}
    EMAILNOTIFICATIONURL: ${{ secrets.ISSUELOGICAPPURL }}

jobs:
    notifyinactiveissues:
        runs-on: ubuntu-latest

        steps:
            - name: Check and notify inactive issues
              uses: actions/checkout@v2
              with:
                ref: ${{ github.event.inputs.ref }}

            - name: Run Notify Inactive Issues GitHub Action
              uses: Fariz-fx/IssueReminder@v1.0.1
              with:
                schedule: '*0 * * * *' # Specify the cron schedule for the action
                consolidated_email: 'false' # Specify 'true' for consolidated email or 'false' for separate emails
                updated_time: '1 hour' # Specify the default update time interval (e.g., 1 hour)
                label_filter: 'bug,help wanted' # Specify labels to filter the issues (optional)
                milestone_filter: '123' # Specify the milestone ID to filter the issues (optional)
```

### Step 3: Configure the action inputs

In the example above, you can customize the following inputs:

- `schedule`: Set the cron schedule for the action. By default, it is set to trigger at the start of every hour (`*0 * * * *`), but you can modify it as per your requirements.
- `consolidated_email`: Set it to `true` if you want a single consolidated email. Set it to `false` if you want separate emails for each issue.
- `updated_time`: Set the default update time interval. You can specify different intervals based on issue severity by modifying the action code.
- `label_filter`: Specify labels to filter the issues. Use comma-separated values if you want to filter issues by multiple labels. This input is optional.
- `milestone_filter`: Specify the milestone ID to filter the issues. This input is optional.

### Step 4: Store secrets

Make sure to store your email notification URL (obtained from your email integration service) as a secret in your GitHub repository using the name `ISSUE_LOGICAPP_URL`. Refer to the GitHub documentation for more details on storing secrets.

## Use Cases

The Notify Inactive Issues GitHub Action can be used in various situations, such as:

- Monitoring inactive open issues to ensure timely responses and actions.
- Keeping track of unassigned issues or issues without any updates.
- Sending consolidated or separate email notifications based on your preferences.
- Customizing the update time interval based on issue severity (e.g., high severity issues get more frequent updates).

## Limitations

- The action relies on the GitHub API to fetch the issues, so it's limited to the permissions and rate limits of the API.
- The action requires a configured email integration (e.g., Azure Logic App) to send the email notifications.

## Contributing

Contributions are welcome! If you have any suggestions, feature requests, or bug reports, please open an issue or submit a pull request on the GitHub repository.

### Note: Create PR for Dev Branch only not main

## License

This GitHub Action is licensed under the [MIT License](LICENSE).
