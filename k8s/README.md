# Mail Server Kubernetes Deployment

Docker-mailserver deployment for maxf.net and virtual domains.

## Prerequisites

1. Let's Encrypt TLS secrets in the `mail` namespace:
   - `letsencrypt-live-domain-fullchain-pem`
   - `letsencrypt-live-domain-privkey-pem`

2. Copy the secrets from their current namespace:
   ```bash
   kubectl get secret letsencrypt-live-domain-fullchain-pem -n SOURCE_NS -o yaml | \
     sed 's/namespace: .*/namespace: mail/' | kubectl apply -f -
   kubectl get secret letsencrypt-live-domain-privkey-pem -n SOURCE_NS -o yaml | \
     sed 's/namespace: .*/namespace: mail/' | kubectl apply -f -
   ```

## Setup

### 1. Generate password hashes

```bash
# For each user, generate a password hash:
docker run --rm -it ghcr.io/docker-mailserver/docker-mailserver:latest \
  setup email add max@maxf.net

# This outputs a hash like: max@maxf.net|{SHA512-CRYPT}$6$...
# Copy into 02-mail-config-secrets.yaml
```

### 2. Update DKIM key

Copy your existing DKIM private key from `etc/mail/maxf.net.dkim.key` into the secret in `02-mail-config-secrets.yaml`.

### 3. Deploy

```bash
./apply.sh
```

### 4. Verify

```bash
kubectl -n mail get pods
kubectl -n mail logs -f deployment/mailserver
```

## Ports

| Port | Service |
|------|---------|
| 25   | SMTP (inbound) |
| 465  | SMTPS (submission over TLS) |
| 587  | Submission (STARTTLS) |
| 143  | IMAP (STARTTLS) |
| 993  | IMAPS (TLS) |

## DNS Requirements

Update DNS MX and A records:
- MX: `mail.maxf.net` priority 10
- A: `mail.maxf.net` → LoadBalancer IP
- SPF: `v=spf1 mx a:mail.maxf.net -all`
- DKIM: Add TXT record for `mail._domainkey.maxf.net`
- DMARC: `v=DMARC1; p=quarantine; rua=mailto:postmaster@maxf.net`

## Domains

- **Primary**: maxf.net
- **Virtual**: barbash.info, fcspc.net, fortun.org, russiantranslate.com, verticair.com
