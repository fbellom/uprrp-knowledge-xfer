.PHONY: build

build:
	@echo "Building New Image"
	docker build -t kxfer:latest .

run:
	@echo "Runing kxfer Container"
	docker run -p 8000:8000 --rm kxfer

destroy:
	@echo "Runing kxfer Container"
	docker image rm kxfer