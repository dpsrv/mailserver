# mailserver
## Change password
```
kubectl -n dpsrv exec -it deploy/mailserver -- doveadm pw -s SHA512-CRYPT -p 'YOUR_PASSWORD'
```
Then update `postfix-accounts.cf`

