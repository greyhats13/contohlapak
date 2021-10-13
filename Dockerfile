FROM golang:buster

RUN mkdir /app
WORKDIR /app
COPY contohlapak .

EXPOSE 9090

ENTRYPOINT ["/app/contohlapak"]
