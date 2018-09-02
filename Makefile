VERSION = 7.1.14

APP      := pixlr-offline
PACKAGES := $(shell go list -f {{.Dir}} ./...)
GOFILES  := $(addsuffix /*.go,$(PACKAGES))
GOFILES  := $(wildcard $(GOFILES))

.PHONY: clean docker binary

binary: bin/$(APP)

bin/$(APP): $(GOFILES) static/patched
	go run vendor/github.com/gobuffalo/packr/packr/main.go build -v -o bin/$(APP) -ldflags="-s -w"
	if >/dev/null 2>/dev/null which upx; then \
		upx bin/$(APP); \
	fi

docker: $(GOFILES) Dockerfile static/patched
	docker build -t "$(APP)":latest -t "$(APP)":$(VERSION) -f Dockerfile .

static/patched: Dockerfile.patch
	docker build -t "$(APP)-patch" -f Dockerfile.patch .
	docker run --rm -i -a stdout -a stderr -v "$$PWD/static":"/static" -w /static "$(APP)-patch" "\
		>/vanilla curl -sSL https://pixlr.com/editor/editor-$(VERSION).swf && \
		rdiff patch /vanilla delta patched"

clean:
	rm -rf bin/
