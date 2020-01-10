all: static build

.PHONY: all clean prep fetch build

clean:
	rm -Rf output
	rm -Rf build
	rm -Rf static/bootstrap
	rm -f static/jquery.min.js
	rm -f static/popper.min.js

static:
	mkdir -p static

build/download/bootstrap-dist.zip:
	mkdir -p build/download
	curl -Ls https://github.com/twbs/bootstrap/releases/download/v4.3.1/bootstrap-4.3.1-dist.zip -o "$@"

static/jquery.min.js: static
	curl -Ls https://code.jquery.com/jquery-3.4.1.min.js -o "$@"

static/popper.min.js: static
	curl -Ls https://unpkg.com/popper.js@1.15.0/dist/umd/popper.min.js -o "$@"

static/bootstrap/bootstrap.min.css: scss/custom.scss node_modules/bootstrap/scss/bootstrap.scss package.json
	yarn css:compile
	yarn css:prefix
	yarn css:minify

Xstatic/bootstrap/bootstrap.min.css: build/download/bootstrap-dist.zip
	rm -Rf static/bootstrap
	mkdir -p static/bootstrap
	cd static/bootstrap && unzip -qq -j  ../../build/download/bootstrap-dist.zip

fetch: static/bootstrap/bootstrap.min.css
fetch: static/jquery.min.js
fetch: static/popper.min.js

build:
	hagen

run: build
	cd output && python3 -m http.server 8080
