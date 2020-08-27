FROM openjdk:alpine

ENV USER=keycloak
ENV HOME=/home/$USER
ENV KEYCLOAK_VERSION=8.0.2 \
    LAUNCH_JBOSS_IN_BACKGROUND=true \
    DISTRIBUTED_CACHE_OWNERS=1

RUN apk --no-cache add \
    ca-certificates \
    wget \
    jq \
    curl \
    bash && \
  rm -rf /var/cache/apk/* && \
  update-ca-certificates && \
  adduser -S $USER

## Expose application port and administration port
EXPOSE 8080 7600 9990

COPY toRoot $HOME/

RUN cd $HOME && \
    wget https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz &&\
    tar -xvf keycloak-${KEYCLOAK_VERSION}.tar.gz &&\
    rm keycloak-${KEYCLOAK_VERSION}.tar.gz && \
    mv $HOME/keycloak-${KEYCLOAK_VERSION}/ $HOME/keycloak

RUN cd $HOME && \
    mkdir -p $HOME/logs && \
    mkdir -p $HOME/keycloak/modules/org/postgres/main &&\
    cd $HOME/keycloak/modules/org/postgres/main &&\
    wget https://jdbc.postgresql.org/download/postgresql-42.2.5.jar && \
    mv $HOME/standalone-ha.xml /$HOME/keycloak/standalone/configuration/standalone-ha.xml && \
    mv $HOME/module.xml /$HOME/keycloak/modules/org/postgres/main/module.xml && \
    # cleanup
    chmod 755 $HOME/*.sh && \
    chown -R $USER $HOME

USER $USER
WORKDIR /home/$USER
CMD ["./runapp.sh"]
