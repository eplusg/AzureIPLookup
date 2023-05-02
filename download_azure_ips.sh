#!/bin/bash
# Load environment variables from .env file
source .env

# Discord webhook URL (replace with your own webhook URL)
webhook_url="$WEBHOOK_URL"

# Get the download page content
page_content=$(curl -s 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519')

# Extract the download URL of the JSON file
download_url=$(echo "$page_content" | grep -oP 'href="\K(https://[^\"]+\.json)' | head -n 1)

# Download the JSON file
wget -O azure_ips_new.json "$download_url"

# Set the backup folder path and the maximum number of archived files to keep
backup_folder="/data/aztools/"
max_archived_files=3

# Check if the old file exists and move it to the backup folder with the current date
if [ -e "azure_ips.json" ]; then
  current_date=$(date +"%d%m%y")
  mv azure_ips.json "${backup_folder}azure_ips_backup_${current_date}.json"

  # Delete old backup files if there are more than max_archived_files
  num_archived_files=$(ls -1 ${backup_folder}azure_ips_backup_*.json | wc -l)
  if [ "$num_archived_files" -gt "$max_archived_files" ]; then
    files_to_delete=$((num_archived_files - max_archived_files))
    ls -t ${backup_folder}azure_ips_backup_*.json | tail -n $files_to_delete | xargs rm --
  fi
fi

# Replace the old file with the downloaded file
mv azure_ips_new.json azure_ips.json

# Send a message to the Discord channel using the webhook
curl -H "Content-Type: application/json" \
     -X POST \
     -d '{"content":"Script finished running, and the azure_ips.json file has been updated."}' \
     "$webhook_url"