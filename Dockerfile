FROM debian:buster

ENV APACHE2_HTTP=REDIRECT \
    # ICINGA2_FEATURE_GRAPHITE=false \
    # ICINGA2_FEATURE_GRAPHITE_HOST=graphite \
    # ICINGA2_FEATURE_GRAPHITE_PORT=2003 \
    # ICINGA2_FEATURE_GRAPHITE_URL=http://graphite \
    # ICINGA2_FEATURE_GRAPHITE_SEND_THRESHOLDS="true" \
    # ICINGA2_FEATURE_GRAPHITE_SEND_METADATA="false" \
    ICINGA2_USER_FULLNAME="Icinga2"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    curl gnupg gnupg2 gnupg1 ca-certificates supervisor locales pwgen

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --install-recommends \
    icinga2 \
    icinga2-ido-pgsql \
    icingacli \
    monitoring-plugins \
    libmonitoring-plugin-perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ADD content/ /

# Final fixes
RUN true \
    && sed -i 's/vars\.os.*/vars.os = "Docker"/' /etc/icinga2/conf.d/hosts.conf \
    #&& mv /etc/icinga2/ /etc/icinga2.dist \
    #&& mkdir -p /etc/icinga2 \
    && mkdir -p /var/log/icinga2 \
    && chmod 755 /var/log/icinga2 \
    && chown nagios:adm /var/log/icinga2 \
    && chmod u+s,g+s \
    /bin/ping \
    /bin/ping6 \
    /usr/lib/nagios/plugins/check_icmp

RUN icinga2 api setup \
    && icinga2 feature enable ido-pgsql livestatus compatlog command checker

EXPOSE 5665

# Initialize and run Supervisor
ENTRYPOINT ["/opt/run"]