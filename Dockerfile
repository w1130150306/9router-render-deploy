FROM decolua/9router:latest

# Install git for config persistence via GitHub
RUN apk add --no-cache git openssh-client-default

COPY entrypoint.sh /custom-entrypoint.sh
RUN chmod +x /custom-entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/custom-entrypoint.sh"]