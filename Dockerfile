ARG GO_VERSION=1.17

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine as builder

# Set necessary environmet variables needed for our image

ARG TARGETPLATFORM

ENV GO111MODULE=on \
    CGO_ENABLED=0 
#    GOOS=$TARGETOS \
#    GOARCH=$TARGETARCH

# Move to working directory /build
WORKDIR /build

# Copy and download dependency using go mod
COPY go.mod .
COPY go.sum .
RUN go mod download

# Copy the code into the container
COPY . .

# Build the application
RUN go build -o main .

# Move to /dist directory as the place for resulting binary folder
WORKDIR /dist

# Copy binary from build to main folder
RUN cp /build/main .

# Build a small image
FROM alpine:latest

COPY --from=builder /dist/main /

# Command to run when starting the container
CMD ["/main"]
