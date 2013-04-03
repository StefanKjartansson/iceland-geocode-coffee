# Iceland-Geocode-Coffee

Simple geocoding proxy server for Icelandic addresses using non-blocking calls to fasteignaskrá. Returns results in gmaps friendly wgs84.

Proxies the query directly to fasteignaskrá's geoserver so it's generally quite quick.

## Installation

Install node and npm

    $ npm install -g coffee-script
    $ git clone git@github.com:StefanKjartansson/iceland-geocode-coffee.git
    $ npm install
    $ coffee app.coffee

Navigate your browser to **http://localhost:3000/?q=Laugavegur+1,101**
