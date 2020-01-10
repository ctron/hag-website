all: static build

.PHONY: all clean fetch prep build

clean:
	rm -Rf output
	rm -Rf download
	-rm static/jquery.min.js
	-rm static/popper.min.js

static:
	mkdir -p static

download/bootstrap.zip:
	mkdir -p download
	curl -Ls https://github.com/twbs/bootstrap/releases/download/v4.3.1/bootstrap-4.3.1-dist.zip -o "$@"

static/jquery.min.js: static
	curl -Ls https://code.jquery.com/jquery-3.4.1.min.js -o "$@"

static/popper.min.js: static
	curl -Ls https://unpkg.com/popper.js@1.15.0/dist/umd/popper.min.js -o "$@"

fetch: download/bootstrap.zip
fetch: static/jquery.min.js
fetch: static/popper.min.js

fetch:
	rm -Rf static/bootstrap
	mkdir -p static/bootstrap
	cd static/bootstrap && unzip -qq -j  ../../download/bootstrap.zip

build:
	hagen

run: build
	cd output && python3 -m http.server 8080
