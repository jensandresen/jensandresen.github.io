TAG=blog-builder
CONTENT=${PWD}/.blog/hugo
PORT=1313

init:
	@cd .blog && docker build -t $(TAG) .

hugo:
	@cd .blog && docker run -it --rm -p 1313:1313 -v "$(CONTENT)":/blog $(TAG) $(args)

clean:
	@cd .blog && sh ./clean.sh

server:
	@cd .blog && docker run -it --rm -p 1313:1313 -v "$(CONTENT)":/blog $(TAG) server -D --bind=0.0.0.0