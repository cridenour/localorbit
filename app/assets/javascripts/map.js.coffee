class Map

  constructor: (container_id, center, map_id) ->
    @signs = []
    @map = new L.Map container_id,
      center: center
      zoom: 15
      attributionControl: false
    @bounds = new L.LatLngBounds([center])
    @map.addLayer(new L.tileLayer("https://{s}.tiles.mapbox.com/v3/#{map_id}/{z}/{x}/{y}.png"))


  add: (sign) ->
    @signs.push(sign)
    @map.addLayer(sign.marker())
    @bounds.extend(sign.point)

  resize: =>
    if @signs.length == 1
      @map.panTo(@signs[0].point)
    else
      @map.fitBounds(@bounds)

window.Map = Map

$ ->
  if $('#market-map').length
    map = new Map("market-map", new L.LatLng(42.76, -86.10), $('#market-map').data('mapbox-map-id'))
    window.map = map
    map_data = $.parseJSON $("#market-map-data").text()
    _.each(map_data, (location) ->
      link = $("<a href=\"#{location.market_path}\">#{location.name}</a>")[0]
      map.add new MapMarket(new L.LatLng(
              +location.latitude,
              +location.longitude),
              $("<div>").append(link, $("<br/>"), $("<div>Plan: #{location.plan_name}</div>"))[0],
              location.plan_name))
    
