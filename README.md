# k8s-protocol-debug-images

A collection of lightweight Docker images designed for debugging and testing network protocols inside Kubernetes clusters. Each image focuses on a specific protocol with essential tools for troubleshooting and testing.

## Available Images

### gRPC Debug Image

**Location**: `grpc/`

A comprehensive debugging image for gRPC services in Kubernetes environments.

**Tools Included**:
- **grpcurl** - Command-line gRPC client (like curl for gRPC)
- **grpcui** - Web-based interactive gRPC UI
- **evans** - Interactive REPL for gRPC services
- **ghz** - Load testing and benchmarking tool
- **Supporting utilities**: curl, wget, jq, openssl, dig, netcat

**Usage**:
```bash
# Build the image
docker build -f grpc/Dockerfile.grpc -t grpc-debug:latest grpc/

# Quick debug with ephemeral container
kubectl debug mypod -it --image=j4rj4r/grpc-debug

# Spin up a throwaway pod
kubectl run tmp-shell --rm -i --tty --image j4rj4r/grpc-debug

# Test gRPC service
kubectl exec -it grpc-debug -- grpcurl -plaintext my-service:50051 list
```

**Documentation**: See [grpc/README-grpc.md](grpc/README-grpc.md) for detailed usage examples.

## Building Images

Each protocol has its own directory with:
- `Dockerfile.*` - Multi-arch Dockerfile (amd64/arm64)
- `build/fetch_binaries.sh` - Script to fetch latest tool versions
- `README-*.md` - Detailed documentation
- `*-debug-pod.yaml` - Kubernetes manifests

## CI/CD

**Release workflow**: Tag with `<protocol>-v*` (e.g., `grpc-v1.0.0`)

## Contributing

Each protocol image should:
- Be based on Alpine Linux for minimal size
- Run as non-root user
- Include only essential debugging tools
- Support multi-architecture builds
- Have comprehensive documentation
