# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gzta android ios gzta-cross evm all test clean
.PHONY: gzta-linux gzta-linux-386 gzta-linux-amd64 gzta-linux-mips64 gzta-linux-mips64le
.PHONY: gzta-linux-arm gzta-linux-arm-5 gzta-linux-arm-6 gzta-linux-arm-7 gzta-linux-arm64
.PHONY: gzta-darwin gzta-darwin-386 gzta-darwin-amd64
.PHONY: gzta-windows gzta-windows-386 gzta-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

gzta:
	build/env.sh go run build/ci.go install ./cmd/gzta
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gzta\" to launch gzta."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gzta.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Gzta.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

lint: ## Run linters.
	build/env.sh go run build/ci.go lint

clean:
	./build/clean_go_build_cache.sh
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

gzta-cross: gzta-linux gzta-darwin gzta-windows gzta-android gzta-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gzta-*

gzta-linux: gzta-linux-386 gzta-linux-amd64 gzta-linux-arm gzta-linux-mips64 gzta-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-*

gzta-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gzta
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep 386

gzta-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gzta
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep amd64

gzta-linux-arm: gzta-linux-arm-5 gzta-linux-arm-6 gzta-linux-arm-7 gzta-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep arm

gzta-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gzta
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep arm-5

gzta-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gzta
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep arm-6

gzta-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gzta
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep arm-7

gzta-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gzta
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep arm64

gzta-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gzta
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep mips

gzta-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gzta
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep mipsle

gzta-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gzta
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep mips64

gzta-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gzta
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gzta-linux-* | grep mips64le

gzta-darwin: gzta-darwin-386 gzta-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gzta-darwin-*

gzta-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gzta
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-darwin-* | grep 386

gzta-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gzta
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-darwin-* | grep amd64

gzta-windows: gzta-windows-386 gzta-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gzta-windows-*

gzta-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gzta
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-windows-* | grep 386

gzta-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gzta
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gzta-windows-* | grep amd64
