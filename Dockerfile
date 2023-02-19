FROM python:3.11 AS base

WORKDIR /material/
RUN pip install mkdocs
RUN pip install mkdocs-material
RUN pip install mkdocs-material-extensions

FROM base AS build
CMD ["mkdocs", "build"]

FROM base AS serve
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]
