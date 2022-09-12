.DEFAULT: help

help:
	@echo "***** BUILD IMAGE *****"
	@echo "make buildapp			build app image"
	@echo "make buildnomad			build nomad image"
	@echo "make buildnweb			build nweb image"
	@echo "make buildwh			build wh image"
	@echo "make buildws			build ws image"
	@echo "make buildall			build ALL images"
	@echo "***** ADD IMAGE *****"
	@echo "make addapp			add app image"
	@echo "make addnomad			add nomad image"
	@echo "make addnweb			build nweb image"
	@echo "make addwh			add wh image"
	@echo "make addws			add ws image"
	@echo "make addall			add ALL images"

buildapp:
	@packer build -force app.pkr.hcl

buildnomad:
	@packer build -force nomad_server.pkr.hcl

buildnweb:
	@packer build -force nweb.pkr.hcl

buildwh:
	@packer build -force wh.pkr.hcl

buildws:
	@packer build -force ws.pkr.hcl

buildall:
	@make buildapp
	@make buildnomad
	@make buildnweb
	@make buildwh
	@make buildws

addapp:
	@vagrant box add --force app-base output-rockylinux-8-app/package.box

addnomad:
	@vagrant box add --force nomad-base output-rockylinux-8-nomad-server/package.box

addnweb:
	@vagrant box add --force nweb-base output-rockylinux-8-nweb/package.box

addwh:
	@vagrant box add --force wh-base output-rockylinux-8-wh/package.box

addws:
	@vagrant box add --force ws-base output-rockylinux-8-ws/package.box

addall:
	@make addapp
	@make addnomad
	@make addnweb
	@make addwh
	@make addws
