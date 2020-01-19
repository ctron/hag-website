all: static build

.PHONY: all clean prep fetch build

POPPER_VERSION=1.16.0
BOOTSTRAP_VERSION=4.4.1

clean:
	rm -Rf output
	rm -Rf build
	rm -Rf node_modules
	rm -Rf static/bootstrap
	rm -f static/jquery.min.js
	rm -f static/popper.min.js

static:
	mkdir -p static

build/download/bootstrap-dist.zip:
	mkdir -p build/download
	curl -Ls https://github.com/twbs/bootstrap/releases/download/v$(BOOTSTRAP_VERSION)/bootstrap-$(BOOTSTRAP_VERSION)-dist.zip -o "$@"

static/jquery.min.js: static
	curl -Ls https://code.jquery.com/jquery-3.4.1.min.js -o "$@"

static/popper.min.js: static
	curl -Ls https://unpkg.com/popper.js@$(POPPER_VERSION)/dist/umd/popper.min.js -o "$@"

static/bootstrap/bootstrap.min.js: build/download/bootstrap-dist.zip
	rm -Rf build/bootstrap
	mkdir -p build/bootstrap
	cd build/bootstrap && unzip -qq -j  ../../build/download/bootstrap-dist.zip
	cp -p build/bootstrap/bootstrap.min.js "$@"

node_modules/bootstrap/scss/bootstrap.scss:
	yarn install

static/bootstrap/bootstrap.min.css: scss/custom.scss node_modules/bootstrap/scss/bootstrap.scss package.json
	yarn css:compile
	yarn css:prefix
	yarn css:minify

fetch: static/bootstrap/bootstrap.min.css
fetch: static/bootstrap/bootstrap.min.js
fetch: static/jquery.min.js
fetch: static/popper.min.js

build:
	hagen -b http://localhost:8080

run: build
	cd output && python3 -m http.server 8080
