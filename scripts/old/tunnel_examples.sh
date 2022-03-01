# jupyter on remotehost, map ports to notebook
ssh -L 8080:localhost:8900 user@remotehost # e.g. from macbook
# cockpit on homeserver, map ports on remotehost and notebook
ssh -L 8991:localhost:9090 user@homeserver # from remotehost, than ssh -L 8991:localhost:8991 remotehost from notebook
# login to homeserver from notebook
ssh -L 40022:localhost:40022 user@remotehost
