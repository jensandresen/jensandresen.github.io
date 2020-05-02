FROM alpine

RUN apk add curl
RUN apk add tar

WORKDIR /usr/local/bin
RUN curl -o dl-hugo.tar.gz -L https://github.com/gohugoio/hugo/releases/download/v0.69.2/hugo_0.69.2_Linux-64bit.tar.gz

RUN tar -xvzf ./dl-hugo.tar.gz

WORKDIR /blog

EXPOSE 1313

ENTRYPOINT [ "hugo" ]