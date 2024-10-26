# Deploy a NodeJS App with Docker

In this demo, we are going to create a simple Node.JS app which display a simple message. The Goal is to understand the process to containerize it with Docker.

## Prerequisites

- Docker Installed
- Node Installed on your machine

## STEP 1: Setting up a Node.JS Express

The application is extremely simple, the goal is not to discuss about Node here, but to understand the process to put this inside a Docker container.

Create a file named `server.js` with the following content:

```js
const express = require("express");
const app = express();
const port = 3000;

app.get("/", (req, res) => {
  res.send("Hello from UKnowXChange");
});

app.listen(port, () => {
  console.log(`App running on http://localhost:${port}`);
});
```

Once you created this code, to try it locally at your terminal, install all the dependencies

```bash
npm init -y
npm install express
```

Finally run `node server.js`, you shoud see something similar to `App running on http://localhost:3000`

n=Now you can run `curl -X GET http://127.0.0.1:3000/` and the server should response `Hello from Knowledge Transfer`

Your NodeJS Service is complete!!

## STEP 2: Create Dockerfile

In this phase, we create the Dockerfile using the following example:

```docker
FROM node:23.0-alpine
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["node","server.js"]
```

Let's understand each command

- FROM: Specifies the base image for the container
- WORKDIR: Set the working directory inside the container
- COPY: copy local folder files to the container
- RUN: Executes commands in the current container layer, to build the environment needed for the app
- EXPOSE: Informs to docker engine which network port is open at the container to receive connections
- CMD: is the actual command invoking the app.

## STEP 3: Build the image

Now with the code tested, the next step is to build the image to use locally or to move it to a registry.

Use the following command

```sh
 docker build -t my-node-app:latest .
```

After the process of image building run

```bash
$ docker image ls
REPOSITORY    TAG       IMAGE ID       CREATED          SIZE
my-node-app   latest    ce3cc12bd7fc   7 seconds ago    165MB
```

The output shows the newly created image with the `latest` tag, so this is a sucessful build.

## STEP 4: Run the container

The final step is to run the app from the actual image, in order to validate everything is working.

Use the `docker run -p 3000:3000 --rm --name my-app my-node-app`

Let's review each command

- **docker run**: will start a new instance of the conatiner image.
- **p HOST:CONTAINER**: is the port Host will use to allow access from outside world to container
- **rm**: is to make the container ephimeral, so when you stop it, it will be destroyed
- **name**: is to assign a meaninful name to the instance

After the execution, you can use curl again to test the application.

That's all.

## Extra

You can create an auxiliary Makefile to simplify the cli command input

```Makefile
build:
	@echo "Building New Image"
	docker build -t my-node-app:latest .

run:
	@echo "Runing demo Container"
	docker run -p 3000:3000 --rm my-node-app

destroy:
	@echo "Destroy demo Image"
	docker image rm my-node-app
```

to use it just try `make build`, `make run` and `make destroy`.
