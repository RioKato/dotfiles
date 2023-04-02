FROM kalilinux/kali-rolling:latest
WORKDIR /work

COPY apt.txt .
COPY repo.txt .
COPY tool.txt .
COPY install.sh .
RUN chmod +x install.sh && ./install.sh
RUN rm apt.txt repo.txt tool.txt install.sh

RUN git clone https://github.com/RioKato/dotfiles.git ~/dotfiles
RUN chmod +x ~/dotfiles/deploy.sh && ~/dotfiles/deploy.sh

RUN updatedb

CMD ["/bin/zsh"]
