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
kubectl -n dpsrv exec -it deploy/mailserver -- rsync -avz \
  --exclude='dovecot*' \
  --exclude='.dovecot*' \
  -e ssh \
    root@oldserver:/path/to/Maildir/ /var/mail/maxf.net/max/

### Fix ownership
kubectl -n dpsrv exec -it deploy/mailserver -- chown -R 5000:5000 /var/mail/

### Resync
kubectl -n dpsrv exec -it deploy/mailserver -- doveadm force-resync -A '*'


