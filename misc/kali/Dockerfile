FROM kalilinux/kali-rolling:latest
WORKDIR /work

COPY apt.txt .
COPY repo.txt .
COPY tool.txt .
COPY install.sh .
RUN chmod +x install.sh
RUN ./install.sh
RUN rm apt.txt repo.txt tool.txt install.sh

RUN git clone https://github.com/RioKato/dotfiles.git ~/dotfiles
RUN chmod +x ~/dotfiles/deploy.sh
RUN ~/dotfiles/deploy.sh

RUN updatedb

CMD ["/bin/zsh"]
