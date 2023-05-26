FROM grafana/grafana:9.5.1

USER grafana


ENV GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS=grafana-mongodb-opensource-datasource

RUN grafana-cli --pluginUrl https://github.com/SiemaApplications/mongodb-grafana/archive/refs/tags/v0.9.2.zip plugins install grafana-mongodb-opensource-datasource
RUN grafana-cli plugins install frser-sqlite-datasource 3.1.0

COPY ./etc/grafana/provisioning /etc/grafana/provisioning

COPY ./assets/img/Vossloh_Logo_svg_O.svg /usr/share/grafana/public/img/grafana_icon.svg
