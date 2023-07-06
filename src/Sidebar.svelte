<script>
  import Typeahead from "svelte-typeahead"

  // properties
  export let title;
  export let subtitle;
  export let explainerText;
  export let dataCols;
  export let dataColsLabels;
  export let value;
  export let allCounties;
  export let selectedCounty;

  let extract = (item) => item.location;

  // static assets
  import dropdownArrow from "./assets/urban-select-2x.png"; //auto-converted to base64 inline (under 4kb)
  import SearchIcon from "./assets/icon-search.svg";

  let windowWidth = 0;
  $: smallScreen = windowWidth < 800; 

  let onTypeaheadSelect = ({detail}) => {
    selectedCounty = detail.selected

    gtag('event',
      'button_click', //eventName
      {
          'firing-module-name':'snap-map', //firingModuleName
          'target-classes':"dropdown-container",
          'target-id':"",
          'target-text':"Search for your county...",
          'dropdown-select': detail.selected
      }
    )
  }

  let onTimeframeChange = () => {
    gtag('event',
      'button_click', //eventName
      {
          'firing-module-name':'snap-map', //firingModuleName
          'target-classes':"dropdown-container",
          'target-id':"",
          'target-text':"Choose a timeframe:",
          'dropdown-select': value
      }
    )
  }

</script>


<!-- titles -->
<svelte:window bind:innerWidth={windowWidth}/>
<div class="sidebar-container">
    <h2 class="chart-title">{title}</h2>
    <p class="chart-subtitle" role="heading" aria-level={5}>{subtitle}</p>
    <div class="filters">
      <div class="dropdown-container  search-container {smallScreen ? 'render-up': "render-down"}">
        <Typeahead data={allCounties} {extract} showDropdownOnFocus showAllResultsOnFocus hideLabel label="Search for your county" placeholder="Search for your county" on:select={onTypeaheadSelect}/>
        <div class="search">
          <SearchIcon alt="Search icon" viewBox = "0 0 48 48" width=20 height=20></SearchIcon>
      </div>
    </div>
        <div class="dropdown-container">
            <label aria-hidden="true" hidden for="opts">Choose a timeframe:</label>
            <select
                bind:value
                on:change={onTimeframeChange}
                name="opts"
                id="opts"
                style="--bg-img: url({dropdownArrow})"
                aria-label="Choose a metric"
            >
                <!-- create options -->
                {#each dataCols.split(",") as col, i}
                <option value={col}>{dataColsLabels.split(",")[i]}</option>
                {/each}
            </select>
        </div>
    </div>
    {#if !smallScreen}
    <p class ="chart_explainer_text"> {@html explainerText.split("///")[dataCols.split(",").indexOf(value)]}</p>
    {/if}
</div>

<style>

  .sidebar-container{
      flex-basis: 27%;
      text-align: left;
      font-family: Lato;
      width: 100%;
      min-width: 180px;
  }

  .dropdown-container{
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    margin-top: 20px;
  }

  .search-container{
    border: 1px solid lightgray;
    background-color: white;
  }

  .search {
    width: 20px;
    height: 20px;
    margin: 0px 10px;
    display: inline-block;
    color: darkgrey;
    background-size: 20px 20px;
    background-repeat: no-repeat;
    background-position: center bottom;
    vertical-align: text-bottom;
  }

  :global([data-svelte-typeahead]){
    width: 100%;
    display: block;
    z-index: 3;
  }

  :global([data-svelte-typeahead] ul){
    overflow: scroll;
    max-height: 300px;
  }

  /* maybe this messes with accessibility but in dark mode it's white text by default */
  :global([data-svelte-typeahead] input){
    color: black; 
    border: none !important;
  }

  :global([data-svelte-typeahead] mark){
    background-color: #FBDF11;
  }

  select#opts{
    width: 100%;
  }


  #opts {
    color: #ffffff;
    padding: 8px 12px;
    font-size: 16px;
    font-family: Lato, helvetica, sans-serif;
    font-style: normal;
    border: 1px solid #1696d2;
    cursor: pointer;
    width: 180px;
    background-color: #1696d2;
    background-image: var(--bg-img);
    background-size: 35px 35px;
    background-repeat: no-repeat;
    background-position: right center;
    border-radius: 0px !important;
    z-index: 2;
    position: relative;
    overflow: hidden;
    -webkit-appearance: none;
    -moz-appearance: none;
    appearance: none;
  }

  .chart_explainer_text {
    margin-top: 30px;
    font-size: 16px;
  }

  :global(a){
    color: #1696D2;
    text-decoration: none;
  }

  @media screen and (min-width: 600px) and (max-width:800px){
    .filters{
        display: flex;
    }
  }

</style>