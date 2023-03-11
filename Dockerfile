FROM golang:1.19-alpine3.17 as build
ENV TOKEN=0 \
    PORT=2112 \
    DECONZ_HOST=localhost \
    DECONZ_PORT=80
WORKDIR /src/
ADD . .
ENV USER=appuser
ENV UID=10001 
RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

RUN apk add git build-base
RUN go mod download
RUN CGO_ENABLED=0 go build -o deconz-exporter

FROM alpine

COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group
COPY --from=build /src/deconz-exporter /bin/deconz-exporter

USER appuser:appuser
ENTRYPOINT ["/bin/deconz-exporter"]
EXPOSE ${PORT}
