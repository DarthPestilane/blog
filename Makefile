# make build && make deploy

build:
	rm -rf db.json && hexo clean && hexo generate
deploy:
	rsync -azvh ./public/ vps:/var/local/www/blog/ --delete
deploy-github-page:
	hexo deploy
