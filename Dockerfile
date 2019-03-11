FROM intersoftlab/duplicati:2.0
ADD ./init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT /init.sh