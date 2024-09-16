#!/bin/bash

# Define variables
URL="http://localhost:8080/bidder/?bid=aaaaa"
JSON_DATA='{
  "id": "1234567893",
  "imp": [{
    "id": "1",
    "video": {
      "mimes": ["video/mp4"],
      "linearity": 1,
      "minduration": 5,
      "maxduration": 30,
      "protocol": [2, 5]
    }
  }],
  "site": {
    "page": ""
  },
  "device": {
    "carrier": "o2 - de1",
    "ip": "24.234.255.255",
    "dpidsha1": "AA000DFE74168477C70D291f574D344790E0BB11"
  },
  "user": {
    "uid": "456789876567897654678987656789",
    "buyeruid": "545678765467876567898765678987654"
  }
}'

OUTPUT_DIR="/var/lib/node_exporter/textfile_collector"
OUTPUT_FILE="$OUTPUT_DIR/rtb_test_bidder_metric.prom"
METRIC_NAME="rtb_test_bidder"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Initialize metric value
metric_value=0

# Send POST request using curl
response=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "$URL")

# Check if the request was successful
if [ $? -eq 0 ]; then
  # Extract the "id" value from the JSON response using jq
  id_value=$(echo "$response" | jq -r '.id')

  # Check if the id value matches the specified values
  if [[ "$id_value" == "1234567893" || "$id_value" == "e27605b1-ab55-4b2d-93c0-87953989f434" ]]; then
    # Set metric value to 1 if the id matches
    metric_value=1
  fi
fi

# Write the metric in Prometheus exposition format
echo "# HELP $METRIC_NAME Indicates if the bidder response is valid (1 for valid, 0 for invalid)" > "$OUTPUT_FILE"
echo "# TYPE $METRIC_NAME gauge" >> "$OUTPUT_FILE"
echo "$METRIC_NAME $metric_value" >> "$OUTPUT_FILE"
