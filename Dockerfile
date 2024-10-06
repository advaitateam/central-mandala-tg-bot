FROM python:3.12-alpine3.19@sha256:849ed6079c9f797ca9c1b7d6aea1c00aea3ac35110cbd0d6003f15950017ea8d

RUN apk add --no-cache --virtual .build-deps \
  ca-certificates git openssl-dev openssh-client curl

# if git needed
# RUN apk add --no-cache --virtual .build-deps \
#  ca-certificates musl-dev openssl-dev openssh-client git

RUN addgroup -S python && adduser -S python -G python
USER python

WORKDIR /app/

# Copying requirements
COPY --chown=python:python . .
# ENV PATH="/usr/local/app/venv/bin:$PATH"

RUN pip install -r requirements.txt

CMD ["./make.sh", "run"]
