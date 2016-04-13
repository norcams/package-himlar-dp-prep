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
	rm -fr /installdir
	rm -f $(NAME)-$(VERSION)-*.rpm
	rm -Rf vendor/

.PHONY: deps
deps:
	yum install -y gcc ruby-devel rpm-build
	gem install -N fpm
	yum install -y python-devel python-virtualenv git

.PHONY: build
build:
	mkdir vendor/
	mkdir -p /installdir/opt/dpapp
	cd vendor && git clone https://github.com/norcams/himlar-dp-prep
	cd vendor/himlar-dp-prep && git submodule update --init
	rsync -avh vendor/himlar-dp-prep/ /installdir/opt/dpapp/
	virtualenv /installdir/opt/dpapp/
	cd /installdir/opt/dpapp/ && bin/python setup.py develop
	echo "/opt/dpapp" > /installdir/opt/dpapp/lib/python2.7/site-packages/himlar-dp-prep.egg-link

.PHONY: rpm
rpm:
	/usr/local/bin/fpm -s dir -t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		--iteration "$(PACKAGE_VERSION).el$(RELVERSION)" \
		--description "$(shell cat $(DESCRIPTION))" \
		--url "$(shelpl cat $(URL))" \
		--maintainer "$(MAINTAINER)" \
		-C /installdir/ \
		.

