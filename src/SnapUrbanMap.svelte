<script>
  // @ts-nocheck

  // import Svelte components
  import Sidebar from "./Sidebar.svelte";
  import Map from "./Map.svelte";
  import LocatorHeading from "./LocatorHeading.svelte";
  import HoverInfoBadge from "./HoverInfoBadge.svelte";
  import HoverBarsComparison from "./HoverBarsComparison.svelte";
  import ComparisonBars from "./ComparisonBars.svelte";
  import RuccBar from "./RuccBar.svelte"

  // export arguments for component
  export let title;
  export let subtitle;
  export let explainerText;
  export let shapefileLocation;
  export let shapefileObjectName;
  export let shapefileAccessor = "id";
  export let shapeColName;
  export let outlineColor = "white";
  export let dataLocation;
  export let dataCols;
  export let dataColsLabels;
  export let dataColsFormat = ".0f";
  export let selectedMetricName;
  export let naColor = "#5c5859";
  export let hoverOutlineColor = "#FDBE11";
  export let descText;
  export let albers_projection_flag = "true";

  $: albersProjectionFlag = albers_projection_flag === "true";

  // initialize values to be used in async functions
  let value = selectedMetricName;
  // initial width value, bound to element width
  let width = 1160;
  let mapWidth = 960;
  let height = 600;

  let hoverBarsModuleWidth = 400;

  $: if (width > 800){ //if desktop
    height = 600;
  } else if (width > 600){ //if tablet
    height = 480;
  } else { //on phone
    height = 400;
  }

  // to be passed between map and locator heading and others
  let hoverCountyName = "National Average"; //county name for locator heading
  let hoverStateName = "State"; //state name for locator heading
  let hoverCountyRuccCode = "#"; //rucc code for locator heading
  let hoverSnapPrice = ""; //snap benefit for hoverComparisonBars, hoverBadge, ComparisonBars
  let hoverAveragePrice = ""; //avg meal price for hoverComparisonBars, ComparisonBars
  let hoverPercentGap = "" //percent gap btw snap and avg price for in hoverBadge
  let hoverColor = "#1696D2"; //color of selected county on map, for...everything
  let hoverTextColor = "black"; //this is for the text, b/w dependent on lightness of hoverColor
  let hoverAllPrices = []; //this is for comparisonBars, lists data for all timeframes
  let ruccSelection = []; //from ruccBar TO map
  let allCounties; //a list compiled for the searchbar in sidebar
  let selectedCounty = ""; //from sidebar TO map for highlight

  let nationalPrices = [] //const, really-- holds nation-level data across all timeframes
  let weHaveData; //whether or not the selected county data is NA

</script>

<!-- main container -->
<!-- svelte-ignore a11y-click-events-have-key-events -->
<div class="center-container" bind:clientWidth={width}>
  <!--Sidebar holds all our selectors and explainer text-->
  <Sidebar {title} {subtitle} {explainerText} {dataCols} {dataColsLabels} {allCounties} 
    bind:value = {value} bind:selectedCounty={selectedCounty}
  ></Sidebar>

  <div class="map-container"  bind:clientWidth={mapWidth}>
    <LocatorHeading {hoverStateName} {hoverCountyName} {hoverCountyRuccCode} width={mapWidth} {hoverBarsModuleWidth}/>
    <HoverBarsComparison {hoverAveragePrice} {hoverSnapPrice} {hoverColor} {hoverTextColor} {weHaveData} bind:hoverBarsModuleWidth={hoverBarsModuleWidth}/>
    <div style="position: relative;">
      <ComparisonBars {hoverAllPrices} {hoverColor} {hoverTextColor} {dataColsLabels} {nationalPrices} {weHaveData}/>
      <Map 
        {shapefileLocation} {shapefileAccessor} {shapefileObjectName} {shapeColName} 
        {outlineColor} {dataLocation} {dataCols} {dataColsFormat} 
        {hoverOutlineColor} {descText} {albersProjectionFlag} width={mapWidth} {height} {naColor}
        bind:value = {value}
        bind:hoverCountyName = {hoverCountyName}
        bind:hoverStateName = {hoverStateName} 
        bind:hoverCountyRuccCode = {hoverCountyRuccCode} 
        bind:hoverAveragePrice = {hoverAveragePrice} 
        bind:hoverSnapPrice = {hoverSnapPrice} 
        bind:hoverPercentGap = {hoverPercentGap} 
        bind:hoverColor={hoverColor}
        bind:hoverTextColor={hoverTextColor}
        bind:hoverAllPrices = {hoverAllPrices}
        bind:allCounties = {allCounties}
        bind:nationalPrices = {nationalPrices}
        {selectedCounty}
        bind:weHaveData = {weHaveData}
        bind:ruccSelection={ruccSelection}
      ></Map>
      <HoverInfoBadge {hoverAveragePrice} {hoverPercentGap} {hoverColor} {hoverTextColor} {hoverAllPrices} {weHaveData}/>
    </div>
    
    <RuccBar width={mapWidth} bind:ruccSelection={ruccSelection}/>
    {#if width < 800}
    <p class ="chart_explainer_text"> {@html explainerText.split("///")[dataCols.split(",").indexOf(value)]}</p>
    {/if}
  </div>

</div>
<!--/div-->

<style>
  /* lato font */
  div{
    font-family: Lato;
  }

  /* container styling */
  .center-container {
    width: 100%;
    display: flex;
    gap: 15px;
  }

  .map-container{
    flex-basis: 73%;
    width: 73%;
    position: relative;
  }

  .chart_explainer_text {
    margin-top: 30px;
    font-size: 16px;
  }


  @media screen and (max-width: 800px){ /*smaller screens*/
    .center-container{
      display: block;
    }
    .map-container{
      width: 100%;
    }
  }


</style>
