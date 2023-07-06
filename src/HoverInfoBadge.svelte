<script>
    export let hoverAveragePrice;
    export let hoverPercentGap;
    export let hoverColor;
    export let hoverTextColor;
    export let hoverAllPrices;
    export let weHaveData;

    $: avgPrice = Number(hoverAveragePrice).toFixed(2)
    $: moreLessEqual = checkValToZero(Number(hoverPercentGap)) 

    let checkValToZero = (val) => {
        if (val == 0) return "about equal to";
        if (val > 0) return "more than";
        if (val < 0) return "less than";
    }


    $: absPercentGap = Math.abs(Number(hoverPercentGap) * 100).toFixed(0)

</script>

{#if weHaveData && hoverAllPrices.length > 0 && moreLessEqual != "about equal to"}
<h5 class="hover-info-badge">
    A modestly priced meal cost ${avgPrice}, <span class="key-highlight" style="background-color: {hoverColor}; color: {hoverTextColor};">{absPercentGap} percent</span> {moreLessEqual} the SNAP benefit.
</h5>
{:else if weHaveData && hoverAllPrices.length > 0 && moreLessEqual == "about equal to"}
<h5 class="hover-info-badge">
    A modestly priced meal cost ${avgPrice}, <span class="key-highlight" style="background-color: {hoverColor}; color: {hoverTextColor};">{moreLessEqual}</span> the SNAP benefit.
</h5>
{:else if !weHaveData}
<h5 class="hover-info-badge">
    There is no average meal price data for this county.
</h5>
{:else}
<h5 class="hover-info-badge">
    Nationwide, a modestly priced meal cost ${avgPrice}, <span class="key-highlight" style="background-color: {hoverColor}; color: {hoverTextColor};">{absPercentGap} percent</span> {moreLessEqual} the SNAP benefit.
</h5>
{/if}


<style>
    .hover-info-badge{
        width: 280px;
        height: 85px;
        padding: 10px;
        background-color: white;
        text-align: left;
        border: 1px solid lightgrey;

        position: absolute;
        bottom: 20px;
        left: 20px;
    }

    .key-highlight{
        color: white;
        background-color: #1696D2;
        padding: 0 2px;
    }

    @media screen and (max-width: 600px){
        .hover-info-badge{
            width: 250px;
        }
    }

    @media screen and (max-width: 500px){
        .hover-info-badge{
            width: 95%;
            height: auto;
            position: relative;
            top: 0px;
            left: 0px;
            background-color: #f5f5f5;
            margin: 20px 0px;
            border: none;
        }
    }

</style>