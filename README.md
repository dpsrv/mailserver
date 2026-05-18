# mailserver
## Change password
```
kubectl -n dpsrv exec -it deploy/mailserver -- doveadm pw -s SHA512-CRYPT -p 'YOUR_PASSWORD'
```
Then update `postfix-accounts.cf`

## Migration
### Install rsync in running container
kubectl -n dpsrv exec -it deploy/mailserver -- apt-get update && apt-get install -y rsync

### Then rsync from old server
```
#!/bin/bash -ex

src=$1
domain=$2
user=$3

if [ -z "$user" ]; then
    echo "Usage: $0 <src> <domain> <user>"
    echo " e.g.: $0 root@oldserver:/path/to/Maildir/ example.com user"
    exit 1
fi      

kubectl -n dpsrv exec -it deploy/mailserver -- rsync -avz \
  --exclude='dovecot*' \
  --exclude='.dovecot*' \
  -e ssh \
    $src /var/mail/$domain/$user/
```

### Fix ownership
kubectl -n dpsrv exec -it deploy/mailserver -- chown -R 5000:5000 /var/mail/

### Resync
kubectl -n dpsrv exec -it deploy/mailserver -- doveadm force-resync -A '*'


