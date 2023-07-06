<script>
    import * as d3 from "d3"

    export let hoverSnapPrice;
    export let hoverAveragePrice;
    export let hoverColor;
    export let hoverTextColor;
    export let weHaveData;
    export let hoverBarsModuleWidth;

    let barsWidth = 215,
        barsHeight = 30,
        moduleHeight = 80
        //moduleWidth = 400;

    let barX = d3.scaleLinear().domain([6.5,0]).range([barsWidth,0])

    $: {
        let avgBarWidth = barX(Number(hoverAveragePrice)) + 164 + 7 //bar and text together with padding
        let snapBarWidth = barX(Number(hoverSnapPrice)) + 200 + 7 //bar and text together with padding
        hoverBarsModuleWidth = (avgBarWidth > snapBarWidth) ? avgBarWidth : snapBarWidth
    }

</script>


<div class="hoverComparisonBars">
    <svg class="hoverBars" height= {moduleHeight} width={hoverBarsModuleWidth}>
        <rect class="snapRect" height={barsHeight} width={barX(Number(hoverSnapPrice))} fill="black" x=0 y=0></rect>
        <text class="priceText h5" x={barX(Number(hoverSnapPrice))/2 - 25} y=22 fill="white">{weHaveData ? "$"+Number(hoverSnapPrice).toFixed(2):""}</text>
        <text class="barTitle h5" x={barX(Number(hoverSnapPrice)) + 5} y=22>SNAP benefit per meal</text>
        <br>
        <rect class="avgRect {hoverColor == "#ffffff" ? ' boxed' : ""}" height={barsHeight} width={barX(Number(hoverAveragePrice))} fill={hoverColor} x=0 y=40></rect>
        <text class="priceText h5" x={barX(Number(hoverAveragePrice))/2 - 25} y=62 fill={hoverTextColor}>{weHaveData ? "$"+Number(hoverAveragePrice).toFixed(2):""}</text>
        <text class="barTitle h5" x={barX(Number(hoverAveragePrice)) + 5} y=62>Average meal cost</text>
    </svg>
</div>


<style>
    .hoverComparisonBars{
        margin-top: 10px;
        height: 100px;
        display: flex;
        align-items:end;
    }
    .hoverBars{
        text-align: left;
        margin-bottom: 20px;
    }
    .barTitle, .priceText{
        display: inline-block;
    }
    .priceText{
        font-weight: bold;
    }

    .boxed {
        stroke:black;
    }

    @media screen and (min-width:600px){ /*on bigger screens*/
        .hoverComparisonBars{
           position: absolute;
           right: 0;
           top: 0;
           height: 150px;
        }
    }

</style>