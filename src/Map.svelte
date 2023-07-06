<script>
  // import npm modules
  import * as topojson from "topojson-client";
  import { onMount } from "svelte";
  import * as d3 from "d3";
  import * as _ from "lodash";

  // import static assets
  import iconPlus from "./assets/icon-plus.png";
  import iconMinus from "./assets/icon-minus.png";
  import ResetIcon2 from "./assets/reset-button-10.svg";

  //export controlling data for/from other modules
  export let shapefileLocation;
  export let shapefileObjectName;
  export let shapefileAccessor;
  export let shapeColName;
  export let outlineColor;
  export let dataLocation;
  export let dataCols;
  export let dataColsFormat;
  export let value;
  export let naColor;
  export let hoverOutlineColor;
  export let descText;
  export let albersProjectionFlag;
  export let width;
  export let height;
  export let hoverCountyName = "";
  export let hoverStateName = "";
  export let hoverCountyRuccCode;
  export let hoverSnapPrice;
  export let hoverAveragePrice;
  export let hoverPercentGap;
  export let hoverColor = "#46ABDB";
  export let hoverTextColor = "black";
  export let hoverAllPrices = [];
  export let ruccSelection;
  export let allCounties = {};
  export let selectedCounty;
  export let nationalPrices;
  export let weHaveData = true;

  // holds geographic data once it is loaded
  let shapefile;
  // holds raw data from csv
  let rawData = [];
  let naFlag = false;
  // holds reference to any highlighted feature on the map
  let highlightedFeature = null;
  // boolean that holds state of click focus
  let clickFocus = false;
  //reset this reactively based on mousein

  // reactively convert raw topojson to geojson
  $: shapefileInit = shapefile
    ? topojson.feature(shapefile, shapefile.objects[shapefileObjectName])
    : null;

  // reactively grab the features array from the geojson
  $: shapefileFeatures = shapefileInit ? shapefileInit.features : [];

  // reactively split the raw cols prop into an array of vars
  $: vars = dataCols.split(",");

  // reactively convert any provided vars to numeric values
  $: data = rawData.map((d) => {
    let obj = {};
    vars.forEach((v) => {
      obj[v] = +d[v];
    });
    return { ...d, ...obj };
  });
  
  //makes a list of counties to send to sidebar for search
  $: allCounties = data.map((item)=> {
    return {location:item['countystate']};
  })

  // reactively create projection to fit the shapefile to the area based on the width variable
  $: projectionFun = albersProjectionFlag
    ? d3.geoAlbersUsa()
    : d3.geoMercator();
  $: projection = projectionFun.fitSize([width, height], shapefileInit);

  // reactively create a d3 path function based on the projection
  $: path = d3.geoPath().projection(projection);

  //make state shapes
  // let's get an organic list of fips
  let fips = {};
  $: shapefileFeatures.forEach(function(county) {
      fips[county.properties.GEOID - county.properties.GEOID % 1000] = 1;
  });

  let states = [];
  // and merge by fips
  $: Object.keys(fips).forEach(function(fip) {
      let state = topojson.merge(
          shapefile,
          shapefile.objects[shapefileObjectName].geometries.filter(function(d) {
              return d.properties.GEOID - d.properties.GEOID % 1000 == +fip;
          })
      );
      states.push(state);
  });


  // set up zoom functionality ------------
  let svgEl;
  $: svgSelection = d3.select(svgEl)

  $: svgSelection.call(zoom).on("wheel.zoom", null);

  let zoomTransform = {x: 0, y: 0, k: 1,}; //default zoom on load

  function zoomed(e) {
    const { transform } = e;
    zoomTransform = transform;
  }

  // leaning on this d3 zoom magic
  $: zoom = d3.zoom()
    .scaleExtent([.75, 10])
    .translateExtent([[0,0],[width, height]])
    .on("zoom", zoomed);

  //some handlers to attach to our zoom buttons
  const zoomInClick = () => {
    svgSelection.transition().call(zoom.scaleBy, 2);
  };

  const zoomOutClick = () => {
    svgSelection.transition().call(zoom.scaleBy, .5);
  };

  $: flyToDropdownCounty(selectedCounty) //when this changes in Sidebar, should run this

  let flyToDropdownCounty = (countyName) => {
    let scale = 5;
    let selectedFeature = lookupFeatureFromLocation(countyName)
    if (selectedFeature){
      updateExternalData(selectedFeature) //updates all external data
      clickFocus = true;
      svgSelection
        .transition()
        .duration(500)
        .call(zoom.scaleTo, scale) //maybe whiplash
        .transition()
        .ease(d3.easeCircle)
        .duration(1000)
        .call(zoom.translateTo, path.centroid(selectedFeature.geometry)[0], path.centroid(selectedFeature.geometry)[1])
    }
  }

  // reactively set data values in a map for easy lookup
  //this is mostly left in from template; could rework 
  $: dataMap = dataMapFun(data, value, shapeColName);

  //COLORS
  let colorHexes =["#e88e2d","#fdbf11","#fccb41", "#fdd870", "#fce39e", "#fff2cf","#ffffff","#cfe8f3","#a2d4ec","#73bfe2","#46abdb","#1696d2","#12719e", "#0f6187","#0d5070", "#0a4059"]
  let breaks = [-.5,-.4,-.3,-.2,-.1,-.001,.001,.1,.2,.3,.4,.5,.6,.7,.8, 1]

  $: colorScale = setColorScale(value);
  
  // doesn't actually change on val change
  let setColorScale = (val) => {
      let scale = d3.scaleThreshold()
              .domain(breaks)
              .range(colorHexes)
              .unknown(naColor)
      return scale;
  }
    

  // function that takes data and a metric key and returns a Map for easy lookup
  let dataMapFun = (inputData, metric, col) => {
    let dm = new Map();
    inputData.forEach((d, i) => {
      dm.set(Number(d[col]), d[metric]);
    });
    return dm;
  };

  // check NA of currently selected data
  // if two data variables are valid length, then iterate through and check if there's any falsy values to indicate an NA
  $: naFlag =
    dataMap.size > 0 && shapefileFeatures.length > 0
      ? shapefileFeatures.reduce((a, c) => a || !lookupData(c), false)
      : false;


  // this is for what to fill our text with on load/hover not on map
  $: nationalPrices = 
  [
    ["0.29", "2.43", "3.14", colorScale(.29)], //some hard-coded data for usa
    ["0.15", "2.74", "3.14", colorScale(.15)] 
  ] 

  $: if (value != "") clearHighlight() //if we deselect any timeframes, unselect county

  // create number formatting function based on currently select dropdown value
  let formatTooltip = (which, percent, county, state) => {

    let format = d3.format(
      dataColsFormat.split("|")[dataCols.split(",").indexOf(which)] ?? ",.0f"
    );

    if (percent > 0){
      return `The cost of a modestly priced meal is ${format(percent)} higher than the maximum SNAP benefit in ${county}, ${state}.`
    }
    else if (percent == 0){
      return `The cost of a modestly priced meal is about equal to the maximum SNAP benefit in ${county}, ${state}.`
    }
    else { //if (val < 0)
      return `The cost of a modestly priced meal is ${format(Math.abs(percent))} lower than the maximum SNAP benefit in ${county}, ${state}.`
    }
    
  };

  // lookup data from dataMap based on feature
  const lookupData = (feature) => {
    let lookupKey;
    let returnVal;
    try{
      lookupKey = Number(_.get(feature, shapefileAccessor));
      returnVal = dataMap.get(lookupKey);
      if (returnVal == undefined){
        returnVal = NaN;
      }
    }catch (e){returnVal = NaN;}
    return returnVal;
  };

  // lookup data from inputData based on feature
  const lookupProps = (feature, val) => {
    const lookupKey = Number(_.get(feature, shapefileAccessor));
    let returnItem;
    try{
      returnItem = _.find(data, function(o) { return o[shapeColName] == lookupKey; })[val]
    }
    catch(e){returnItem = NaN;}
    return returnItem;
  };  

  //get feature if you have the written location
  const lookupFeatureFromLocation = (value) => {
    return _.find(shapefileFeatures, function(feat) {return (feat.properties.NAMELSAD + ", "+ feat.properties.STATE_NAME) == value.trim()})
  }

  $: setDataOnNewValue(value)

  let setDataOnNewValue = (val) => {
    if (highlightedFeature)
      updateExternalData(highlightedFeature)
  }

  //sets all the vars that react in other components
  const updateExternalData = (feature) => {
      highlightedFeature = feature;

      if (!isNaN(lookupData(feature))){
        hoverCountyName = feature.properties.NAMELSAD
        hoverStateName = feature.properties.STATE_NAME;
        hoverCountyRuccCode = lookupProps(feature, "rucc");
        let snapVar = "maxsnap_" + (value == "percent_snap_gap_jansept2022" ? "jansept2022" : "octdec2022"); //convert to a switchCase by possible value for future
        hoverSnapPrice = lookupProps(feature,snapVar)
        hoverAveragePrice = lookupProps(feature,"costpermeal_2022")
        hoverPercentGap = lookupProps(feature, value)
        hoverColor = colorScale(lookupData(feature))
        hoverTextColor = lookupData(feature) > .25 ? "white" : "black"
        hoverAllPrices = [
          [lookupProps(feature, "percent_snap_gap_jansept2022"), lookupProps(feature, "maxsnap_jansept2022"), lookupProps(feature, "costpermeal_2022"), colorScale(lookupProps(feature, "percent_snap_gap_jansept2022" ))],
          [lookupProps(feature, "percent_snap_gap_octdec2022"), lookupProps(feature, "maxsnap_octdec2022"), lookupProps(feature, "costpermeal_2022"), colorScale(lookupProps(feature, "percent_snap_gap_octdec2022"))]
        ]
        weHaveData = true;
      } else { //no data for this county-- show national average -- could probably simply these two cases
        hoverCountyName = feature.properties.NAMELSAD
        hoverCountyRuccCode = "#";
        hoverStateName = feature.properties.STATE_NAME;
        hoverAllPrices = []

        let dataColIndex = (value == dataCols.split(',')[0]) ? 0 : 1
        hoverPercentGap = nationalPrices[dataColIndex][0]
        hoverSnapPrice = nationalPrices[dataColIndex][1]
        hoverAveragePrice = nationalPrices[dataColIndex][2]
        hoverColor = colorScale(Number(nationalPrices[dataColIndex][0]))
        hoverTextColor = "black"
        weHaveData = false;

      }
  }

  // show tooltip for a given feature
  // there actually isn't a tooltip, so I should rename this fx
  const showTooltip = (feature) => {
    // if there is a current click focus, set highlightedFeature to new feature
    if (
      clickFocus &&
      _.get(feature, shapefileAccessor) !==
        _.get(highlightedFeature, shapefileAccessor)
    ) {
      updateExternalData(feature);
    }

    console.log(data[0])

    // alternate click focus
    clickFocus = !clickFocus;

    //if there's an active county...
    if (clickFocus) {
      //send to analytics
      let init = lookupData(feature);
      let locale = "undefined shape"
      if (!isNaN(init)) {
        locale = feature.properties.NAMELSAD + ", " + feature.properties.STATE_NAME
      } 
      logClickToGA(locale) //send analytics ping for selection
    } 
  };

  const showHighlight = (feature) => {
    // only update the highlighted feature if there is not a click focus
    if (!clickFocus) {
      updateExternalData(feature);
    }
  };

  const clearHighlight = () => {
    // resets all external handles to national defaults
    if (!clickFocus) {
      highlightedFeature = null;
      hoverCountyName = "";  //will set to "NATIONAL AVERAGE" at the end of the line
      hoverCountyRuccCode = "#";
      hoverStateName = "State"
      hoverAllPrices = [] //I'm using this==empty as a isNational flag

      let dataColIndex = (value == dataCols.split(',')[0]) ? 0 : 1 //which timeframe is active? use the index to set national vals
      hoverPercentGap = nationalPrices[dataColIndex][0]
      hoverSnapPrice = nationalPrices[dataColIndex][1]
      hoverAveragePrice = nationalPrices[dataColIndex][2]
      hoverColor = colorScale(Number(nationalPrices[dataColIndex][0]))
      if (hoverColor == "#FFFFFF") hoverColor = "#46ABDB" //if not on the scale, just use a middle color
      hoverTextColor = "black"
    }
    weHaveData = true; //resets this
  };

  //recenters and unzooms map; resets to national data
  const resetMap = () => {
    clickFocus = false;
    clearHighlight();
    ruccSelection = []; 
    svgSelection
		  .transition()
		  .call(zoom.scaleTo, 1);
  }

  let logClickToGA = (locationName) => {
    gtag('event',
            'button_click', //eventName
            {
                'firing-module-name':'snap-map', //firingModuleName
                'target-classes':"chart-container",
                'target-id':"",
                'target-text':"I'm the map",
                'click-target': locationName
            }
        )
  }

  // lifecycle method onMount: run when component is added to the DOM
  onMount(async () => {
    // load shapefile data
    shapefile = await fetch(shapefileLocation).then((d) => d.json());
    // load csv data
    rawData = await d3.csv(dataLocation);


  });

