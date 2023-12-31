#************************************************************#
#  Label Generator for QBO                                   #
#                                                            #
#  Written by Yuri H. Galvao <yuri@galvao.ca>, January 2023  #
#************************************************************#

# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.9.16-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

# Install production dependencies.
RUN apt -y install apt-transport-https
RUN apt update
RUN apt -y upgrade
RUN apt -y install tzdata
RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/America/Winnipeg /etc/localtime
RUN apt -y install libreoffice-base libreoffice
#openjdk8-jre
RUN pip install --no-cache-dir -r requirements.txt

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
#CMD ["/usr/local/bin/gunicorn", "--config", "gunicorn_config.py", "app:app"]
