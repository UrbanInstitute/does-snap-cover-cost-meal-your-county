<script>
    export let ruccSelection;
    export let width;

    import arrow from "./assets/icon-chevron.png"
    import iconClose from "./assets/icon-close.png"

    $: trueWidth = (width <= 570 ? width  : width - 260) //on wider screens, leave space for more/less urban

    let RUCC_TEXT = [
        "",
        "Counties in metropolitan areas of 1 million people or more",
        "Counties in metropolitan areas of 250,000 to 1 million people",
        "Counties in metropolitan areas of fewer than 250,000 people",
        "Nonmetropolitan counties: urban population of 20,000 or more, adjacent to a metropolitan area",
        "Nonmetropolitan counties: urban population of 20,000 or more, not adjacent to a metropolitan area",
        "Nonmetropolitan counties: urban population of 2,500 to 19,999, adjacent to a metropolitan area",
        "Nonmetropolitan counties: urban population of 2,500 to 19,999, not adjacent to a metropolitan area",
        "Nonmetropolitan counties: completely rural, or urban population of less than 2,500, adjacent to a metropolitan area",
        "Nonmetropolitan counties: completely rural, or urban population of less than 2,500, not adjacent to a metropolitan area"
    ]

    let svgEl; //for bubbles responsiveness
    let ruccEl; //for analytics
    let popup;
    let clickedIndex = []; //something ridiculous out of bounds
    let popupIndex = 0; //controls which text is in popup, either clicked or hovered

    $: if (popup) popup.style.setProperty("--popup-left", 24 + "px")
    $: resetRuccBar(ruccSelection); //if ruccSelection is reset, reset ruccBar

    let resetRuccBar = (rucc) => {
        //if it's changed externally to empty
        if(rucc.length == 0  && clickedIndex.length != 0 && svgEl){ 
            for (let i of clickedIndex){ //reset styles for every active index
                svgEl.childNodes[+i+1].childNodes[0].style.fill = "lightgray";
                svgEl.childNodes[+i+1].childNodes[1].style.fill="#9d9d9d";
            }
            
            popup.classList.add("hidden")
            clickedIndex = [];
            //ruccSelection is reset elsewhere as a trigger for this function
        }
    }

    let onHover = (i) => {
        // show popup with relevant text at that bubble's location
        //also change backgroundcolor to blue and color to white
        svgEl.childNodes[i+1].childNodes[0].style.fill = "white"; //circle
        svgEl.childNodes[i+1].childNodes[1].style.fill = "black"; //text

        //also bring the popup over and show it
        if (i != 0){
            popupIndex = i; //show popup at this button even if there's a click
            popup.style.setProperty("--popup-left",25+(i*trueWidth)/10 +"px")
            popup.classList.remove("hidden") 
        }
       
    }

    let onNoHover = (i) => {
        if (clickedIndex.includes(i)){
            //turn back to clicked colors
            svgEl.childNodes[i+1].childNodes[0].style.fill = "#1696D2";
            svgEl.childNodes[i+1].childNodes[1].style.fill="white";
        } else {
            //put background color and color back to what it was
            svgEl.childNodes[i+1].childNodes[0].style.fill = "lightgray"; //circle
            svgEl.childNodes[i+1].childNodes[1].style.fill="#9d9d9d"; //text
        }
        //hide popup in all cases
        popup.classList.add("hidden")
        
    }

    let onClick = (i) => {
        //do not reset previously clicked button

        if (clickedIndex.includes(i)){
            //already active--remove this index
            clickedIndex.splice(clickedIndex.indexOf(i), 1); //remove one item at the index where i is found

            //reset styles of deselected button
            svgEl.childNodes[i+1].childNodes[0].style.fill = "lightgray";
            svgEl.childNodes[i+1].childNodes[1].style.fill="#9d9d9d";

            if (clickedIndex.length > 0){
                //still active buttons left
                popupIndex = clickedIndex[clickedIndex.length -1]
                popup.classList.add("hidden")
            } else{
                //no active buttons left
                popup.classList.add("hidden")
            }
        } else if (i != 0){
            //not already active and not "ALL"--add this index
            clickedIndex.push(i);
            popupIndex = i;

            //add styles to newly selected button
            svgEl.childNodes[i+1].childNodes[0].style.fill = "#1696D2";
            svgEl.childNodes[i+1].childNodes[1].style.fill="white";

            popup.style.setProperty("--popup-left",25+(i*trueWidth)/10 +"px")
            popup.classList.remove("hidden")
            logClickToGA(i) //ANALYTICS
        } else {
            //new click is "ALL"
            for (let j of clickedIndex){ //reset styles for every active index
                svgEl.childNodes[j+1].childNodes[0].style.fill = "lightgray";
                svgEl.childNodes[j+1].childNodes[1].style.fill="#9d9d9d";
            }
            clickedIndex = [] //remove all active buttons
            popup.classList.add("hidden")
        }
        ruccSelection = clickedIndex
        
        
    }
    
    let logClickToGA = (ruccVal) => {
        gtag('event',
            'dataviz_click',
            {
                'dataviz_title':'snap-farm-bill-map', 
                'dataviz_target': ruccEl,
                'dataviz_detail': "ruccbar_click--" + ruccVal
            }
        )
    }


