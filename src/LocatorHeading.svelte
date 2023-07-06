<script>
    import InfoIcon from "./assets/icon-info.svg"
    import iconClose from "./assets/icon-close.png"

    export let hoverCountyName;
    export let hoverStateName;
    export let hoverCountyRuccCode;
    export let width; //of the map section, source of truth
    export let hoverBarsModuleWidth;

    let myEl;
    let popup;

    $: if (myEl) myEl.style.setProperty("--allowed-width", width - hoverBarsModuleWidth - 7 + "px")

</script>

<div class="locator-heading" bind:this={myEl}>
    <div>
       <h6 class="state-name">
            {(hoverStateName) ?? "State"}  |  
            <span class="rucc">
                <span class="rucc__label">RUCC </span>
                <span class="rucc__id">{hoverCountyRuccCode}</span>
                <span class="bubble"
                    on:click={() => popup.classList.toggle("hidden")}
                    on:keypress={() => popup.classList.toggle("hidden")}
                    on:focus={() => popup.classList.remove("hidden")}
                    on:blur = {()=>popup.classList.add("hidden")}
                    >
                    <InfoIcon class="rucc__info" alt="Info icon" viewBox = "0 0 48 48" width=15 height=15/>
                </span>
                
            </span>
        </h6>
        <h3 class="county-name">
            {#if hoverCountyName == ""}
                National Average
            {:else}
                {hoverCountyName}
            {/if}
        </h3> 
        <div class="rucc-explained-popup hidden" bind:this={popup}>
            <div class="close-rucc" 
                style="background-image: url({iconClose});"
                on:click = {() => popup.classList.add("hidden")} 
                on:keypress = {() => popup.classList.add("hidden")}
                ></div>
            <h6>RUCC</h6>
            <a href="https://www.ers.usda.gov/data-products/rural-urban-continuum-codes.aspx" target="_blank">RUCC</a>, or the rural-urban continuum code, is a government classification
            for describing the urbanicity or rurality of a county. The codes range from 1, the most urban, to
            9, the most rural. Factors like population size, level of urbanization, and proximity to a
            metropolitan area determine a county’s RUCC. In our key findings below, we define urban counties as RUCCs 1 through 3 and rural counties as RUCCs 4 through 9. 
        </div>
    </div>
    
</div>

<style>
    .locator-heading{
        height: 150px;
        text-align: left;
        width: 100%;
        --allowed-width: 180;
        overflow: hidden;
        display: flex;
        align-items: end;
    }

    .state-name{
        text-transform: uppercase;
    }

    .county-name{
        /*height: 100px;*/
        margin-bottom: 10px;
    }

    .rucc{
        display: inline-block;
    }
    .bubble{
        cursor: pointer;
    }

    .rucc-explained-popup{
        width: var(--allowed-width);
        max-width: 300px;
        min-width: 200px;
        background-color: black;
        color: white;
        display: block;
        position: absolute;
        padding: 10px;
        margin: 20px;
        font-size: 14px;
        z-index: 5;
    }

    .rucc-explained-popup h6{
        color: white;
    }

    .rucc-explained-popup a{
        color: #1696d2;
    }

    .close-rucc{
        color: white;
        height: 20px;
        width: 20px;
        float: right;
        background-color: white;
        border-radius: 10px;
        background-size: 10px 10px;
        background-position: center;
        background-repeat: no-repeat;
    }

    .close-rucc:hover{
        cursor: pointer;
    }

    .hidden{
        display: none;
    }

    @media screen and (min-width: 600px){ /**on larger screens*/
        .locator-heading{
            max-width: var(--allowed-width); /*var(--allowed-width)px;*/
        }
    }

    @media screen and (max-width: 600px){ /**on smaller screens*/
        .locator-heading{
            height: 130px;
        }
        .rucc-explained-popup{
            top: 240px;
            width: 90%;
            max-width: fit-content;
        }
    }

</style>