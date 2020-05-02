TAG=blog-builder
CONTENT=${PWD}/.blog/hugo
PUBLISHED_CONTENT=$(CONTENT)/public/
PORT=1313
WWWROOT=${PWD}

init:
	@cd .blog && docker build -t $(TAG) .

hugo:
	@cd .blog && docker run -it --rm -p 1313:1313 -v "$(CONTENT)":/blog $(TAG) $(args)

clean:
	@cd .blog && sh ./clean.sh

server:
	@cd .blog && docker run -it --rm -p 1313:1313 -v "$(CONTENT)":/blog $(TAG) server -D --bind=0.0.0.0

publish:
	@cd .blog && docker run -it --rm -p 1313:1313 -v "$(CONTENT)":/blog $(TAG) --cleanDestinationDir && cp -r $(PUBLISHED_CONTENT) $(WWWROOT)

preview:
	@docker run --rm -p 1313:80 -v "$(WWWROOT)":/usr/share/nginx/html:ro nginx
