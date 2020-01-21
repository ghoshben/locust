FROM python:3.6-alpine as builder

RUN apk --no-cache add g++ zeromq-dev libffi-dev
COPY . /src
WORKDIR /src
RUN pip install .

FROM python:3.6-alpine

RUN apk --no-cache add zeromq && adduser -s /bin/false -D locust
COPY --from=builder /usr/local/lib/python3.6/site-packages /usr/local/lib/python3.6/site-packages
COPY --from=builder /usr/local/bin/locust /usr/local/bin/locust
COPY docker_start.sh docker_start.sh
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

# install chromedriver
RUN apt-get install -yqq unzip
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# set display port to avoid crash
ENV DISPLAY=:99

#selenium
RUN pip install selenium

#real_browser
RUN pip install git+https://github.com/nickboucart/realbrowserlocusts.git

RUN chmod +x docker_start.sh

EXPOSE 8089 5557 5558

USER locust
CMD ["./docker_start.sh"]
