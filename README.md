# Fun with Packer, Vagrant, and Nomad

## Packer
```bash
# setup plugins
packer init .

# make HCL files look pretty
packer fmt .

# ensure HCL files are legit
packer validate .

# build nomad server and box add
packer build -force nomad_server.pkr.hcl
vagrant box add --force nomad-server-base output-rockylinux-8-nomad-server/package.box

# build ws node and box add
packer build -force ws.pkr.hcl
vagrant box add --force ws-base output-rockylinux-8-ws/package.box

# build wh node and box add
packer build -force wh.pkr.hcl
vagrant box add --force wh-base output-rockylinux-8-wh/package.box

# build app node and box add
packer build -force app.pkr.hcl
vagrant box add --force app-base output-rockylinux-8-app/package.box

# build nweb node and box add
packer build -force nweb.pkr.hcl
vagrant box add --force nweb-base output-rockylinux-8-nweb/package.box
```

## Vagrant
```bash
# stand up nomad server
vagrant up server1

# stand up ws node
vagrant up ws-client1

# stand up wh node
vagrant up wh-client1

# stand up app node
vagrant up app-client1
```

## Nomad
### Deploying Config Mgmt
```bash
# plan and run ws bootstrap and cron job
nomad job plan bootstrap-ws-dev.hcl
nomad job plan cron-ws-dev.hcl

nomad job run bootstrap-ws-dev.hcl
nomad job run cron-ws-dev.hcl

...

nomad job run bootstrap-wh-dev.hcl
nomad job run cron-wh-dev.hcl
nomad job run bootstrap-app-dev.hcl
nomad job run cron-app-dev.hcl
nomad job run bootstrap-nweb-dev.hcl
nomad job run cron-nweb-dev.hcl
```

### Deploying and Scaling an App
```bash
# run ptyhon app
nomad job plan app.hcl

nomad job scale hello world 5
nomad job scale hello world 1
```

## What to See
- see packer
- see vagrant using packer images

- see nomad node raw
- see nomad in bootstrap mode
- see nomad in cron mode

- see nomad service discovery in ansible (ws)
- see nomad service discovery via ansible/golang template mix (wh)
- see nomad service discovery as it should be (nweb, hweb)

## Cons
- nomad not secure by default (mTLS, ACLs)
- only recent idea of deploying job with secrets
- golang templates hurt a little
- overkill for config mgmt ?? but what if ..
