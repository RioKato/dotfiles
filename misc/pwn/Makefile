NAME=pwn

build:
	sudo docker buildx build -t $(NAME) .
clean:
	sudo docker rmi $(NAME)
	sudo docker image prune
