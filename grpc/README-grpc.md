# gRPC Debugging Image for Kubernetes

A lightweight Docker image designed for gRPC service debugging and testing within Kubernetes clusters.

## Tools Included

### Core gRPC Tools

#### grpcurl
- Command-line tool for interacting with gRPC servers
- Similar to curl but for gRPC services
- Supports reflection-based service discovery
- Can invoke RPC methods and inspect service definitions

#### grpcui
- Web-based GUI for gRPC service interaction
- Provides interactive forms for RPC methods
- Automatically discovers services via server reflection
- Runs on port 8080 by default

#### ghz
- gRPC benchmarking and load testing tool
- Measure performance and latency
- Generate load with configurable concurrency
- Detailed performance metrics and histograms

#### evans
- Interactive gRPC client with REPL interface
- Intuitive command-line interface for exploring services
- Supports both CLI mode and REPL mode
- Automatic tab completion and service discovery
- Proto file support and server reflection

### Supporting Utilities
- **curl/wget**: HTTP/HTTPS testing and file downloads
- **jq**: JSON parsing and formatting
- **openssl**: TLS/SSL certificate inspection
- **nslookup/dig**: DNS debugging
- **netcat**: TCP connection testing
- **ca-certificates**: Trusted root certificates for TLS

## Usage Examples

### List Services (requires server reflection)
```bash
grpcurl -plaintext <service>:<port> list
```

### Describe a Service
```bash
grpcurl -plaintext <service>:<port> describe <service.name>
```

### Invoke an RPC Method
```bash
grpcurl -plaintext -d '{"name": "test"}' \
  <service>:<port> <package.Service/Method>
```

### Using Proto Files
```bash
# Copy your .proto files to /home/debugger/protos
grpcurl -import-path ./protos -proto service.proto \
  -plaintext -d '{"id": "123"}' \
  <service>:<port> <package.Service/Method>
```

### TLS/Secure Connections
```bash
# With TLS
grpcurl -d '{"name": "test"}' <service>:443 <package.Service/Method>

# Skip certificate verification
grpcurl -insecure -d '{"name": "test"}' <service>:443 <package.Service/Method>

# With custom CA certificate
grpcurl -cacert /path/to/ca.crt -d '{"name": "test"}' \
  <service>:443 <package.Service/Method>
```

### Launch gRPC UI
```bash
# With server reflection
grpcui -plaintext <service>:<port>

# With proto files
grpcui -import-path ./protos -proto service.proto \
  -plaintext <service>:<port>

# Access at http://localhost:8080
```

### Load Testing with ghz
```bash
# Basic load test
ghz --insecure --proto ./protos/service.proto \
  --call package.Service/Method \
  -d '{"name":"test"}' \
  -c 10 -n 1000 \
  <service>:50051

# With duration and rate limiting
ghz --insecure \
  --call package.Service/Method \
  -d '{"name":"test"}' \
  -c 50 --rps 100 -z 30s \
  <service>:50051
```

### Interactive Debugging with evans

#### REPL Mode (Interactive)
```bash
# Connect with server reflection (most common)
evans --host <service> --port 50051 -r repl

# Inside evans REPL:
# show package         - List available packages
# package <name>       - Select a package
# show service         - List services in package
# service <name>       - Select a service
# show message         - List message types
# call <method>        - Call an RPC method (interactive prompts)
# exit                 - Exit REPL

# Example session:
evans --host my-grpc-service --port 50051 -r repl
> show package
> package api.v1
> show service
> service UserService
> call GetUser
# (evans will prompt for field values)
user_id: 123
```

#### CLI Mode (One-shot Commands)
```bash
# Call a method directly without REPL
evans --host <service> --port 50051 \
  --package api.v1 \
  --service UserService \
  --call GetUser \
  --json '{"user_id": "123"}'

# With proto files (no reflection)
evans --host <service> --port 50051 \
  --path ./protos \
  --proto service.proto \
  -r repl

# With TLS
evans --host <service> --port 443 \
  --tls \
  --cacert /path/to/ca.crt \
  -r repl

# Plaintext (no TLS)
evans --host <service> --port 50051 \
  --plaintext \
  -r repl
```

#### evans Tips
- Tab completion works in REPL mode for commands and service names
- Use `header` command to set metadata: `header authorization="Bearer token"`
- Use `--web` flag for a web-based UI alternative to terminal REPL
- evans is more user-friendly than grpcurl for exploratory testing
- Great for manual testing and understanding service schemas

## grpc-debug with Kubernetes

* if you want to debug using an [ephemeral container](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#ephemeral-container-example) in an existing pod:

    `$ kubectl debug mypod -it --image=j4rj4r/grpc-debug`

* if you want to spin up a throw away pod for debugging.

    `$ kubectl run tmp-shell --rm -i --tty --image j4rj4r/grpc-debug`

* if you want to spin up a container on the host's network namespace.

    `$ kubectl run tmp-shell --rm -i --tty --overrides='{"spec": {"hostNetwork": true}}'  --image j4rj4r/grpc-debug`

### Testing gRPC Services in Cluster

```bash
# Deploy the debug pod
kubectl apply -f grpc-debug-pod.yaml

# Exec into pod
kubectl exec -it grpc-debug -- /bin/sh

# List services from a gRPC service
grpcurl -plaintext my-grpc-service:50051 list

# Test an RPC call
grpcurl -plaintext -d '{"user_id": "123"}' \
  my-grpc-service:50051 api.v1.UserService/GetUser
```

### Cross-Namespace Testing

```bash
# From grpc-debug pod, test service in another namespace
grpcurl -plaintext \
  my-service.other-namespace.svc.cluster.local:50051 list
```

### Debugging mTLS/Service Mesh

```bash
# Test with service mesh (Istio, Linkerd)
# Usually requires proper certificates mounted via volumes

# Check certificate details
openssl s_client -connect my-service:50051 -showcerts

# Test with mTLS
grpcurl -cert /certs/client.crt -key /certs/client.key \
  -cacert /certs/ca.crt \
  my-service:50051 list
```

## Common Use Cases

1. **Service Discovery**: List available services and methods
2. **RPC Testing**: Invoke methods with custom payloads
3. **Performance Testing**: Benchmark gRPC endpoints
4. **TLS Debugging**: Inspect certificates and secure connections
5. **Network Policy Testing**: Verify gRPC connectivity across namespaces
6. **Load Generation**: Stress test gRPC services
