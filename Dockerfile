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
    curl wget gnupg gnupg2 gnupg1 ca-certificates supervisor locales pwgen

RUN export DEBIAN_FRONTEND=noninteractive \
    && wget -O - https://packages.icinga.com/icinga.key | apt-key add \
    && echo "deb https://packages.icinga.com/debian icinga-buster main" > /etc/apt/sources.list.d/icinga.list \
    && echo "deb-src https://packages.icinga.com/debian icinga-buster main" >> /etc/apt/sources.list.d/icinga.list\
    && apt update \
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
    && mkdir -p /var/log/icinga2 \
    && chmod 755 /var/log/icinga2 \
    && chown nagios:adm /var/log/icinga2 \
    && chmod u+s,g+s \
    /bin/ping \
    /bin/ping6 \
    /usr/lib/nagios/plugins/check_icmp

RUN icinga2 api setup \
    && icinga2 feature enable ido-pgsql livestatus compatlog command checker \
    && icinga2 node setup --master

EXPOSE 5665

ENTRYPOINT ["/opt/run"]