From centos
MAINTAINER sahsu.mobi@gmail.com
ENV OPSMANAGER_VERSION=1.8.1.290-1 \
    OPSMANAGER_CFG=/opt/mongodb/mms/conf/conf-mms.properties \
    OPSMANAGER_BACKUPCFG=/opt/mongodb/mms-backup-daemon/conf/conf-daemon.properties \
    OPSMANAGER_MONGO_APP=localhost:27017 \
    OPSMANAGER_CENTRALURL=localhost \
    OPSMANAGER_CENTRALURLPORT=8080 \
    OPSMANAGER_BACKUPURL=localhost \
    OPSMANAGER_BACKUPURLPORT=8081 \
    OPSMANAGER_FROMEMAIL=nobody@nobody \
    OPSMANAGER_ADMINEMAIL=nobody@nobody \
    OPSMANAGER_REPLYTOEMAIL=nobody@nobody \
    OPSMANAGER_ADMINFROMEMAIL=nbody@nobody \
    OPSMANAGER_BOUNCEEMAIL=nobody@nobody \
    OPSMANAGER_APPLOG=/opt/mongodb/mms/logs \
    OPSMANAGER_BACKUPLOG=/opt/mongodb/mms-backup-daemon/logs \
    OPSMANAGER_BACKUPMONGO=localhost:27017 \
    OPSMANAGER_BACKUPPATH=/backup/ 
#    OPSMANAGER_BACKUPSUPPORTVERSION=3.0.6 2.6.11 

# download url: https://www.mongodb.com/subscription/downloads/ops-manager
# sample Ops manager download url: https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-1.8.1.290-1.x86_64.rpm
# backup : https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-backup-daemon-1.8.1.290-1.x86_64.rpm

# INSTALL MMS & MMS-BACKUP
RUN  curl -OL https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-${OPSMANAGER_VERSION}.x86_64.rpm \
    && rpm -ivh mongodb-mms-${OPSMANAGER_VERSION}.x86_64.rpm && rm -f mongodb-mms-${OPSMANAGER_VERSION}.x86_64.rpm \
    && curl -OL https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-backup-daemon-${OPSMANAGER_VERSION}.x86_64.rpm \
    && rpm -ivh mongodb-mms-backup-daemon-${OPSMANAGER_VERSION}.x86_64.rpm && rm -f mongodb-mms-backup-daemon-${OPSMANAGER_VERSION}.x86_64.rpm \
    && cd /opt/mongodb/ && rm -fr mms-backup-daemon/jdk && cd mms-backup-daemon && ln -s ../mms/jdk .

RUN echo '[10gen] ' >> /etc/yum.repos.d/10gen.repo && \
echo 'name=10gen Repository' >> /etc/yum.repos.d/10gen.repo && \
echo 'baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64' >> /etc/yum.repos.d/10gen.repo && \
echo 'gpgcheck=0' >> /etc/yum.repos.d/10gen.repo && \
echo 'enabled=1'  >> /etc/yum.repos.d/10gen.repo && \
yum install -y mongodb-org-server && yum clean all

# INSTALL few related package
RUN yum install python-setuptools sudo nmap telnet openssl net-tools -y \
    && easy_install supervisor \
    && yum remove -y wget && yum clean all

EXPOSE ${OPSMANAGER_CENTRALURLPORT}/tcp ${OPSMANAGER_BACKUPURLPORT}/tcp
VOLUME [${OPSMANAGER_APPLOG}, ${OPSMANAGER_BACKUPLOG}]

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:start"]
