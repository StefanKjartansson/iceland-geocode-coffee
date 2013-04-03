_ = require 'underscore'
convert = require('data2xml') valProp: '#'
express = require 'express'
isn2wgs = require "isn2wgs"
querystring = require "querystring"
request = require "request"

# globals
url = 'http://geo.skra.is/geoserver/wfs'

params =
  service: 'wfs',
  version: '1.1.0',
  request: 'GetFeature',
  typename: 'fasteignaskra:VSTADF',
  outputformat: 'json',

headers =
  'content-type' : 'application/x-www-form-urlencoded'

app = express()
app.configure ->
  app.set 'port', process.env.PORT || 3000
  app.use express.bodyParser()
  app.use express.methodOverride()


buildFilter = (street, number, postcode) ->
  props = []
  keys = ["fasteignaskra:HEITI_NF", "fasteignaskra:HUSNR", "fasteignaskra:POSTNR"]
  values = [street, number, postcode]

  for key, value of _.object(keys, values)
    if value
      props.push {PropertyName:
        '#': key
      Literal:
        '#': value}

  _.rest(convert('Filter',
    And:
      PropertyIsEqualTo: props).split('\n')).join('')


app.get "/", (req, res) ->
  l = req.query.q.split(",")
  [street, number] = (i.trim() for i in _.first(l).trim().split(' '))
  postcode = _.last(l).trim()

  request.post {
    url: url,
    body: querystring.stringify(_.extend(params, {filter: buildFilter(street, number, postcode)})),
    headers: headers}, (error, response, body) ->

    if not error
      res.send _.map JSON.parse(body).features, (feature) ->
        display_name: "#{feature.properties.HEITI_NF} #{feature.properties.HUSMERKING}, #{feature.properties.POSTNR}"
        display_name_objective_case: "#{feature.properties.HEITI_TGF} #{feature.properties.HUSMERKING}, #{feature.properties.POSTNR}"
        street: feature.properties.HEITI_NF
        number: feature.properties.HUSMERKING
        postcode: feature.properties.POSTNR
        coordinates: isn2wgs.apply(null, feature.geometry.coordinates)


app.listen app.get('port'), ->
  console.log "Express server listening on port #{app.get 'port'}"
