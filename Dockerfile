FROM golang:1.19-alpine as build
LABEL org.opencontainers.image.source="https://github.com/ProspePrim/go_0101_scratch"

ENV USER=appuser
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/bin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR $GOPATH/src/app/

COPY . .

RUN go mod download && go mod verify && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build  -o /go/bin/app.bin cmd/main.go

### scratch ###
FROM scratch as final
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group
COPY --from=build /go/bin/app.bin /go/bin/app.bin
COPY --from=build --chown=${USER}:${USER} /go/src/app/upload uploads

USER $USER:$USER

EXPOSE 9999

VOLUME uploads

ENTRYPOINT ["/go/bin/app.bin"]