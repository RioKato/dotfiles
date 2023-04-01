From kalilinux/kali-rolling:latest
WORKDIR /work

COPY apt.txt apt.txt
RUN apt update && apt install -y $(cat apt.txt)
RUN rm apt.txt

RUN git clone https://github.com/RioKato/dotfiles.git ~/dotfiles
RUN bash ~/dotfiles/deploy.sh

COPY repo.txt repo.txt
COPY tool.txt tool.txt
COPY install.sh install.sh
RUN sh install.sh
RUN rm repo.txt tool.txt install.sh

RUN go install github.com/ropnop/kerbrute@latest
RUN pip install git-dumper
RUN npm -g install js-beautify
RUN cargo install urlencode

RUN updatedb
