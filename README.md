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
```

## Vagrant
```bash
# stand up nomad server
vagrant up server1

# stand up ws node
vagrant up ws-client1

# stand up wh node
vagrant up wh-client1
```

## Nomad
```bash
# plan and run ws bootstrap and cron job
nomad job plan bootstrap-ws-dev.hcl
nomad job plan cron-ws-dev.hcl
nomad job run bootstrap-ws-dev.hcl
nomad job run cron-ws-dev.hcl

# plan and run wh bootstrap and cron job
nomad job plan bootstrap-wh-dev.hcl
nomad job plan cron-wh-dev.hcl
nomad job run bootstrap-wh-dev.hcl
nomad job run cron-wh-dev.hcl
```
