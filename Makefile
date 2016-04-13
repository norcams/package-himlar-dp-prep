NAME=himlar-dp-prep
VERSION=1.0
PACKAGE_VERSION=1
DESCRIPTION=package.description
URL=package.url
MAINTAINER="http://norcams.org"
RELVERSION=7

.PHONY: default
default: deps build rpm
package: rpm

.PHONY: clean
clean:
	sudo rm -fr installdir
	sudo rm -f $(NAME)-$(VERSION)-*.rpm
	rm -Rf vendor/

.PHONY: deps
deps:
	sudo yum install -y gcc ruby-devel rpm-build
	sudo gem install -N fpm
	sudo yum install -y python-devel python-virtualenv git

.PHONY: build
build:
	mkdir vendor/
	sudo mkdir -p installdir/opt/dpapp
	cd installdir/opt && git clone https://github.com/norcams/himlar-dp-prep.git dpapp
	cd installdir/opt/dpapp && git submodule update --init
	#rsync -avh vendor/himlar-dp-prep/ installdir/opt/dpapp/
	virtualenv installdir/opt/dpapp/
	cd installdir/opt/dpapp/ && bin/python setup.py develop

.PHONY: rpm
rpm:
	sudo /usr/local/bin/fpm -s dir -t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		--iteration "$(PACKAGE_VERSION).el$(RELVERSION)" \
		--description "$(shell cat $(DESCRIPTION))" \
		--url "$(shelpl cat $(URL))" \
		--maintainer "$(MAINTAINER)" \
		-C installdir/ \
		.

.PHONY: upload
upload:
	scp $(NAME)-$(VERSION)-*.rpm repo@repoupload.uib.no:yum/incoming/el-extra-dev/$(RELVERSION)/.
