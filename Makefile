# make build && make deploy
.PHONY: all

build:
	rm -rf db.json && hexo clean && hexo generate
new:
	hexo new post '$(name)'
run:
	hexo s
deploy:
	rsync -azvhP ./public/ tencent:/var/local/www/blog/ --delete
deploy-github-page:
	hexo deploy

clean:
	hexo clean
