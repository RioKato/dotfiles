From kalilinux/kali-rolling:latest

COPY apt.txt /tmp/apt.txt
RUN apt update && apt install -y $(cat /tmp/apt.txt)
RUN rm /tmp/apt.txt
