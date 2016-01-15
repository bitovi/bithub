all: gitco cleandesktop installdesktop builddesktop buildhomepageembed cleanmobile installmobile buildmobile gitadd gitci

desktop: gitco cleandesktop installdesktop builddesktop buildhomepageembed gitadd gitci

mobile: gitco cleanmobile installmobile buildmobile addtogit gitadd gitci

cleandesktop:
	@echo "********************************************************************************"
	@echo "* Removing desktop node_modules                                                *"
	@echo "********************************************************************************"
	rm -rf node_modules

installdesktop:
	@echo "********************************************************************************"
	@echo "* Installing desktop node_modules                                              *"
	@echo "********************************************************************************"
	npm install

builddesktop:
	@echo "********************************************************************************"
	@echo "* Building desktop app                                                         *"
	@echo "********************************************************************************"
	./node_modules/steal-tools/bin/steal build --main=bithub-social;
	./node_modules/steal-tools/bin/steal build --main=bithub-embed

buildhomepageembed:
	@echo "********************************************************************************"
	@echo "* Building homepage embed                                                      *"
	@echo "********************************************************************************"
	./node_modules/steal-tools/bin/steal build --main=homepage_embed/index

cleanmobile:
	@echo "********************************************************************************"
	@echo "* Removing mobile node_modules                                                 *"
	@echo "********************************************************************************"
	cd new-bithub-client; rm -rf node_modules

installmobile:
	@echo "********************************************************************************"
	@echo "* Installing mobile node_modules                                               *"
	@echo "********************************************************************************"
	cd new-bithub-client; npm install

buildmobile:
	@echo "********************************************************************************"
	@echo "* Building mobile app                                                          *"
	@echo "********************************************************************************"
	cd new-bithub-client; donejs build

gitco:
	@echo "********************************************************************************"
	@echo "* Switching to release branch"
	@echo "********************************************************************************"
	git checkout -b release

gitadd:
	@echo "********************************************************************************"
	@echo "* Forcefully adding to git"
	@echo "********************************************************************************"
	git add --force node_modules dist new-bithub-client/node_modules new-bithub-client/dist

gitadd:
	@echo "********************************************************************************"
	@echo "* Forcefully adding to git"
	@echo "********************************************************************************"
	git ci -m 'Release is out yall!'

