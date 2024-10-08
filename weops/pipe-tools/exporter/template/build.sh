#!/bin/bash

for VERSION in v6-8 v5-17; do
  output_file="greenplum_exporter_${VERSION}.yaml"
  sed "s/{{VERSION}}/${VERSION}/g" exporter.tpl > ../standalone/${output_file}
done