</script>

<div style="position: relative;">
    <div class="rucc-flex"  style="--bg-img: url({arrow});" bind:this={ruccEl}>
        <h6 class="more flexitem">More urban</h6>
        <div class="right arrow"></div>
        <div class="holdsbar">
            <svg bind:this={svgEl} width={trueWidth} height=45>
                <line stroke="#d2d2d2" stroke-width="3" x1=0 y1=24 x2={trueWidth} y2=24></line>
                {#each RUCC_TEXT as ruccText, i}
                <g class="bubble"
                    on:mouseover={() => onHover(i)} 
                    on:focus={() => onHover(i)} 
                    on:mouseout={() => onNoHover(i)} 
                    on:blur={() => onNoHover(i)} 
                    on:click={()=>onClick(i)} 
                    on:keypress={()=>onClick(i)}>
                    <circle cx={21+(i*trueWidth)/10} cy=24 r=15 fill="#d2d2d2" stroke="#d2d2d2"></circle>
                    <text x={(i == 0 ? 8 : 16)+(i*trueWidth)/10} y = 29 fill="#9d9d9d">{i == 0 ? "ALL" : i}</text>
                </g>
                {/each}
            </svg>
            
        </div>
        <div class= "left arrow"></div>
        <h6 class="less flexitem">More rural</h6>
    </div>
    <div class="popup hidden" bind:this={popup}> 
        <div class="close-rucc" 
            style="background-image: url({iconClose});"
            on:click = {() => popup.classList.add("hidden")} 
            on:keypress = {() => popup.classList.add("hidden")}
            ></div>
        <h5>RUCC <span class="blue">{popupIndex}</span></h5>
        <h6>{RUCC_TEXT[popupIndex]}</h6>
    </div>
</div>

<style>
    g,g:focus,g:hover{
        outline:none;
    }

    .rucc-flex{
        display: flex;
        align-items: center;
        gap: 5px;
        --popup-left: 24px;
        position: relative;
    }
    .flexitem{
        flex-shrink: 0;
    }
    .holdsbar{
        overflow-x: scroll;
        overflow-y: hidden;
        cursor: default;

    }
    .bubble{
        cursor: pointer;
    }
    .blue {
        color: #1696D2;
        font-size: 15px;
    }

    .popup{
        max-width: 260px;
        position: relative;
        display: block;
        left: var(--popup-left);
        top: 0px;
        background-color: black;
        color: white;
        padding: 10px;
    }
    .popup > h5{
        color: white;
        font-size: 15px;
    }
    .popup > h6 {
        color: white;
        font-size: 14px;
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

    .arrow{
        display: inline-block;
        height: 20px;
        width: 20px;
        color: black;
        background-color: white;
        background-size: 15px 15px;
        background-position: center;
        background-repeat: no-repeat;
        background-image: var(--bg-img);
    }

    .left{
        rotate: 0deg;
    }

    .right{
        rotate: 180deg;
    }

    @media screen and (max-width: 570px){
        .popup{
            max-width: 95%;
            width: 100%;
            position: relative;
            left: 0px;
            top: 0px;
            margin-bottom: 10px;
        }
        .rucc-flex{
            flex-wrap: wrap;
        }
        .flexitem{
            flex-basis: 49%;
        }
        .holdsbar {
            order: 98;
        }
        .left, .right {
            display: none;
        }
        .less {
            text-align: right;
        }
    }

</style>