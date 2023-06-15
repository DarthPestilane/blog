# make build && make deploy

.PHONY: build
build: clean
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
	rsync -azvhP ./public/ yecao:/root/docker/blog/public/ --delete

.PHONY: clean
clean:
	npx hexo clean
	rm -rf db.json
