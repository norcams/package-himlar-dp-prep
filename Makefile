NAME=himlar-dp-prep
VERSION=3.0
PACKAGE_VERSION=2
DESCRIPTION=package.description
URL=package.url
MAINTAINER="https://github.com/norcams"
RELVERSION=8

.PHONY: default
default: deps build rpm
package: rpm

.PHONY: clean
clean:
	rm -fr /installdir
	rm -fr /opt/dpapp
	rm -f $(NAME)-$(VERSION)-*.rpm
	rm -Rf vendor/

.PHONY: deps
deps:
	dnf module reset ruby -y
	dnf install -y @ruby:3.3
	dnf install -y gcc rpm-build ruby-devel git python3.11-devel
	gem install -N fpm


.PHONY: build
build:
	mkdir vendor/
	mkdir -p /opt/dpapp
	cd vendor && git clone -b upgrade https://github.com/norcams/himlar-dp-prep
	rsync -avh vendor/himlar-dp-prep/ /opt/dpapp/
	python3.11 -m venv /opt/dpapp/
	cd /opt/dpapp/ && bin/pip install --upgrade pip
	cd /opt/dpapp/ && bin/python setup.py develop
	cd /opt/dpapp/ && bin/pip install -r requirements.txt
	echo "/opt/dpapp" > /opt/dpapp/lib/python3.11/site-packages/himlar-dp-prep.egg-link
	mkdir -p /installdir/opt
	cp -R /opt/dpapp /installdir/opt/

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
