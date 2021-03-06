class Map

  constructor: (container_id, center, map_id) ->
    @markets = []
    @map = new L.Map container_id,
      center: center
      zoom: 15
      attributionControl: false
    @bounds = new L.LatLngBounds([center])
    @map.addLayer(new L.tileLayer("https://{s}.tiles.mapbox.com/v3/#{map_id}/{z}/{x}/{y}.png"))

  add: (market) ->
    marker = market.marker()
    $(marker).ready =>
      @resize()
    @markets.push(market)
    @bounds.extend(market.point)
    @map.addLayer(marker)

  resize: =>
    if @markets.length == 1
      @map.panTo(@markets[0].point)
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

  if $('#map-canvas').length

    directionsService = new (google.maps.DirectionsService)
    directionsDisplay = new (google.maps.DirectionsRenderer)
  
    mapOptions =
      center: new google.maps.LatLng(30.055487, 31.279766),
      zoom: 8,
      mapTypeId: google.maps.MapTypeId.NORMAL,
      panControl: true,
      scaleControl: false,
      streetViewControl: true,
      overviewMapControl: true
  
    canvas = $('#map-canvas')
  
    map = new (google.maps.Map)(document.getElementById('map-canvas'), mapOptions)
    directionsDisplay.setMap map

    orig = canvas.data('orig')
    dest = canvas.data('dest')
    wp_raw = canvas.data('wp')
  
    wp = wp_raw.split('|')
    wp_a = []
    for w in wp
      do ->
        if w.length > 0
          wp_a.push {location: w, stopover: true}

    if wp.length > 0
      request =
        origin: orig
        destination: dest
        waypoints: wp_a
        optimizeWaypoints: true
        travelMode: google.maps.DirectionsTravelMode.DRIVING
    else
      request =
        origin: orig
        destination: dest
        travelMode: google.maps.DirectionsTravelMode.DRIVING
  
    directionsService.route request, (response, status) ->
      #Check if request is successful.
      if status == google.maps.DirectionsStatus.OK
        console.log status
      directionsDisplay.setDirections response
      #Display the directions result
      return

  if $('#map').length
    google.load("maps", "3", {callback: init, other_params:"key=AIzaSyDIGWmhdUPAIEyt8hlIAgBtTUIsOMhrjCc"});

init = () ->
  if (google.loader.ClientLocation != null)
    latLng = new google.maps.LatLng(google.loader.ClientLocation.latitude, google.loader.ClientLocation.longitude);
    loadAtStart(google.loader.ClientLocation.latitude, google.loader.ClientLocation.longitude, 8);
  else
    loadAtStart(37.4419, -122.1419, 8);

  canvas = $('#map')

  orig = canvas.data('orig')
  dest = canvas.data('dest')
  wp_raw = canvas.data('wp')

  origlatlng = orig.split(',')
  destlatlng = dest.split(',')
  o_ll = new (google.maps.LatLng)(parseFloat(origlatlng[0]),parseFloat(origlatlng[1]))
  d_ll = new (google.maps.LatLng)(parseFloat(destlatlng[0]),parseFloat(destlatlng[1]))

  addWaypointWithLabel(o_ll,'Origin')

  wp = wp_raw.split('|')
  wp_a = []
  for w in wp
    do ->
      if w.length > 0
        waylatlong = w.split(',')
        w_ll = new (google.maps.LatLng)(parseFloat(waylatlong[0]),parseFloat(waylatlong[1]))
        addWaypointWithLabel(w_ll,'Stop')

  addWaypointWithLabel(d_ll,'Destination')
  tsp.setAsStop(d_ll)
  directions(1,false,false)

  return
