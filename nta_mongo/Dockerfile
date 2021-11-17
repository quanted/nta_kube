FROM mongo:latest
COPY start_mongo.sh /usr/local/bin
RUN chmod 755 /usr/local/bin/start_mongo.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/start_mongo.sh"]

EXPOSE 27017
CMD ["mongod"]