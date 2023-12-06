# SunderBashpathinator

[[https://demonnic.github.io/gifs/SunderBashPathinator.gif]]

## UI for browsing bashing areas and managing a bashpath in Sunder

This is for making it easier to browse the areas known by Sunder's basher. It also helps manage a custom gogo path named "custom" which you can run using `gogo custom`

## Installation

Copy and paste the following command into Mudlet to install or update the Sunder Bashpathinator

`lua uninstallPackage("SunderBashpathinator") installPackage("https://github.com/demonnic/SunderBashpathinator/releases/latest/download/SunderBashpathinator.mpackage")`

## Usage

`sunder areas` will open the user window. You can click the `Area` or `Level` header to sort by either area name or level (or reversed if you click them again).

Clicking the number of targets or items will print just that area, and print the actual details on the targets and items.

Clicking the "Area List" button at the top left will print the full list out again.

Clicking the "Custom Path" button at the top right will display the custom gogo path and give you controls to reorder the areas in the path.

### Aliases

* `sunder areas`
  * brings up the interface

### API

* `snd.pathinator:browser()
  * If you want to open the interface programmatically
