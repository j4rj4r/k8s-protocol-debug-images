# LDAP Debugging Image for Kubernetes

A lightweight Docker image designed for LDAP service debugging and testing within Kubernetes clusters.

## Tools Included

### Core LDAP Tools

#### ldapsearch
- Search and display LDAP directory entries
- Query LDAP servers with filters
- Display attributes and values
- Support for LDIF output format

#### ldapadd
- Add entries to an LDAP directory
- Read LDIF files for bulk additions
- Support for authentication and TLS

#### ldapmodify
- Modify existing LDAP directory entries
- Update attributes and values
- Support for bulk modifications via LDIF

#### ldapdelete
- Delete entries from an LDAP directory
- Recursive deletion support
- Authentication and authorization

#### ldapwhoami
- Display the DN of the authenticated user
- Verify authentication and authorization
- Test LDAP bind operations

#### ldapcompare
- Compare attribute values in LDAP entries
- Verify data consistency
- Test access controls

#### ldappasswd
- Change user passwords in LDAP
- Support for various password hash formats
- Admin password resets

#### ldapvi
- Interactive LDAP editor
- Edit LDAP entries in a vi-like interface
- Batch modifications

### Supporting Utilities
- **curl/wget**: HTTP/HTTPS testing and file downloads
- **jq**: JSON parsing and formatting
- **openssl**: TLS/SSL certificate inspection
- **nslookup/dig**: DNS debugging
- **netcat**: TCP connection testing
- **ca-certificates**: Trusted root certificates for TLS

## Building the Image

```bash
docker build -f ldap/Dockerfile.ldap -t ldap-debug:latest ldap/
```

## Running Locally

```bash
docker run -it --rm ldap-debug:latest
```

## Usage Examples

### Basic LDAP Search

```bash
# Simple search
ldapsearch -x -H ldap://ldap-server:389 -b "dc=example,dc=com"

# Search with filter
ldapsearch -x -H ldap://ldap-server:389 -b "dc=example,dc=com" "(uid=jdoe)"

# Authenticated search
ldapsearch -x -H ldap://ldap-server:389 \
  -D "cn=admin,dc=example,dc=com" \
  -w password \
  -b "dc=example,dc=com" \
  "(objectClass=person)"

# Search with specific attributes
ldapsearch -x -H ldap://ldap-server:389 \
  -b "dc=example,dc=com" \
  "(uid=jdoe)" mail cn sn
```

### LDAPS (Secure LDAP)

```bash
# LDAPS on port 636
ldapsearch -x -H ldaps://ldap-server:636 \
  -b "dc=example,dc=com"

# Skip certificate verification (testing only)
LDAPTLS_REQCERT=never ldapsearch -x -H ldaps://ldap-server:636 \
  -b "dc=example,dc=com"

# With custom CA certificate
ldapsearch -x -H ldaps://ldap-server:636 \
  -b "dc=example,dc=com" \
  env LDAPTLS_CACERT=/path/to/ca.crt
```

### StartTLS

```bash
# Use StartTLS on port 389
ldapsearch -x -H ldap://ldap-server:389 \
  -ZZ \
  -b "dc=example,dc=com"
```

### Adding Entries

```bash
# Create LDIF file
cat > user.ldif <<EOF
dn: uid=jdoe,ou=users,dc=example,dc=com
objectClass: inetOrgPerson
uid: jdoe
cn: John Doe
sn: Doe
mail: jdoe@example.com
userPassword: secret123
EOF

# Add entry
ldapadd -x -H ldap://ldap-server:389 \
  -D "cn=admin,dc=example,dc=com" \
  -w password \
  -f user.ldif
```

### Modifying Entries

```bash
# Create modify LDIF
cat > modify.ldif <<EOF
dn: uid=jdoe,ou=users,dc=example,dc=com
changetype: modify
replace: mail
mail: john.doe@example.com
EOF

# Apply modification
ldapmodify -x -H ldap://ldap-server:389 \
  -D "cn=admin,dc=example,dc=com" \
  -w password \
  -f modify.ldif
```

### Deleting Entries

