FROM mysql:latest
USER root
COPY ./docker/include/ /

ARG MYSQL_ROOT_PASSWORD 
ENV MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD 

RUN mkdir -p /var/run/mysqld
RUN chown mysql:mysql /var/run/mysqld