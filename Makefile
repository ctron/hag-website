all: static build

.PHONY: all clean clean_images prep build images

POPPER_VERSION=1.16.0
BOOTSTRAP_VERSION=4.4.1
YARN=yarn

clean: clean_images
	rm -Rf output
	rm -Rf build
	rm -Rf node_modules
	rm -Rf static/bootstrap
	rm -f static/jquery.min.js
	rm -f static/popper.min.js

clean_images:
	rm -Rf $(WEBP_IMAGES) $(1X_IMAGES) $(CVT_IMAGES)

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
	$(YARN) install

static/bootstrap/bootstrap.min.css: scss/custom.scss node_modules/bootstrap/scss/bootstrap.scss package.json
	$(YARN) css:compile
	$(YARN) css:prefix
	$(YARN) css:minify

assets: static/bootstrap/bootstrap.min.css
assets: static/bootstrap/bootstrap.min.js
assets: static/jquery.min.js
assets: static/popper.min.js

%.1x.png: %.png
	convert $< -resize 50% $@

content/games/com.bonusxp.legend/images/default.1x.png: content/games/com.bonusxp.legend/images/default.png
	cp $< $@

%.webp: %.png
	cwebp -q 90 -m 6 $< -o $@

%.png: %.jpg
	convert $< $@

1X_IMAGES=\
	content/games/com.bonusxp.legend/images/default.1x.png \
	content/games/com.bscotch.crashlands/images/default.1x.png \
	content/games/com.terribletoybox.thimbleweedparkandroid/images/default.1x.png \


WEBP_IMAGES=\
	content/games/com.bonusxp.legend/images/default.webp \
	content/games/com.bonusxp.legend/images/default.1x.webp \
	content/games/com.bscotch.crashlands/images/default.webp \
	content/games/com.bscotch.crashlands/images/default.1x.webp \
	content/games/com.DarongStudio.Colorzzle/images/default.webp \
	content/games/com.DarongStudio.Colorzzle/images/default.1x.webp \
	content/games/com.terribletoybox.thimbleweedparkandroid/images/default.webp \
	content/games/com.terribletoybox.thimbleweedparkandroid/images/default.1x.webp \
	content/games/com.inkle.eightydays/images/default.webp \
	content/games/com.inkle.eightydays/images/default.1x.webp \
	content/games/nz.co.codepoint.minimetro/images/default.webp \
	content/games/nz.co.codepoint.minimetro/images/default.1x.webp \


CVT_IMAGES=\
	content/games/com.bonusxp.legend/images/default.png \


images: $(1X_IMAGES) $(WEBP_IMAGES) $(CVT_IMAGES)

build: images assets
	hagen -b http://localhost:8080 -D

run: build
	cd output && python3 -m http.server 8080
