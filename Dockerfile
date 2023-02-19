FROM python:3.11 AS base

WORKDIR /material/
RUN pip install mkdocs
RUN pip install mkdocs-material
RUN pip install mkdocs-material-extensions
RUN useradd -u 1000 mkdocs

FROM base AS build
USER mkdocs
CMD ["mkdocs", "build"]

FROM base AS serve
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]
