FROM intersoftlab/duplicati:stable
ADD ./init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT /init.sh