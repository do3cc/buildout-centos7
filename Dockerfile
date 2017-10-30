
# buildout-centos7
FROM centos/s2i-base-centos7
MAINTAINER Patrick Gerken <gerken@patrick-gerken.de>

EXPOSE 8080

ENV PYTHON_VERSION=2.7 \
    PATH=$HOME/.local/bin/:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PIP_NO_CACHE_DIR=off


ENV SUMMARY="Platform for building and running Python $PYTHON_VERSION applications built with buildout" \
    DESCRIPTION="Python $PYTHON_VERSION available as docker container is a base platform for \
building and running various Python $PYTHON_VERSION applications and frameworks using buildout. \
Python is an easy to learn, powerful programming language. It has efficient high-level \
data structures and a simple but effective approach to object-oriented programming. \
Python's elegant syntax and dynamic typing, together with its interpreted nature, \
make it an ideal language for scripting and rapid application development in many areas \
on most platforms."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Python 2.7" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="buildout,builder,python,python27,rh-python27" \
      name="do3cc/buildout-centos7" \
      version="2.7" \
      release="1" \
      maintainer="Patrick Gerken <gerken@patrick-gerken.de>"

RUN yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/Packages/w/wv-1.2.7-2.el6.x86_64.rpm
RUN yum install -y epel-release
RUN rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
RUN yum install -y centos-release-scl && \
    INSTALL_PKGS="libjpeg-turbo libjpeg-turbo-devel \
    openssl-devel libxslt-devel readline-devel libmemcached-devel \
    unixODBC-devel postgresql-devel graphviz-devel \
    python27 python27-python-devel python27-python-setuptools \
	python27-python-pip python-devel openldap-devel libdb-devel \
    freetds-devel \
    nss_wrapper \
    gcc-c++ patch \
    make which \
    poppler-utils" && \
    yum install -y --setopt=tsflags=nodocs --enablerepo=epel,centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH.
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Copy extra files to the image.
COPY ./root/ /

# Create a Python virtual environment for use by any application to avoid
# potential conflicts with Python packages preinstalled in the main Python
# installation.
RUN source scl_source enable python27 && \
    virtualenv /opt/app-root && \
    /opt/app-root/bin/pip install zc.buildout

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /opt/app-root && chmod -R ug+rwx /opt/app-root

# Ensure that odbc is configured to work with freetds
COPY freetds /tmp/freetds

RUN cat /tmp/freetds >> /etc/odbcinst.ini && rm /tmp/freetds

USER 1001

# Set the default CMD to print the usage of the language image.
CMD $STI_SCRIPTS_PATH/usage
