FROM python:3.10.15-alpine3.20
WORKDIR /knwodocs
COPY . .
RUN pip install mkdocs-material
EXPOSE 8080
CMD ["mkdocs","serve"]