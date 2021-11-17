FROM mongo:latest
COPY start_mongo.sh /usr/local/bin
RUN chmod 755 /usr/local/bin/start_mongo.sh
ENTRYPOINT ["/usr/local/bin/start_mongo.sh"]