# podman run -d --net host -v /home/alex/.eyaml-af:/etc/puppetlabs/puppet/eyaml -v `pwd`/hieradata:/etc/puppetlabs/code/environments/production/hieradata -v `pwd`/manifests:/etc/puppetlabs/code/environments/production/manifests -v `pwd`/modules:/etc/puppetlabs/code/environments/production/modules --name puppet --hostname localhost localhost/af/puppetserver:6.9.1
#
# podman start puppet
#
# podman stop puppet

FROM rockylinux:8

ENV PUPPETSERVER_VERSION="6"

ENV LANG="en_US.UTF-8"

RUN dnf install -y http://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/e/epel-release-8-19.el8.noarch.rpm && \
    dnf install -y https://yum.puppet.com/puppet${PUPPETSERVER_VERSION}-release-el-8.noarch.rpm && \
    dnf install -y puppetserver rsync && \
    dnf clean all

RUN /opt/puppetlabs/bin/puppetserver gem install --no-document hiera-eyaml toml-rb

# COPY hiera.yaml /etc/puppetlabs/code/environments/production/hiera.yaml
COPY hiera.yaml /etc/puppetlabs/puppet/hiera.yaml

RUN mkdir -p /etc/puppetlabs/puppet/{eyaml,_eyaml} && \
    chown -R puppet:root /etc/puppetlabs/puppet/{eyaml,_eyaml} && \
    chmod 0700 /etc/puppetlabs/puppet/{eyaml,_eyaml} && \

    mkdir -p /etc/puppetlabs/code && \
    chown root:puppet /etc/puppetlabs/code && \
    chmod 0750 /etc/puppetlabs/code && \
    mkdir -p /etc/puppetlabs/code/environments/production && \
    chown root:puppet /etc/puppetlabs/code/environments /etc/puppetlabs/code/environments/production && \
    chmod 0770 /etc/puppetlabs/code/environments /etc/puppetlabs/code/environments/production && \
    mkdir -p /etc/puppetlabs/code/environments/production/{manifests,modules,hieradata} && \
    chown root:puppet /etc/puppetlabs/code/environments/production/{manifests,modules,hieradata} && \
    chmod 0770 /etc/puppetlabs/code/environments/production/{manifests,modules,hieradata} && \
    /opt/puppetlabs/bin/puppet config set certname localhost --section master && \
    /opt/puppetlabs/bin/puppet config set autosign true --section master && \
    sed -i.orig 's,^.*max-active-instances:.*$,max-active-instances: 1,' /etc/puppetlabs/puppetserver/conf.d/puppetserver.conf

    # # Clear all ACL from existing files
    # setfacl -R -b /etc/puppetlabs/code

    # # Set ACL and defaults for group `puppet`
    # setfacl -R -m 'd:g:puppet:rwx,g:puppet:rwx' /etc/puppetlabs/code/environments

    # # Set ACL and defaults for user `puppetizer`
    # setfacl -m 'u:puppetizer:r-x' /etc/puppetlabs/code
    # setfacl -R -m 'd:u:puppetizer:rwx,u:puppetizer:rwx' /etc/puppetlabs/code/environments

    # # # Set ACL and defaults for user `gitlab-runner`
    # # setfacl -m 'u:gitlab-runner:r-x' /etc/puppetlabs/code
    # # setfacl -R -m 'd:u:gitlab-runner:rwx,u:gitlab-runner:rwx' /etc/puppetlabs/code/environments

# RUN dnf install -y https://github.com/krallin/tini/releases/download/v0.18.0/tini_0.18.0.rpm

COPY entrypoint /entrypoint
RUN chmod +x /entrypoint

EXPOSE 8140/TCP

# ENTRYPOINT ["tini", "--"]
# CMD ["/opt/puppetlabs/server/apps/puppetserver/bin/puppetserver", "foreground"]

ENTRYPOINT ["/entrypoint"]
CMD ["/opt/puppetlabs/server/apps/puppetserver/bin/puppetserver", "foreground"]

# ENTRYPOINT ["/opt/puppetlabs/server/apps/puppetserver/bin/puppetserver", "foreground"]


###
#   VERSIONNING OF IMAGE
#   LABELS AND DESCRIPTION

# WARNING ARG and FROM: https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
# ARG VCS_REF
# ARG VCS_URL
ARG BUILD_DATE
ARG VERSION_IMAGE

ENV SUMMARY="Puppetserver $PUPPETSERVER_VERSION and Rsync"

ENV DESCRIPTION="\n\
    ${SUMMARY} \n\
    \n\
    This container bundles a Puppetserver v$PUPPETSERVER_VERSION and Rsync \n\
    \n\
    Usage: \n\
    \tRsync your code in bla bla bla, \n\
    \tTODO. \n\
    \n\
    \tFor example: \n\
    \tTODO \n\
    "

LABEL org.label-schema.vendor="Puppet" \
    org.label-schema.url="https://github.com/puppetlabs/puppetserver" \
    org.label-schema.name="Puppet Server $PUPPETSERVER_VERSION and Rsync" \
    org.label-schema.license="Apache-2.0" \
    org.label-schema.vcs-url="https://github.com/puppetlabs/puppetserver" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.dockerfile="/Dockerfile" \
    org.label-schema.build-date=$BUILD_DATE \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.title=$SUMMARY \
    org.opencontainers.image.description=$DESCRIPTION \
    org.opencontainers.image.version=$VERSION_IMAGE \
    org.label-schema.vendor=''
    # org.opencontainers.image.vcs-ref=$VCS_REF \
    # org.opencontainers.image.source=$VCS_URL \
    # org.opencontainers.image.documentation="docker run --rm -ti bla bla ..." \
