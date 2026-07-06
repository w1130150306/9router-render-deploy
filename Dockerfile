FROM decolua/9router:latest

RUN apt-get update && apt-get install -y git openssh-client && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /custom-entrypoint.sh
RUN chmod +x /custom-entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/custom-entrypoint.sh"]