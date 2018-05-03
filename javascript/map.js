var map;
var bounds = new google.maps.LatLngBounds();
var position;
var infowindow = null;
var markers = [];
var geocoder = new google.maps.Geocoder();
var year= 2015;

function icon_circle(color) {
   return {
    path: google.maps.SymbolPath.CIRCLE,
    fillColor: color,
    fillOpacity: 1,
    scale: 4.5,
    strokeColor: color,
    strokeWeight: 1
    }
};
function htmlDecode(input){
  var e = document.createElement('div');
  e.innerHTML = input;
  return e.childNodes[0].nodeValue;
}

var debug = false;

function initialize() { 
  div = document.getElementById("map_canvas");
  if (div == null) return null;
  map = new google.maps.Map(div,{
      zoom:  zoom,
      panControl: false,
      zoomControl: true,
      mapTypeControl: true,
      scaleControl: true,
      streetViewControl: false,
      overviewMapControl: false,

      center: centre,
      mapTypeId: 'roadmap'
      }); 
   addMarkers();
//   if (markers.length > 0)map.fitBounds(bounds);

   infowindow =  new google.maps.InfoWindow( {
          content: "loading ... "
       });         
 
      if (debug) alert(map.center);

}   

function addMarkers() {
   for (i in sites){
       var site = sites[i];
       var text = htmlDecode(site[3]);        
       position = new google.maps.LatLng(site[1],site[2]);
       bounds.extend(position);
       var color = site[4][year-2011];
       marker = new google.maps.Marker({
          position: position,
          title: site[0],
          map: map,
          icon: icon_circle(color),
          html: text
       });
       markers[i]=marker;
       google.maps.event.addListener(marker,'click', function() {
            infowindow.setContent(this.html);
            infowindow.open(map, this);
        });
   }
 }

function set_year(new_year) {
    $('#'+year).toggleClass('blue');
    year=new_year;
    for (i in markers) {
        var m = markers[i];
        var site =sites[i];
        var color = site[4][year-2011];
        m.setIcon(icon_circle(color));
    }
     $('#'+year).toggleClass('blue');
}

$(document).ready(function() {   
    initialize ();
  });
