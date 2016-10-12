TARGET=deb
PACKAGE_NAME=mtail
PACKAGE_VERSION=0.1.3
PACKAGE_REVISION=3
PACKAGE_ARCH=amd64
PACKAGE_MAINTAINER=tristan@qubit.com
PACKAGE_FILE=$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION)_$(PACKAGE_ARCH).$(TARGET)

GITREPO=https://github.com/google/mtail.git

BINNAME=mtail

PWD=$(shell pwd)

all: package

binary: clean-binary
	mkdir -p build/go/src
	mkdir -p build/$(PACKAGE_NAME)
	export GOPATH=$(PWD)/build/go && go get -d github.com/google/mtail
	export GOPATH=$(PWD)/build/go && cd $(PWD)/build/go/src/github.com/google/mtail && make install
	mkdir -p dist/usr/local/bin
	install -m755 $(PWD)/build/go/bin/$(BINNAME) dist/usr/local/bin/$(BINNAME)

	mkdir -p dist/etc/init
	mkdir -p dist/etc/default
	install -m755 -d mtail.d dist/etc/mtail.d
	for file in mtail.d/*.mtail;do install -m 755 "$$file" dist/etc/"$$file" ; done
	install -m644 $(BINNAME).conf dist/etc/init/$(BINNAME).conf
	install -m644 $(BINNAME).defaults dist/etc/default/$(BINNAME)

clean-binary:
	rm -f dist/usr/local/bin/$(BINNAME)

package: clean binary
	cd dist && \
	  fpm \
	  -t $(TARGET) \
	  -m $(PACKAGE_MAINTAINER) \
	  -n $(PACKAGE_NAME) \
	  -a $(PACKAGE_ARCH) \
	  -v $(PACKAGE_VERSION) \
	  --iteration $(PACKAGE_REVISION) \
	  -s dir \
	  -p ../$(PACKAGE_FILE) \
	  .


clean:
	rm -f $(PACKAGE_FILE)
	rm -rf dist
	rm -rf build
