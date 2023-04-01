From kalilinux/kali-rolling:latest

COPY apt.txt /tmp/apt.txt
RUN apt update && apt install -y $(cat /tmp/apt.txt)
RUN rm /tmp/apt.txt
RUN go install github.com/ropnop/kerbrute@latest
RUN pip install git-dumper
RUN pip install git+https://github.com/GerbenJavado/LinkFinder.git
RUN npm -g install js-beautify
