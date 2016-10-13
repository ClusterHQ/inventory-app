FROM python:slim

MAINTAINER Ryan Wallner <ryan@clusterhq.com>

RUN mkdir /app

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

ENTRYPOINT ["python", "add_dealers.py"]
