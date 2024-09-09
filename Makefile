NAME=himlar-dp-prep
VERSION=3.0
PACKAGE_VERSION=1
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
	rm -f $(NAME)-$(VERSION)-*.rpm
	rm -Rf vendor/

.PHONY: deps
deps:
	dnf module reset ruby -y
	dnf install -y @ruby:2.7
	dnf install -y gcc rpm-build ruby-devel git python3.11-devel httpd-devel
	gem install -N fpm


.PHONY: build
build:
	mkdir vendor/
	mkdir -p /installdir/opt/dpapp
	cd vendor && git clone -b upgrade https://github.com/norcams/himlar-dp-prep
	rsync -avh vendor/himlar-dp-prep/ /installdir/opt/dpapp/
	python3.11 -m venv /installdir/opt/dpapp/
	# Temp fix for requests
	#cd /installdir/opt/dpapp/ && bin/pip install requests==2.18.0
	cd /installdir/opt/dpapp/ && bin/python setup.py develop
	cd /installdir/opt/dpapp/ && bin/pip install -r requirements.txt
	#cd /installdir/opt/dpapp/ && virtualenv --relocatable .
	#echo "/opt/dpapp" > /installdir/opt/dpapp/lib/python2.7/site-packages/himlar-dp-prep.egg-link

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
