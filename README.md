# Does SNAP cover the price of a meal in your county

## Project details

### Pertinent links
What it powers: This project is a D3 map of counties across the U.S. Counties are colored by the percent difference between the maximum SNAP benefit in that state and the average price of a modest meal. There is a sidebar with time frame selection and search capability for counties, and a badge on the map shows the price of a meal and the percent difference at the cursor's location. There is a bar at the bottom with bubbles  which, on selection, filter the map's data by RUCC.

Developer: Rachel Logan

Designer: Brittney Spinner

Writer: Rachel Kenney

Lead Researcher: Elaine Waxman

Staging link:[https://apps-staging.urban.org/features/does-snap-cover-meal-2.0/](https://apps-staging.urban.org/features/does-snap-cover-meal-2.0/)

Production link:

Figma link:

Data catalogue link:


## Data
Original source: Meal price data comes from Feeding America's Map the Meal Gap study and was processed by Urban's IBC policy center. Shapefiles come from the U.S. census bureau.

How is the data prepared: No preparation was needed for this dataset. The shapefiles can be pulled and processed by running ```make clean``` and ```make```in a terminal.

Where do the geojson and csv live: County-level topojson and csv are kept in the public folder.


## Development

### Dependencies
This project runs on Vite, Svelte, and D3.

### Svelte module descriptions
App.svelte: the entry point to the project. Holds constant data in one place, including explainer text for time frames and dropdown labels, as well as outline colors.

SnapUrbanMap.svelte: the true beginning of top-level module organization. Holds default values for internal variables.

Sidebar.svelte: holds the searchbar, time frame dropdown, and information about each time frame. 

HoverBarsComparison.svelte: dynamic bars for the average meal price for the hovered county as well as the maximum snap benefit. 

ComparisonBars.svelte: a dropdown information panel showing bars for meal price and snap benefit across all timeframes for the hovered county. 

Map.svelte: contains all logic for rendering, maneuvering, hovering and selecting the map. 

HoverInfoBadge: displays the current county's average meal price and percent difference from the snap benefit there. 

Ruccbar.svelte: an svg arrangement of bubbles for filtering county data in the map by the selected RUCC. Multi-selectable. Includes a popup explaining the code on hover.


### Running locally

You should now be ready to start developing! Start a local server with:

```bash
npm run dev
```

Open your browser and visit [http://localhost:5173](http://localhost:5173) to see your project running.

The project has a single entry point, defined by the `index.html` file. This HTML file loads a JavaScript module found in `src/main.js`. Vite will automatically bundle any JavaScript, CSS, or other assets imported by this file or any of its dependencies.


## Deploying to Urban's servers

Deployments are handled by [CircleCI](https://app.circleci.com/). Once your repository is setup in Github, you can initialize the project in CircleCI by visiting [https://app.circleci.com/projects/project-dashboard/github/UI-Research/](https://app.circleci.com/projects/project-dashboard/github/UI-Research/), finding your new project, and clicking the "Set Up Project" button.

Projects will also need to be configured with SSH keys to deploy properly. Consult [Mitchell Thorson](mailto:MThorson@urban.org) or [Jess Kelly](mailto:JKelly@urban.org) if you need help with this.

Once enabled, CircleCI will automatically build and deploy your project to Urban's staging server when you push a commit to the `dev` branch.

CircleCI will also run your tests and a build for each commit you push to any branch. You can use these checks to ensure that your changes don't break anything before you merge them into `dev` or `main`.

When you are ready to deploy to the production server, you'll need to make a small adjustment to the CircleCI config. Near the bottom of the `.circleci/config.yml` file, you'll see a `workflows` section. Under `workflows`, there should be a `install-test-build-deploy-prod` workflow that contains a `when` conditional statement:

```yaml
install-test-build-deploy-prod:
  when:
    equal: [ SET-ME-TO-MAIN-TO-DEPLOY, << pipeline.git.branch >>]
```

Update the `equal` statement to compare `main` to `pipeline.git.branch` instead of `SET-ME-TO-MAIN-TO-DEPLOY` like so:

```yaml
install-test-build-deploy-prod:
  when:
    equal: [ main, << pipeline.git.branch >>]
```

Once you've done that, CircleCI will automatically deploy each new commit to the `main` branch to the production server.

Optionally, you can modify the URL ending for your production build by specifying a new `project_slug_production` parameter near the top of the file:  

```yaml
parameters:
  project_slug_production:
    type: string
    default: my-new-production-slug-goes-here
```

The value of `project_slug_production` will be used in place of the repository name when this is set.
