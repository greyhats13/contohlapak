FROM golang:buster

RUN mkdir /app
WORKDIR /app
COPY contohlapak .

ENTRYPOINT ["/app/contohlapak"]
