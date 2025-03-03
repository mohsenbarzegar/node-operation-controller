# Build the manager binary
FROM golang:1.22 AS builder

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# Initialize and download modules
RUN go mod download && \
    go mod verify

# Copy the go source
COPY . .

# Install controller-gen
RUN go install sigs.k8s.io/controller-tools/cmd/controller-gen@latest

# Build with module support enabled
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=readonly -a -o manager main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot AS final
WORKDIR /
COPY --from=builder /workspace/manager .
USER 65532:65532

ENTRYPOINT ["/manager"]