</script>




<!-- chart container -->
<div id="map" class="chart-container">
    <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
    <svg viewBox="0 0 {width} {height}" bind:this={svgEl} role="img" tabindex="0">
      <!-- <desc id="desc" /> -->
      <title>{descText.split("///")[dataCols.split(",").indexOf(value)]}</title>
      <!-- if there is data to load, show the <g>  -->
      {#if dataMap.size > 0}
        <g transform="translate({zoomTransform.x}, {zoomTransform.y}) scale({zoomTransform.k})">
          <!-- each feature of the shapefile... -->
          {#each shapefileFeatures as feature, i}
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <!-- if the feature is not highlighted, add <path> here-->
            <!-- if ALL rucc is selected or this feature matches selected RUCC, make it hoverable. otherwise, change the opacity instead -->
            {#if _.get(feature, shapefileAccessor) !== _.get(highlightedFeature, shapefileAccessor)}
              {#if ruccSelection.length == 0 || ruccSelection.includes(+lookupProps(feature,"rucc"))}
              <path
                tabindex="-1"
                role="button"
                d={path(feature)}
                stroke={outlineColor}
                stroke-width={1 / (2* zoomTransform.k)}
                fill={colorScale(lookupData(feature))}
                on:mouseover={() => showHighlight(feature)}
                on:mouseout={() => clearHighlight()}
                on:focus={() => showHighlight(feature)}
                on:blur={() => clearHighlight()}
                on:click={() => showTooltip(feature)}
              >
                <title>{formatTooltip(value, lookupData(feature), hoverCountyName, hoverStateName)}</title>
              </path>
              {:else}
              <path
                tabindex="-1"
                role="button"
                d={path(feature)}
                stroke={outlineColor}
                stroke-width={1 / (2* zoomTransform.k)}
                fill={(ruccSelection.length == 0 || ruccSelection.includes(+lookupProps(feature,"rucc"))) ? colorScale(lookupData(feature)) : "#9d9d9d"}
                opacity= {(ruccSelection.length == 0 || ruccSelection.includes(+lookupProps(feature,"rucc"))) ? 1 : .25}
              >
                <title>{formatTooltip(value, lookupData(feature), hoverCountyName, hoverStateName)}</title>
              </path>
              {/if}
            {/if}
          {/each}
          <!--add state shapes-->
          {#each states as state}
          <path
            tabindex="-1"
            role="button"
            d={path(state)}
            stroke={ruccSelection.length == 0 ? "white" : "black"}
            fill=none
            stroke-width={1 / (zoomTransform.k)}
            >
          </path>
          {/each}
          <!-- if the feature IS highlighted, add <path> on top instead -->
          {#if highlightedFeature}
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <path
              tabindex="-1"
              d={path(highlightedFeature)}
              stroke={hoverOutlineColor}
              stroke-width={3 / zoomTransform.k}
              fill={colorScale(lookupData(highlightedFeature))}
              on:mouseout={() => clearHighlight()}
              on:blur={() => clearHighlight()}
              on:click={() => showTooltip(highlightedFeature)}
            >
              <title>{formatTooltip(value, lookupData(highlightedFeature), hoverCountyName, hoverStateName)}</title>
            </path>
          {/if}
        </g>
      {:else}
      <div>there's no data to parse.</div>
      <div>{shapefileInit}</div>
      {/if}
      
    </svg>
    <!--zoom controls-->
    <div class="zoom-controls">
      <button class="zoom-in-button map-button" style = "background-image: url({iconPlus});" on:click={zoomInClick}></button><br>
      <button class="zoom-out-button map-button" style = "background-image: url({iconMinus});" on:click={zoomOutClick}></button><br>
      <button class="reset-map-button map-button" on:click={resetMap}><ResetIcon2 alt="Reset icon" viewBox = "0 0 322 322" width=20 height=20></ResetIcon2></button>
    </div>
  </div>

<style>

  .zoom-controls{
    position: relative;
    bottom: 110px;
    right: 2px;
    text-align: right;
    height: 0px;
  }

  .map-button{
    display: inline-block;
    background-color: lightgrey;
    height: 30px;
    width: 30px;
    background-size: 15px 15px;
    background-position: center;
    background-repeat: no-repeat;
    font-size: 1.5em;
    border: none;
    margin: 2px;
    padding: 0px !important;
  }

  .map-button:hover{
    background-color: #1696D2;
    color: white;
    cursor: pointer;
  }

  .chart-container{
    border: 1px lightgrey solid;
    background-color: white;
  }

</style>