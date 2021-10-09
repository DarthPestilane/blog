# make build && make deploy

.PHONY: build
build: clean
	rm -rf db.json
	npx hexo generate

.PHONY: new
new:
	npx hexo new post '$(name)'

.PHONY: draft
draft:
	npx hexo new draft '$(name)'

.PHONY: run
run:
	npx hexo s

.PHONY: deploy
deploy:
	rsync -azvhP ./public/ tencent:/var/local/www/blog/ --delete

.PHONY: clean
clean:
	npx hexo clean
