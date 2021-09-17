FROM centos/python-36-centos7:latest

LABEL io.k8s.display-name="JupyterHub" \
      io.k8s.description="JupyterHub." \
      io.openshift.tags="builder,python,jupyterhub" \
      io.openshift.s2i.scripts-url="image:///opt/app-root/builder"

USER root

COPY . /tmp/src

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src && \
    mv /tmp/src/.s2i/bin /tmp/scripts

RUN curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash - && \
    yum remove -y nodejs npm && \
    yum install -y nodejs

RUN node -v && npm -v

USER 1001

ENV NPM_CONFIG_PREFIX=/opt/app-root \
    PYTHONPATH=/opt/app-root/src
    
RUN npm install -g configurable-http-proxy

RUN node -v && npm -v

RUN /tmp/scripts/assemble

CMD [ "/opt/app-root/builder/run" ]
