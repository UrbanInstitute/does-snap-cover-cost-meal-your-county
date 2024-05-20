.PHONY: clean default

default: public/county_topo_2021.json public/county_topo_2022.json public/county_topo_2023.json

clean: 
	rm -rf data/output

public/county_topo_2021.json: data/output/cb_2021_us_county_500k/cb_2021_us_county_500k.shp
	mkdir -p $(dir $@)
	npx mapshaper $^ \
		-filter "parseInt(STATEFP) < 60" \
		-filter-fields GEOID,NAME,NAMELSAD,STATE_NAME \
		-simplify visvalingam 3% \
		-o format=topojson $@
	touch $@

data/output/cb_2021_us_county_500k/cb_2021_us_county_500k.shp: data/output/cb_2021_us_county_500k.zip
	mkdir -p $(dir $@)
	unzip -o $^ -d $(dir $@)
	touch $@

data/output/cb_2021_us_county_500k.zip:
	mkdir -p $(dir $@)
	curl -o $@ -L https://www2.census.gov/geo/tiger/GENZ2021/shp/cb_2021_us_county_500k.zip
	touch $@


public/county_topo_2022.json: data/output/cb_2022_us_county_500k/cb_2022_us_county_500k.shp
	mkdir -p $(dir $@)
	npx mapshaper $^ \
		-filter "parseInt(STATEFP) < 60" \
		-filter-fields GEOID,NAME,NAMELSAD,STATE_NAME \
		-simplify visvalingam 3% \
		-o format=topojson $@
	touch $@

data/output/cb_2022_us_county_500k/cb_2022_us_county_500k.shp: data/output/cb_2022_us_county_500k.zip
	mkdir -p $(dir $@)
	unzip -o $^ -d $(dir $@)
	touch $@

data/output/cb_2022_us_county_500k.zip:
	mkdir -p $(dir $@)
	curl -o $@ -L https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_county_500k.zip
	touch $@


public/county_topo_2023.json: data/output/cb_2023_us_county_500k/cb_2023_us_county_500k.shp
	mkdir -p $(dir $@)
	npx mapshaper $^ \
		-filter "parseInt(STATEFP) < 60" \
		-filter-fields GEOID,NAME,NAMELSAD,STATE_NAME \
		-simplify visvalingam 3% \
		-o format=topojson $@
	touch $@

data/output/cb_2023_us_county_500k/cb_2023_us_county_500k.shp: data/output/cb_2023_us_county_500k.zip
	mkdir -p $(dir $@)
	unzip -o $^ -d $(dir $@)
	touch $@

data/output/cb_2023_us_county_500k.zip:
	mkdir -p $(dir $@)
	curl -o $@ -L https://www2.census.gov/geo/tiger/GENZ2023/shp/cb_2023_us_county_500k.zip
	touch $@