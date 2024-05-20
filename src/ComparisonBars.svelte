<script>
    import * as d3 from "d3"
    import iconPlus from "./assets/icon-plus.png"
    import iconMinus from "./assets/icon-minus.png"
  import PopupTooltip from "./PopupTooltip.svelte";

    export let hoverTextColor;
    export let hoverAllPrices;
    export let dataColsLabels;
    export let nationalPrices;
    export let weHaveData;

    /*format expected: 
    [   [percentChange, snapCost, averageMealCost],
        [percentChange, snapCost, averageMealCost]...
    ]*/

    let compEl;
    let open = false;
    let hover = false;
    let barsWidth = 220;
    let barsModuleWidth = 220;
    let barsModuleHeight = 45;

    let barX = d3.scaleLinear().domain([6.5,0]).range([barsWidth,0])

    let logClickToGA = (open) => {
    gtag('event',
            'dataviz_click',
            {
                'dataviz_title':'snap-farm-bill-map', 
                'dataviz_target': compEl,
                'dataviz_detail': "comparison_bars_openclose--" + open
            }
        )
    }

    //need to confine this so we know it's actually CT
    $: CTflag = hoverAllPrices.findIndex((priceList) => {return priceList.includes("NA")}) != -1 ? true : false

</script>

<div class="comparison-dropdown" bind:this={compEl}>
    <div class="banner {hover ? 'hovering' : ''}"
        on:mouseover = {() => hover = true}
        on:mouseout = {() => hover = false}
        on:focus = {() => hover = true}
        on:blur = {() => hover = false}
        on:click = {() => {open = !open; logClickToGA(open)}} 
        on:keypress = {() => {open = !open; logClickToGA(open)}} 
    >
        <div class="title">Compare time periods</div>
        <div class="open-close" 
            style = "background-color: {open ? '#1696D2' : '#d2d2d2'};
                    background-image: url({open ? iconMinus : iconPlus});">
        </div>
    </div>
    {#if open}
    <div class="info">
        <div class="info__items">
            {#if hoverAllPrices.length > 0 && weHaveData}
                <div class="legend">
                    <div><span class="square" style="background-color: black">  </span> SNAP benefit per meal</div>
                    <div>
                        {#each hoverAllPrices as priceList}
                        {#if priceList[1] != "NA" && priceList[2] != "NA"}
                        <span class="square" style="background-color: {priceList[3]}; {priceList[3] == "#ffffff" ? "border: 1px solid black; box-sizing: border-box;" : ""}">  </span> 
                        {/if}
                        {/each}
                        Average meal cost
                    </div>
                </div>
                {#each hoverAllPrices as timeframeData, index}
                {#if timeframeData[1] != "NA" && timeframeData[2] != "NA"}
                <div class="comparison-chunk">
                    <div class="info__items__label">{dataColsLabels.split(',')[index]}</div>
                    <svg class="info__items__bars" height= {barsModuleHeight} width={barsModuleWidth}>
                        <rect class="snapComparisonBar" height=20 width={barX(Number(timeframeData[1]))} fill="black" x=0 y=0></rect>
                        <text class="priceText" x={barX(Number(timeframeData[1]))/2 - 20} y=15 fill="white">${Number(timeframeData[1]).toFixed(2)}</text>
                        <rect class="avgComparisonBar {timeframeData[3] == "#ffffff" ? ' boxed' : ""}" height=20 width={barX(Number(timeframeData[2]))} fill={timeframeData[3]} x=0 y=25></rect>
                        <text class="priceText" x={barX(Number(timeframeData[2]))/2 - 20} y=40  fill={hoverTextColor}>${Number(timeframeData[2]).toFixed(2)}</text>
                    </svg>
                </div>
                {/if}
                {/each}

                {#if CTflag}
                <div class="fit-width">
                    <span>We do not allow comparisons across years for this state.</span>
                    <div class="popup-holder">
                        <PopupTooltip placementBelow = {false} text = '<a href="https://www.federalregister.gov/documents/2022/06/06/2022-12063/change-to-county-equivalents-in-the-state-of-connecticut" target="_blank">Connecticut began using planning areas as their geographic units in 2023.</a> The nine planning areas do not map perfectly to the eight counties in the 2022 data, so we do not allow comparisons across years.'/>
                    </div>
                </div>
                {/if}
            {:else if !weHaveData}
                <div>
                    <div class="info__items__label">No data for this county.</div>
                </div>
            {:else}
                <div class="legend">
                    <div><span class="square" style="background-color: black">  </span> SNAP benefit per meal</div>
                    <div>
                        {#each nationalPrices as priceList}
                        <span class="square" style="background-color: {priceList[3]}; {priceList[3] == "#ffffff" ? "border: 1px solid black; box-sizing: border-box;" : ""}">  </span> 
                        {/each}
                        Average meal cost
                    </div>
                </div>
                {#each nationalPrices as timeframeData, index}
                <div class="comparison-chunk">
                    <div class="info__items__label">{dataColsLabels.split(',')[index]}</div>
                    <svg class="info__items__bars" height= {barsModuleHeight} width={barsModuleWidth}>
                        <rect class="snapComparisonBar" height=20 width={barX(Number(timeframeData[1]))} fill="black" x=0 y=0></rect>
                        <text class="priceText" x={barX(Number(timeframeData[1]))/2 - 20} y=15 fill="white">${Number(timeframeData[1]).toFixed(2)}</text>
                        <rect class="avgComparisonBar" height=20 width={barX(Number(timeframeData[2]))} fill={timeframeData[3]} x=0 y=25></rect>
                        <text class="priceText" x={barX(Number(timeframeData[2]))/2 - 20} y=40  fill={hoverTextColor}>${Number(timeframeData[2]).toFixed(2)}</text>
                    </svg>
                </div>
                {/each}
            {/if}
        </div>

    </div>
    {/if}

</div>

<style>
.comparison-dropdown{
    position: absolute;
    top: 10px;
    right: 7px;
    background: white;
    text-align: left;
    font-size: 14px;
    z-index: 4;
}

.banner{
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 240px;
    border: 1px solid gray;
    padding-left: 7px;
}

.banner:hover{
    cursor: pointer;
}

.hovering .open-close {
    background-color: #1696D2 !important;
}

.open-close{
    display: inline-block;
    color: white;
    border: 1px solid #d2d2d2;
    height: 30px;
    width: 30px;
    background-size: 15px 15px;
    background-position: center;
    background-repeat: no-repeat;
    font-size: 1.5em;
    border: none;
    text-align: center;
}

.title{
    display: inline-block;
    text-transform: uppercase;
    background-color: white;
}

.info{
    padding: 10px;
    border: 1px solid #e7e7e7;
}

.square{
    display: inline-block; 
    height: 10px; 
    width: 10px; 
    border: 1px solid white;
}

.comparison-chunk:not(:last-of-type){
    border-bottom: 1px solid #9c9c9c;
    padding-bottom: 10px;
    margin-bottom: 10px;
}

.comparison-chunk{
    margin-top: 10px;
}

.fit-width{
    margin-top: 10px;
    display: flex;
    align-items: center;
    gap: 20px;
    width: 220px;
    font-size: 12px;
}
.fit-width>div{
    flex: 1 0 auto;
}
.popup-holder{
    flex: 0 1 auto;
    width: 20px;
    height: 20px;
}

.boxed{
    stroke: black;
}

</style>