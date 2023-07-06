<script>
  import packageJson from "../package.json";
  import SnapUrbanMap from "./SnapUrbanMap.svelte";
  import "./app.css"
  console.log("👋 Welcome to DataViz@URBAN!");
</script>

<main>
  
  <div>
    <SnapUrbanMap
      title="The Gap between SNAP Benefits and Meal Costs"
      subtitle="Choose your own parameters or hover over the map to dynamically see meal costs."
      explainerText="<p>From January to September 2022, the maximum SNAP benefit participants received reflected the US Department of Agriculture’s <a target='_blank' href='https://www.fns.usda.gov/snap/fy-2022-cost-living-adjustments'>fiscal year 2022 cost-of-living adjustment</a>. It does not reflect the <a target='_blank' href='https://www.fns.usda.gov/snap/covid-19-emergency-allotments-guidance'>emergency allotments</a>
      participants received in 2022.</p> ///<p>From October to December 2022, the maximum SNAP benefit participants received reflected the US Department of Agriculture’s <a target='_blank' href='https://www.fns.usda.gov/snap/fy-2023-cola'>fiscal year 2023 cost-of-living adjustment</a>. It does not reflect the <a target='_blank' href='https://www.fns.usda.gov/snap/covid-19-emergency-allotments-guidance'>emergency allotments</a>
      participants received in 2022.</p>"
      shapefileLocation="./county_topo.json"
      shapefileObjectName="cb_2021_us_county_500k"
      shapefileAccessor="properties.GEOID"
      shapeColName="fips"
      dataCols="percent_snap_gap_jansept2022,percent_snap_gap_octdec2022"
      dataColsLabels="January—September 2022,October—December 2022"
      outlineColor="white"
      hoverOutlineColor="black"
      dataColsFormat=".0%|.0%"
      dataLocation="./snap-2-data-041423.csv"
      selectedMetricName="percent_snap_gap_octdec2022"
      descText="A map of US counties shows the maximum SNAP benefit did not cover the cost of a meal in 99 percent of counties from January to September 2022, before the fiscal year 2023 cost-of-living adjustment took effect. Counties with the largest gap between SNAP benefits and meal costs were more concentrated in the Northwest, including in Idaho and Wyoming, and along both coasts. Most of the 27 counties with adequate benefits were in Texas.///A map of US counties that shows the maximum SNAP benefit did not cover the cost of a meal in 78 percent of counties in the last quarter of 2022, when the fiscal year 2023 cost-of-living adjustment was in effect. Counties with the largest gap between SNAP benefits and meal costs were more concentrated in the Northwest, including in Idaho and Wyoming. Counties with adequate SNAP benefits were more concentrated in the South and East, including in Kentucky, Texas, and West Virginia."
    ></SnapUrbanMap>
  </div>
</main>

<style>
  main {
    /* height: 100vh; */
    width: 100%;
  }
</style>
