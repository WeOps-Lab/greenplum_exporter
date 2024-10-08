#
# build container
#
FROM --platform=linux/amd64 golang:1.19-alpine as builder
WORKDIR /
ADD . /

COPY greenplumdb_exporter_linux_amd64 /greenplum_exporter
RUN chmod +x /greenplum_exporter

EXPOSE     9297
ENTRYPOINT [ "/greenplum_exporter" ]
