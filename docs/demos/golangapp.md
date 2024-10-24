# Deploying a Golang binary with Dockerfile builder

This is a demo in how to compile and deploy a golang app inside a container.

Go, also known as Golang, is an open-source programming language developed by Google in 2009. It
was designed to simplify the development of large-scale, concurrent systems while offering strong
performance.

## Prerequisites

- Docker Installed
- Node Installed on your machine

## STEP 1: Setting up a Go Web App

The application is extremely simple, the goal is not to discuss about Node here, but to understand the process to put this inside a Docker container.

```golang
package main

import(
    "fmt"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request){
    fmt.Fprintf(w, "Hello, from UKnowXChange!!")
}

func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe(":8001", nil)
}
```

Once you created this code, to try it locally at your terminal:

```bash
$ go run server.go
```

Now you can run `curl -X GET http://127.0.0.1:8001/` and the server should response `Hello, from UKnowXChange!!`

Your Go Webserver is complete.

## STEP 2: Create Dockerfile

This will be a type of image creation called "Multi-Stage build".

From Docker Documentation we know multi-stage builds use multiple FROM statements in your Dockerfile. Each FROM instruction can use a different base, and each of them begins a new stage of the build. You can selectively copy artifacts from one stage to another, leaving behind everything you don't want in the final image.

The following Dockerfile has two separate stages: one for building a binary, and another where the binary gets copied from the first stage into the next stage.

```docker
# Use the golang base image
FROM golang:1.18-alpine AS build

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go source file
COPY server.go .

# Build the Go app
RUN go build -o server server.go

# Start a new stage from scratch
FROM alpine:latest

# Create the directory
WORKDIR /app

# Copy the Pre-built binary file from the build stage
COPY --from=build /app/server .

# Expose the service port
EXPOSE 8001

# Command to run the binary
CMD ["./server"]
```

Here the most interesting command is `
COPY --from=build /app/server .` where the docker engine instruct to use the precompile binary in previous stage and pass it to the next image.

This is important for optimization and to reduce the size of the images.

## STEP 3: Build the image.

Now with the code tested, the next step is to build the image to use locally or to move it to a registry.

Use the following command

```bash
docker build -t my-golang-app:latest .
```

After the process, check the new image

```bash
$ docker image ls
REPOSITORY      TAG       IMAGE ID       CREATED        SIZE
my-golang-app   latest    adac096f0cce   21 hours ago   14.1MB
```

## STEP 4: Run the container

The final step is to run the app from the actual image, in order to validate everything is working.

Use the `docker run -p 8001:8001 --rm my-golang-app`

Let's review each command

- docker run: will start a new instance of the conatiner image.
- p HOST:CONTAINER: is the port Host will use to allow access from outside world to container
- rm: is to make the container ephimeral, so when you stop it, it will be destroyed

After the execution, you can use curl again to test the application.

That's all.

## Extra

You can create an auxiliary `Makefile` to simplify the cli command input

```Makefile
build:
	@echo "Building New Image"
	docker build -t my-golang-app:latest .

run:
	@echo "Runing demo Container"
	docker run -p 8001:8001 --rm my-golang-app

destroy:
	@echo "Destroy demo Image"
	docker image rm my-golang-app
```

to use it just try `make build`, `make run` and `make destroy`.
