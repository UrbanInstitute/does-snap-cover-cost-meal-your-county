<script>
    import * as d3 from "d3"
    import iconPlus from "./assets/icon-plus.png"
    import iconMinus from "./assets/icon-minus.png"

    export let hoverColor;
    export let hoverTextColor;
    export let hoverAllPrices;
    export let dataColsLabels;
    export let nationalPrices;
    export let weHaveData;

    /*format expected: 
    [   [percentChange, snapCost, averageMealCost],
        [percentChange, snapCost, averageMealCost]...
    ]*/

    let open = false;
    let hover = false;
    let barsWidth = 220;
    let barsModuleWidth = 220;
    let barsModuleHeight = 45;

    let yellowU = "#FDBF11";

    let barX = d3.scaleLinear().domain([6.5,0]).range([barsWidth,0])

</script>

<div class="comparison-dropdown">
    <div class="banner {hover ? 'hovering' : ''}"
        on:mouseover = {() => hover = true}
        on:mouseout = {() => hover = false}
        on:focus = {() => hover = true}
        on:blur = {() => hover = false}
        on:click = {() => open = !open} 
        on:keypress = {() => open = !open} 
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
                    <div><span style="display: inline-block; height: 10px; width: 10px; background-color: black">  </span> SNAP benefit per meal</div>
                    <div>
                        <span style="display: inline-block; height: 10px; width: 10px; background-color: {hoverAllPrices[0][3]}; {hoverAllPrices[0][3] == "#ffffff" ? "border: 1px solid black; box-sizing: border-box;" : ""}">  </span> 
                        <span style="display: inline-block; height: 10px; width: 10px; background-color: {hoverAllPrices[1][3]}; {hoverAllPrices[1][3] == "#ffffff" ? "border: 1px solid black; box-sizing: border-box;" : ""}">  </span> 
                        Average meal cost
                    </div>
                </div>
                {#each hoverAllPrices as timeframeData, index}
                <div>
                    <div class="info__items__label">{dataColsLabels.split(',')[index]}</div>
                    <svg class="info__items__bars" height= {barsModuleHeight} width={barsModuleWidth}>
                        <rect class="snapComparisonBar" height=20 width={barX(Number(timeframeData[1]))} fill="black" x=0 y=0></rect>
                        <text class="priceText" x={barX(Number(timeframeData[1]))/2 - 20} y=15 fill="white">${Number(timeframeData[1]).toFixed(2)}</text>
                        <rect class="avgComparisonBar {timeframeData[3] == "#ffffff" ? ' boxed' : ""}" height=20 width={barX(Number(timeframeData[2]))} fill={timeframeData[3]} x=0 y=25></rect>
                        <text class="priceText" x={barX(Number(timeframeData[2]))/2 - 20} y=40  fill={hoverTextColor}>${Number(timeframeData[2]).toFixed(2)}</text>
                    </svg>
                </div>
                {/each}
            {:else if !weHaveData}
                <div>
                    <div class="info__items__label">No data for this county.</div>
                </div>
            {:else}
                <div class="legend">
                    <div><span style="display: inline-block; height: 10px; width: 10px; background-color: black">  </span> SNAP benefit per meal</div>
                    <div>
                        <span style="display: inline-block; height: 10px; width: 10px; background-color: {nationalPrices[0][3]}; {nationalPrices[0][3] == "#ffffff" ? "border: 1px solid black; box-sizing: border-box;" : ""}">  </span>
                        <span style="display: inline-block; height: 10px; width: 10px; background-color: {nationalPrices[1][3]}; {nationalPrices[1][3] == "#ffffff" ? "border: 1px solid black; box-sizing: border-box;" : ""}">  </span>
                        Average meal cost
                    </div>
                </div>
                {#each nationalPrices as timeframeData, index}
                <div>
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

.info__items__label {
    margin-top: 15px;
}

.title{
    display: inline-block;
    text-transform: uppercase;
    background-color: white;
}

.info{
    padding: 10px;
}

.boxed{
    stroke: black;
}

</style>