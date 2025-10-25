NAME=kalilinux/kali-rolling:custom

build:
	sudo docker buildx build -t $(NAME) --network host .
clean:
	sudo docker rmi $(NAME)
	sudo docker image prune
	sudo docker builder prune
