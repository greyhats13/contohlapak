FROM golang:1.15.2-alpine3.12 AS builder

RUN apk update && apk add --no-cache git

WORKDIR /app

COPY contohlapak /go/bin/contohlapak

FROM alpine:3.12

RUN apk add --no-cache tzdata

COPY --from=builder /go/bin/contohlapak /go/bin/contohlapak
EXPOSE 8080

ENTRYPOINT ["/go/bin/contohlapak"]
