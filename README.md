# Does SNAP cover the price of a meal in your county

## Project details
What it powers: This project is a D3 map of counties across the U.S. Counties are colored by the percent difference between the maximum SNAP benefit in that state and the average price of a modest meal. There is a sidebar with time frame selection and search capability for counties, and a badge on the map shows the price of a meal and the percent difference at the cursor's location. There is a bar at the bottom with bubbles  which, on selection, filter the map's data by RUCC.

Developer: Rachel Marconi

Designer: Brittney Spinner

Writer: Rachel Kenney

Lead Researcher: Elaine Waxman

Staging link:[https://apps-staging.urban.org/features/does-snap-cover-meal-2.0/](https://apps-staging.urban.org/features/does-snap-cover-meal-2.0/)

Production link: [https://www.urban.org/data-tools/does-snap-cover-cost-meal-your-county-2022](https://www.urban.org/data-tools/does-snap-cover-cost-meal-your-county-2022)

Data catalogue link: [https://datacatalog.urban.org/dataset/snap-meal-gap-2022](https://datacatalog.urban.org/dataset/snap-meal-gap-2022)


## Data
Original source: Meal price data come from Feeding America's Map the Meal Gap study and were processed by Urban researchers. Shapefiles come from the U.S. census bureau.

How are the data prepared: No preparation was needed for this dataset. The shapefiles can be pulled and processed by running ```make clean``` and ```make```in a terminal.

Where do the geojson and csv live: County-level topojson and csv are kept in the ```public``` folder.


## Development

### Dependencies
This project runs on Vite, Svelte, and D3.

### Svelte module descriptions
App.svelte: the entry point to the project. Holds constant data in one place, including explainer text for time frames and dropdown labels, as well as outline colors.

SnapUrbanMap.svelte: the true beginning of top-level module organization. Holds default values for internal variables.

Sidebar.svelte: holds the searchbar, time frame dropdown, and information about each time frame. 

HoverBarsComparison.svelte: dynamic bars for the average meal price for the hovered county as well as the maximum SNAP benefit. 

ComparisonBars.svelte: a dropdown information panel showing bars for meal price and SNAP benefit across all timeframes for the hovered county. 

Map.svelte: contains all logic for rendering, maneuvering, hovering and selecting the map. 

HoverInfoBadge: displays the current county's average meal price and percent difference from the SNAP benefit there. 

Ruccbar.svelte: an svg arrangement of bubbles for filtering county data in the map by the selected RUCC. Multi-selectable. Includes a popup explaining the code on hover.


### Running locally

You should now be ready to start developing! Start a local server with:

```bash
npm run dev
```

Open your browser and visit [http://localhost:5173](http://localhost:5173) to see your project running.

The project has a single entry point, defined by the `index.html` file. This HTML file loads a JavaScript module found in `src/main.js`. Vite will automatically bundle any JavaScript, CSS, or other assets imported by this file or any of its dependencies.
