# make build && make deploy

build:
	rm -rf db.json && hexo clean && hexo generate
deploy:
	rsync -azvhP ./public/ vps:/var/local/www/blog/ --delete
deploy-github-page:
	hexo deploy
