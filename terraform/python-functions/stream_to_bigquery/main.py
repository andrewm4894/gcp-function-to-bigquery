from flask import Flask, request
from google.cloud import bigquery
from datetime import datetime, timezone


def stream_to_bigquery(request):
    
    # Ensure the request is a JSON POST
    if request.method != "POST" or not request.is_json:
        return "Invalid request", 400

    # Extract JSON data from request
    data = request.get_json(silent=True)

    # Return a 400 if no data present
    if data is None:
        return "Invalid data", 400
    
    # Add timestamp if it doesn't exist
    if 'timestamp' not in data:
        data['timestamp'] = datetime.now(timezone.utc).isoformat()

    data = [data]

    # Create BigQuery client
    client = bigquery.Client(project='andrewm4894')

    # Define BigQuery dataset and table
    dataset_id = 'telemetry_events'
    table_id = 'raw_events'
    table_ref = client.dataset(dataset_id).table(table_id)

    # Get BigQuery table
    table = client.get_table(table_ref)

    # Insert data into BigQuery
    errors = client.insert_rows_json(table, data)

    if errors:
        return "Failed to insert rows: {}".format(errors), 500
    else:
        return "Successfully inserted {} row(s)".format(len(data)), 200
