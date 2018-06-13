# jekyll-figma-plugin
Basic Jekyll plugin to parse Figma document URL's and retrieve a rendered image using the Figma API.

## Installation

Drop the `Figma.rb` file into your `_plugins` folder, and update the `TOKEN` variable with a Personal Access Token generated from your Figma settings page.

## Usage

In your posts, add `{% figma <figma_url> %}` where `figma_url` is a link to a frame in a Figma document, generated from the *Share* button in the app.

## Notes and caveats

* There's no error checking whatsoever.
* Figma recently updated the API to note that [images expire after 30 days](https://www.figma.com/developers/docs#images-endpoint).

