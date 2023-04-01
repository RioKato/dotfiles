NAME=kalilinux/kali-rolling:custom

build:
	sudo docker build -t $(NAME) .
clean:
	sudo docker rmi $(NAME)
	sudo docker image prune
