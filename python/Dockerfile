FROM ubuntu:latest
RUN mkdir /Paramx
WORKDIR /Paramx/
COPY . /Paramx/
RUN apt update
RUN apt install pip -y
RUN pip install -r requirements.txt