```bash
# Delete single entry
ldapdelete -x -H ldap://ldap-server:389 \
  -D "cn=admin,dc=example,dc=com" \
  -w password \
  "uid=jdoe,ou=users,dc=example,dc=com"

# Delete recursively
ldapdelete -x -H ldap://ldap-server:389 \
  -D "cn=admin,dc=example,dc=com" \
  -w password \
  -r "ou=temp,dc=example,dc=com"
```

### Testing Authentication

```bash
# Test bind
ldapwhoami -x -H ldap://ldap-server:389 \
  -D "uid=jdoe,ou=users,dc=example,dc=com" \
  -w password

# Anonymous bind
ldapwhoami -x -H ldap://ldap-server:389
```

### Password Management

```bash
# Change password
ldappasswd -x -H ldap://ldap-server:389 \
  -D "cn=admin,dc=example,dc=com" \
  -w adminpass \
  -s newpassword \
  "uid=jdoe,ou=users,dc=example,dc=com"
```

### Interactive Editing with ldapvi

```bash
# Edit entries interactively
ldapvi -h ldap-server \
  -D "cn=admin,dc=example,dc=com" \
  -w password \
  -b "ou=users,dc=example,dc=com"
```

## ldap-debug with Kubernetes

* if you want to debug using an [ephemeral container](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#ephemeral-container-example) in an existing pod:

    `$ kubectl debug mypod -it --image=j4rj4r/ldap-debug`

* if you want to spin up a throw away pod for debugging.

    `$ kubectl run tmp-shell --rm -i --tty --image j4rj4r/ldap-debug`

* if you want to spin up a container on the host's network namespace.

    `$ kubectl run tmp-shell --rm -i --tty --overrides='{"spec": {"hostNetwork": true}}'  --image j4rj4r/ldap-debug`

### Testing LDAP Services in Cluster

```bash
# Deploy the debug pod
kubectl apply -f ldap-debug-pod.yaml

# Exec into pod
kubectl exec -it ldap-debug -- /bin/sh

# Search LDAP service
ldapsearch -x -H ldap://openldap.default.svc.cluster.local:389 \
  -b "dc=example,dc=com"

# Test with authentication
ldapsearch -x -H ldap://openldap.default.svc.cluster.local:389 \
  -D "cn=admin,dc=example,dc=com" \
  -w password \
  -b "dc=example,dc=com"
```

### Cross-Namespace Testing

```bash
# From ldap-debug pod, test service in another namespace
ldapsearch -x \
  -H ldap://openldap.ldap-namespace.svc.cluster.local:389 \
  -b "dc=example,dc=com"
```

### Debugging LDAPS/TLS

```bash
# Check certificate
openssl s_client -connect openldap:636 -showcerts

# Test LDAPS connection
ldapsearch -x -H ldaps://openldap:636 \
  -b "dc=example,dc=com"

# Debug TLS handshake
openssl s_client -connect openldap:636 -debug -state
```

## Common Use Cases

1. **Directory Search**: Query and filter LDAP entries
2. **User Management**: Add, modify, delete user accounts
3. **Authentication Testing**: Verify credentials and binds
4. **TLS/LDAPS Debugging**: Inspect certificates and secure connections
5. **Schema Exploration**: Discover directory structure and object classes
6. **Network Policy Testing**: Verify LDAP connectivity across namespaces
7. **Performance Testing**: Measure search and bind response times

## LDAP Configuration Tips

### Environment Variables

```bash
# Set default LDAP URI
export LDAPURI="ldap://ldap-server:389"

# Set default base DN
export LDAPBASE="dc=example,dc=com"

# Set default bind DN
export LDAPBINDDN="cn=admin,dc=example,dc=com"

# Skip certificate verification (testing only)
export LDAPTLS_REQCERT=never
```

### .ldaprc Configuration

```bash
# Create ~/.ldaprc
cat > ~/.ldaprc <<EOF
URI ldap://ldap-server:389
BASE dc=example,dc=com
BINDDN cn=admin,dc=example,dc=com
TLS_REQCERT allow
EOF
```