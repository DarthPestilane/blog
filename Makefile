# make build && make deploy

build:
	rm -rf db.json && hexo clean && hexo generate
run:
	hexo s
deploy:
	rsync -azvhP ./public/ vps:/var/local/www/blog/ --delete
deploy-github-page:
	hexo deploy
