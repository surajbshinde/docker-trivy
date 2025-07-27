# — Build stage: compile your app (example for Go; modify per language)
FROM golang:1.20-alpine AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o app

# — Final runtime stage with minimal base
FROM alpine:3.18

# Install only required runtime libs
RUN apk add --no-cache ca-certificates

# Create minimal non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=build /app/app .

# Permissions locked down
RUN chown -R appuser:appgroup /app

USER appuser

HEALTHCHECK --interval=30s --timeout=5s CMD ["/bin/sh", "-c", "ps aux | grep app || exit 1"]

EXPOSE 8080
ENTRYPOINT ["./app"]
