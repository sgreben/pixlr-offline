VERSION = 7.1.14

APP      := pixlr-offline
PACKAGES := $(shell go list -f {{.Dir}} ./...)
GOFILES  := $(addsuffix /*.go,$(PACKAGES))
GOFILES  := $(wildcard $(GOFILES))
VANILLA  := aHR0cHM6Ly9tZWdhLm56LyMhc01jVXpTNWIhb1laU2NXbFVac3RMVjByRWpyZ1pFM3VsRlZXSnJjUEt5RUFUOERHV2FlVQ==

.PHONY: clean docker binary

binary: bin/$(APP)

bin/$(APP): $(GOFILES) static/patched
	go run vendor/github.com/gobuffalo/packr/packr/main.go build -v -o bin/$(APP) -ldflags="-s -w"
	if >/dev/null 2>/dev/null which upx; then \
		upx bin/$(APP); \
	fi

docker: $(GOFILES) Dockerfile static/patched
	docker build -t "$(APP)":latest -t "$(APP)":$(VERSION) -f Dockerfile .

bin/$(APP)-$(VERSION)-docker-image.tar.gz: docker
	docker save "$(APP)":$(VERSION) -o "bin/$(APP)-$(VERSION)-docker-image.tar.gz"

static/patched: Dockerfile.patch
	docker build -t "$(APP)-patch" -f Dockerfile.patch .
	docker run --rm -i -a stdout -a stderr -v "$$PWD/static":"/static" -w /static "$(APP)-patch" "$(VANILLA)" delta patched

clean:
	rm -rf bin/
	rm -f static/patched
