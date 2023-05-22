# gcp-function-to-bigquery

Example project to have a public gcp function that just streams to bigquery

```bash
# start function locally
functions-framework --target=stream_to_bigquery --source=./terraform/python-functions/stream_to_bigquery/main.py --port=8080
```

```bash
# send event to locally running function
curl -d '{"k1":"foo_local", "k2":"bar_local"}' -H "Content-Type: application/json" -X POST http://localhost:8080
```

```bash
# send event to function running in cloud
curl -d '{"k1":"foo_cloud", "k2":"bar_cloud"}' -H "Content-Type: application/json" -X POST https://us-east1-andrewm4894.cloudfunctions.net/stream_to_bigquery
```
