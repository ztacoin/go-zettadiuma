# Build Gzta in a stock Go builder container
FROM golang:1.12-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

ADD . /go-zettadiuma
RUN cd /go-zettadiuma && make gzta

# Pull Gzta into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-zettadiuma/build/bin/gzta /usr/local/bin/

EXPOSE 9019 9020 28120 28120/udp
ENTRYPOINT ["gzta"]
