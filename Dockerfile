# Build the k6 binary with the extension
# https://github.com/grafana/k6-operator?tab=readme-ov-file#using-extensions
FROM golang:1.20 as builder

RUN go install go.k6.io/xk6/cmd/xk6@latest
# For our example, we'll add support for output of test metrics to InfluxDB v2.
# Feel free to add other extensions using the '--with ...'.
RUN xk6 build v0.49.0 \
    --with github.com/LeonAdato/xk6-output-statsd \
    --with github.com/grafana/xk6-dashboard@latest \
    --output /k6

# Use the operator's base image and override the k6 binary
FROM grafana/k6:0.49.0
COPY --from=builder /k6 /usr/bin/k6
USER 0
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
