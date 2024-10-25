.PHONY: build

build:
	@echo "Building New Image"
	docker build -t kxfer:latest .

run:
	@echo "Runing kxfer Container"
	docker run -d -p 8000:8000 --rm --name uknow  kxfer

destroy:
	@echo "Runing kxfer Container"
	docker stop uknow
	docker image rm kxfer

rebuild:
	@echo "Restart the service"
	docker stop uknow
	docker image rm kxfer
	docker build -t kxfer:latest .
	docker run -d -p 8000:8000 --rm --name uknow  kxfer