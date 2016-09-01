FROM python:slim

MAINTAINER Trevor Sullivan <trevor.sullivan@clusterhq.com>

RUN mkdir /app

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

CMD ["python", "import.py"]