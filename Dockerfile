FROM golang:1.18 as builder

ENV JSONNET_VERSION v0.18.0
#ENV PROMTOOL_VERSION v2.36.2
ENV GOLANGCILINT_VERSION v1.46.2
ENV JB_VERSION v0.5.1
ENV GO_BINDATA_VERSION v3.1.3

RUN apt-get update -y && apt-get install -y g++ make git && \
    rm -rf /var/lib/apt/lists/*
RUN curl -Lso - https://github.com/google/jsonnet/archive/${JSONNET_VERSION}.tar.gz | \
    tar xfz - -C /tmp && \
    cd /tmp/jsonnet-${JSONNET_VERSION#v} && \
    make && mv jsonnetfmt /usr/local/bin && \
    rm -rf /tmp/jsonnet-${JSONNET_VERSION#v}

RUN GO111MODULE=on go install github.com/google/go-jsonnet/cmd/jsonnet@${JSONNET_VERSION}
#RUN GO111MODULE=on go install github.com/prometheus/prometheus/cmd/promtool/v2@${PROMTOOL_VERSION}
RUN GO111MODULE=on go install github.com/golangci/golangci-lint/cmd/golangci-lint@${GOLANGCILINT_VERSION}
RUN GO111MODULE=on go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@${JB_VERSION}
RUN go install github.com/brancz/gojsontoyaml@latest
RUN go install github.com/campoy/embedmd@latest
RUN GO111MODULE=on go install github.com/go-bindata/go-bindata/v3/go-bindata@${GO_BINDATA_VERSION}

FROM golang:1.18

RUN groupadd -r captain && useradd --no-log-init -rm -g captain captain
RUN mkdir /.cache && chmod -R 777 /go /.cache

RUN apt-get update -y && apt-get install -y make git jq gawk python3-yaml && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/bin/jsonnetfmt /usr/local/bin/jsonnetfmt
COPY --from=builder /go/bin/* /go/bin/

USER captain:captain
WORKDIR /home/captain
