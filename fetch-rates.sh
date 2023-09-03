#!/bin/bash

# URL pointing to latest currency rates, measured against the USD.
# $API_KEY is to be obtained from GitHub Actions' secret repository!
RATES_API_URL="https://api.currencybeacon.com/v1/latest?api_key=$API_KEY&base=USD"

# Fetch rates using curl, or exit gracefully.
data=$(curl -s "$RATES_API_URL" || (echo "Failed to fetch latest currency rates from the CurrencyBeacon API." && exit 1))

# Ensure that there is a response code of 200 within the returned JSON data:
response_code=$(echo "$data" | jq -r '.meta.code')
if [ "$response_code" -ne 200 ]; then
    echo "Failed to save rates' response to JSON; response code is not 200."
    exit 1
fi

# Get the current UNIX timestamp, and then save with rates_data.
timestamp=$(date +%s)
rates_data=$(echo "$data" | jq --arg timestamp "$timestamp" '.response | {timestamp: $timestamp | tonumber, base: .base, rates: .rates}')
echo "$rates_data" >"currency-rates.json"
echo "Currency data has been successfully written to currency-rates.json"
