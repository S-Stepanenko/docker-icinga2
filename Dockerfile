# Dockerfile for icinga2 with icingaweb2
# https://github.com/jjethwa/icinga2

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
    curl gnupg gnupg2 gnupg1

RUN export DEBIAN_FRONTEND=noninteractive \
    && curl -s https://packages.icinga.com/icinga.key \
    | apt-key add - \
    && echo "deb http://packages.icinga.org/debian icinga-$(lsb_release -cs) main" > /etc/apt/sources.list.d/icinga2.list \
    && echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" > /etc/apt/sources.list.d/$(lsb_release -cs)-backports.list \
    && apt-get update \
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
    && mv /etc/icinga2/ /etc/icinga2.dist \
    && mkdir -p /etc/icinga2 \
    && mkdir -p /var/log/icinga2 \
    && chmod 755 /var/log/icinga2 \
    && chown nagios:adm /var/log/icinga2 \
    && chmod u+s,g+s \
    /bin/ping \
    /bin/ping6 \
    /usr/lib/nagios/plugins/check_icmp

EXPOSE 5665

# Initialize and run Supervisor
ENTRYPOINT ["/opt/run"]