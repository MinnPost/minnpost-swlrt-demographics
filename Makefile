###
# Make file for the SWLRT demographics file.
#
# Downloads, filters, and converts data
#
###

# Directories
data := data
original := $(data)/original
build := $(data)/build
processing := $(data)/processing

# Sources
source_routes := ftp://gisftp.metc.state.mn.us/PlannedTransitwayAlignments.zip
source_stops := ftp://gisftp.metc.state.mn.us/PlannedTransitwayStations.zip
source_features := https://gist.githubusercontent.com/zzolo/791b7cd1153d65a4452d/raw/a3be1eaa5e4f328424c0948b31210370c9724925/map.geojson

# Local
local_routes_archive := $(original)/planned-transitways.zip
local_routes := $(original)/planned-transitways
local_routes_shp := $(original)/planned-transitways/PlannedTransitwayAlignments.shp
local_stops_archive := $(original)/planned-stations.zip
local_stops := $(original)/planned-stations
local_stops_shp := $(original)/planned-stations/PlannedTransitwayStations.shp
local_features := $(original)/area-features.geo.json

# Converted
geojson_routes := $(build)/swlrt-route.geo.json
geojson_stops := $(build)/swlrt-stops.geo.json

# Final
routes := $(data)/swlrt-route.geo.json
stops := $(data)/swlrt-stops.geo.json
features := $(data)/features.topo.json



# Download and unzip sources.  Transit way file has misspellings
$(local_routes_shp):
	mkdir -p $(original)
	curl -o $(local_routes_archive) "$(source_routes)"
	unzip $(local_routes_archive) -d $(local_routes)
	mv $(local_routes)/PlannedTranstiwayAlignments.cpg $(local_routes)/PlannedTransitwayAlignments.cpg
	mv $(local_routes)/PlannedTranstiwayAlignments.dbf $(local_routes)/PlannedTransitwayAlignments.dbf
	mv $(local_routes)/PlannedTranstiwayAlignments.prj $(local_routes)/PlannedTransitwayAlignments.prj
	mv $(local_routes)/PlannedTranstiwayAlignments.sbn $(local_routes)/PlannedTransitwayAlignments.sbn
	mv $(local_routes)/PlannedTranstiwayAlignments.sbx $(local_routes)/PlannedTransitwayAlignments.sbx
	mv $(local_routes)/PlannedTranstiwayAlignments.shp $(local_routes)/PlannedTransitwayAlignments.shp
	mv $(local_routes)/PlannedTranstiwayAlignments.shx $(local_routes)/PlannedTransitwayAlignments.shx
	touch $(local_routes_shp)

$(local_stops_shp):
	mkdir -p $(original)
	curl -o $(local_stops_archive) "$(source_stops)"
	unzip $(local_stops_archive) -d $(local_stops)
	touch $(local_stops_shp)

$(local_features):
	mkdir -p $(original)
	curl -o $(local_features) "$(source_features)"

download: $(local_routes_shp) $(local_stops_shp) $(local_features)
clean_download:
	rm -rv $(original)/*


# Convert and filter data files
$(routes): $(local_routes_shp)
	mkdir -p $(build)
	ogr2ogr -f "GeoJSON" $(geojson_routes) $(local_routes_shp) -overwrite -where "NAME = 'Southwest LRT'" -t_srs "EPSG:4326"
	cp $(geojson_routes) $(routes)

$(stops): $(local_stops_shp)
	mkdir -p $(build)
	ogr2ogr -f "GeoJSON" $(geojson_stops) $(local_stops_shp) -overwrite -where "Transitway = 'Green Line extension'" -t_srs "EPSG:4326"
	cp $(geojson_stops) $(stops)

$(features): $(local_features)
	topojson $(local_features) -p -o $(features)

convert: $(routes) $(stops) $(features)
clean_convert:
	rm -rv $(build)/*
	rm -rv $(routes)
	rm -rv $(stops)
	rm -rv $(features)


# General
all: convert
clean: clean_download clean_convert
