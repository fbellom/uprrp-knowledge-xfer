# Docker Compose Orchestration

Docker and Docker Compose are widely used tools for managing containerized applications, allowing developers to manage multiple services within an application seamlessly. In this demo, we share how to built and deployed a multi-container application using Docker Compose.

Let’s walk through the step-by-step process to create Docker images for frontend and backend services, and finally deploy the app using Docker Compose.

## Demo 1: Three Web Servers

This Demo shows how to create multiple instances from the same image. this can be an example of several webservers with different content.

### Step 1: Create the index.html

```html
<html>
  <head>
    <title>UKnowXChange</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"
      rel="stylesheet"
    />
  </head>
  <body class="bg-gray-100">
    <header
      class="bg-black text-white p-4 flex justify-between items-center"
    ></header>
    <main class="flex">
      <h1>Welcome to UKnowXChange</h1>
    </main>
  </body>
</html>
```

### Step 2: Create a Dockerfile for Webserver

```docker
FROM ubuntu
RUN apt update -y
RUN apt install apache2 -y
COPY index.html /var/www/html
CMD ["/usr/sbin/apachectl","-D","FOREGROUND"]
```

### Step 3: Build Docker Images

- `docker build -t web1:v1 .`
- `docker build -t web2:v1 .`
- `docker build -t web3:v1 .`

### Step 4: Create a Docker Compose

Create a file named `docker-compose.yaml` or `compose.yaml` and write this code:

```yaml
services:
  webone:
    image: web1:v1
    ports:
      - "8100:80"
    networks:
      - app-network

  webtwo:
    image: web2:v1
    ports:
      - "8200:80"
    networks:
      - app-network

  webthree:
    image: web3:v1
    ports:
      - "8300:80"
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

This file is pretty simple, and its syntax just

- Assign a name (webone, webtwo, webthree)
- Map the docker image,
- Map the external port to the internal exposed port
- Attach the container to a specific network.

This files are extremely flexible to create pretty granular deployments.

### Step 5: Run the Containers

To start all the containers just use the following command

```bash
$ docker compose up -d --build
```

This command do as follow:

- **docker compose up**: Start the container as defined by the compose file
- **-d**: execute the containers detached from the standard output.
- **--build**: If needed, the startup of the compose files will rebuild the container with the lates config and data.

### Step 6: Validation

You can check the outcome of the execution with the following commands

- `docker compose ps -a`
- `docker compose logs`

### Step 7: Managing the Containers

- `docker compose stop` : to stop the execution.
- `docker compose rm` : to erase all the containers.

## Demo 2: Python Flask and Redis

This demo aims to introduce fundamental concepts of Docker Compose by guiding you through the development of a basic Python web application.

Using the Flask framework, the application features a hit counter in Redis, providing a practical example of how Docker Compose can be applied in web development scenarios.

The concepts demonstrated here should be understandable even if you're not familiar with Python.

### Step 1: Create the Python App.

Use this simple code for an Flask App. The goal is not apply Best practices, but to understand the usage of docker compose.

```python
import time

import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as e:
            if retries == 0:
                raise e
            retries -= 1
            time.sleep(0.5)


@app.route('/')
def index():
    count = get_hit_count()
    return f'Hello UKnowXChange, I have seen {count} times \n'
```

This is a pretty simple app, integrating two common tools used on real-world applications.

Flasks will expose a URI with a function using Redis In-Memory Database, to increase a counter of hits.

Create a `requirements.txt` file and add to it the following lines.

```txt
flask
redis
```

Now the application is complete.

### Step 2: Create a Dockerfile for Python App

This is a more comprehensive Dockerfile to prepare a python image for Flask and to use Enviromental Variables

```docker
FROM python:3.10-alpine
WORKDIR /code
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
RUN apk add --no-cache gcc musl-dev linux-headers
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
EXPOSE 5000
COPY . .
CMD ["flask","run","--debug"]
```

This application use the `flask cli` so in the environmental variables you need to set the name of the main flask app file (_app.py_) and in which IP the container will accept connections.

This is a Development Runtime, so for Production ready, you will need a WSGI server like Gunicorn.

### Step 3: Create a Docker Compose

This is another approach to create a compose file.

```yaml
services:
  web:
    build: .
    ports:
      - "5000:5000"
    networks:
      - webapp-netw
  redis:
    image: "redis:alpine"
    networks:
      - webapp-netw

networks:
  webapp-netw:
    driver: bridge
```

The most interesting instruction is `build` where Compose will use the Dockerfile to create the image and the container during the startup.

The other difference is the `redis` service, which is calling the public official image from dockerhub.

Then they are using an specific docker network to connect each other. Docker Internally has a DNS-like service, which has accountability of the name of the containers, that's why no ip are used in the python Flask code to connect to Redis, it is just calling the hostname. See the line using that.

```python
cache = redis.Redis(host='redis', port=6379)
```

### Step 4: Run the Containers

To start all the containers just use the following command

```bash
docker compose up -d --build
```

### Step 5: Validation

You can check the outcome of the execution with the following commands

- `docker compose ps -a`
- `docker compose logs`

### Step 6: Managing the Containers

- `docker compose stop` : to stop the execution.
- `docker compose rm` : to erase all the containers.

That's All!!!
