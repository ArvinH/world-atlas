#!/bin/bash

rm -rvf world

world_shp() {
    mkdir -p build
    curl -z build/ne_10m_populated_places.zip -o build/ne_$1_admin_1_populated_places.zip http://naciscdn.org/naturalearth/$1/cultural/ne_$1_admin_1_populated_places.zip
    unzip -od build build/ne_$1_admin_1_populated_places.zip
    chmod a-x build/ne_$1_admin_1_populated_places.*
}

world() {
    world_shp $1
    mkdir -p world
    geo2topo -q 1e5 -n populated_places=<( \
        shp2json -n build/ne_$1_admin_1_populated_places.shp \
        | ndjson-map '(d.id = d.properties.iso_n3, delete d.properties, d)' \
        | geostitch -n) \
        | topomerge land=populated_places \
        > world/$1.json
}

world 110m
world 50m
