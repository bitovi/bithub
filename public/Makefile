all: cleandesktop installdesktop builddesktop buildhomepageembed cleanmobile installmobile buildmobile

desktop: cleandesktop installdesktop builddesktop buildhomepageembed

mobile: cleanmobile installmobile buildmobile

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