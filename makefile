.PHONY: clean default

default: public/county_topo.json

clean: 
	rm -rf data/output

public/county_topo.json: data/output/cb_2021_us_county_500k/cb_2021_us_county_500k.shp
	mkdir -p $(dir $@)
	npx mapshaper $^ \
		-filter "parseInt(STATEFP) < 60" \
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
