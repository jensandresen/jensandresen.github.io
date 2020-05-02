TAG=hugo-test
CONTENT=${PWD}/.blog/hugo
PORT=1313

init:
	docker build -t $(TAG) .

hugo:
	@docker run -it --rm -p 1313:1313 -v "$(CONTENT)":/blog $(TAG) $(args)

server:
	@docker run -it --rm -p 1313:1313 -v "$(CONTENT)":/blog $(TAG) server -D --bind=0.0.0.0