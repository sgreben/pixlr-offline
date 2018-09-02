FROM golang:1.11-alpine AS build
WORKDIR /go/src/app
COPY . .
ENV CGO_ENABLED 0
RUN go run vendor/github.com/gobuffalo/packr/packr/main.go -ldflags="-s -w" build -o /app

FROM scratch
COPY --from=build /app /app
ENTRYPOINT ["/app"]
