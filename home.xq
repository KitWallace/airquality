import module namespace aq = "http://kitwallace.co.uk/lib/ag" at "./lib/aq.xqm";

let $sites := $aq:sites
let $wards := $aq:wards

let $id := request:get-parameter("id",())
let $mode := request:get-parameter("mode","map")
let $serialize := util:declare-option("exist:serialize" ,"method=xhtml media-type=text/html")
return 
<html>
  <head>
     <link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Merriweather Sans" />
     <link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Gentium Book Basic" />
          <script type="text/javascript" src="javascript/sorttable.js"></script> 
     <link rel="stylesheet" type="text/css" href="assets/base.css" media="screen" ></link>

     <script src="https://maps.googleapis.com/maps/api/js?key={$aq:googlekey}"></script>
     <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
     <script type="text/javascript"> var draggable = false; </script>

     <script type="text/javascript" src="javascript/map.js"></script> 
     <script type="text/javascript"> var centre = new google.maps.LatLng({$aq:centre[1]},{$aq:centre[2]}); var zoom = 12; </script>
 
  </head>
  <body>
   <h1><a href="?mode=about">Air Quality in Bristol</a>  |   <a href="?mode=map">NO<sup>2</sup> Map</a>&#160; | <a href="?mode=table"> NO<sup>2</sup> Table</a>
   |  <a href="?mode=continuous">Continuous Monitoring</a>
   </h1> 
   <hr/>
  {if ($mode="table")
  then
  <div>
  <h3>      <span><span style="color: gray;">gray: no data </span>| <span style="color: yellow;">yellow: &lt; 40 µg/m³ </span> | <span style="color: coral;">red : 40 to &lt; 60</span>
       | <span style="color: plum;">purple &gt; 60</span> </span>
</h3>
  <div>Click on column heading to sort. NO<sup>2</sup> values are in µg/m³ averaged over a year. 40 is the UK/EU limit.</div>
  <table class="sortable">

     <tr>
          <th>Id</th>
          <th>Location</th>
          <th>Distance to Road (m)</th>
          <th>Distance to Kerb (m)</th>
       {for $year in 2011 to 2016
       return <th>NO<sup>2</sup> - {$year}</th>
       }
      <th>Ward</th>
 <!--     <th>#Trees within 100m</th>
      <th># Vehicles per day</th>
      <th>Estimation Method</th>
      <th>Count Point</th>
      <th>Distance in m to count Point</th>
      <th>Est. Speed</th>
-->
     </tr>
     {for $site in $sites
      let $ward :=$wards[id=$site/id]
      return 
           <tr>
              <td>{$site/id}</td>
              <td><a href="?mode=site&amp;id={$site/id}">{$site/name}</a></td>
              <td>{$site/distance-to-nearest-road/string()}</td>
              <td>{$site/distance-to-kerb/string()}</td>
              {for $year in 2011 to 2016
                let $no2 := $site/no2[year=$year]
                let $value := $no2/value
                return <td>
                          {attribute style {concat("background-color:",aq:severity ($value))}}
                          {$value}
                      </td>
              }
             <td>{$ward/wardname/string()}</td>
   <!--          <td>{attribute style {concat("background-color:",
                  if ($site/trees-100m <=5) then "red" else if ($site/trees-100m<20) then "orange" else "green")}}
                 {$site/trees-100m}</td>     
              
             <td>{attribute style {concat("background-color:",
                  if ($site/traffic/AllMotorVehicles <=20000) then "green" else if ($site/traffic/AllMotorVehicles<50000) then "orange" else "red")}}
                  {$site/traffic/AllMotorVehicles}</td>
                  <td>{$site/traffic/Estimation_method}</td>
                  <td>{$site/traffic/name}</td>
             <td>{round($site/traffic/distance)}</td>
             <td>{attribute style {concat("background-color:",
                  if ($site/speed/est_speed <10) then "red" else if ($site/speed/est_speed<20) then "orange" else "green")}}
                  {$site/speed/est_speed}</td>
             <td>{round($site/speed/distance)}</td>
    -->
           </tr>
      } 
  </table>
  </div>
  else if ($mode="map")
  then 
   <div> 
     <h2>Year 
       {for $y in $aq:years
        return
          <button id="{$y}" onclick="set_year({$y})">{if ($y = 2015) then attribute class {'blue'} else ()} {$y}</button>
       }
       &#160; 
       </h2>
     <h3>      <span><span style="color: gray;">gray: no data </span>| <span style="color: yellow">yellow: &lt; 40 µg/m³ </span> | <span style="color: coral;">red : 40 to &lt; 60</span>
       | <span style="color: plum;">purple &gt; 60</span> </span>
</h3>
       {aq:aq-markers($sites)}
        <div id="map_canvas" class="full_canvas"></div>
   </div>
 else if ($mode="about")
 then 
    <div>

    <div  style="padding-top:20">This site aims to gather and visualise data on Air Quality in Bristol. Currently it provides :
       <ul>
         <li>A <a href="?mode=map">Map</a> showing NO<sup>2</sup> Annual average readings from diffusion tubes for the years 2013 to 2016.</li>
         <li>The same data in <a href="?mode=table">Table</a> form</li>
         <li>A page for each site eg <a href="?mode=site&amp;id=161">Bishop Road</a></li>
         <li>A list of the current <a href="?mode=continuous">continuous monitoring stations</a></li>
       </ul>
    </div>

    <h3>Sources </h3>
    <ul>
      <li>NO2 data from WFS source http://maps.bristol.gov.uk/arcgis/services/ext/datagov/MapServer/WFSServer?</li>
      <li>Site metadata from <a href="https://opendata.bristol.gov.uk/explore/dataset/no2-diffusion-tube-data-2016-annual-mean">Opendata.bristol.gov.uk</a></li>
   
    </ul>
    
    <h3>Links</h3>
    <ul>
      <li><a href="https://www.bristol.gov.uk/en_US/pests-pollution-noise-food/air-quality">Bristol City Council</a></li>
      <li><a href="http://ec.europa.eu/environment/air/quality/standards.htm">Air Quality Standards</a></li>
      <li><a href="http://www.bristol.airqualitydata.com/">BCC Air Quality Date</a></li>
      <li><a href="http://www.claircity.eu/bristol/about/">Clair City Bristol</a></li>
      <li><a href="http://www.claircity.eu/bristol/city-shockers/air-pollution-map-of-bristol/">Bristol Map on Claircity.eu</a></li>
      <li><a href="http://kitwallace.tumblr.com/post/158996314739/air-quality-in-bristol">Chris Wallace blog post on this site</a></li>

    </ul>
    
    <div>This site developed by <a href="http://kitwallace.co.uk">Chris Wallace</a> &#160; <a href="https://twitter.com/kitwallace">@kitwallace</a>  Code and data on <a href="https://github.com/KitWallace/airquality">GitHub</a>
   
    </div>
    </div>
 else if ($mode="glossary")
 then 
     aq:glossary()
 else if ($mode="site" and exists ($id))
 then 
   let $site := $sites[id=$id]
   let $site-data :=$aq:site-data[SiteID=$id]
   let $ward := $wards[id=$id]
   let $csite := $aq:continuous-sites[id=$id]
   let $latitude := ($site/latitude,$csite/latitude)[1]
   let $longitude := ($site/longitude,$csite/longitude)[1]
   return
   <div>
      <div class="leftside" style="padding-left:20">
        <h3>Site Details</h3>
      <table>
      <tr><th>Location</th><td>{$site-data/location/string()}</td></tr>
       <tr><th>Location description</th><td>{$site-data/Detailed_Location/string()}</td></tr>
      <tr><th>Location Class</th><td>{$site-data/LocationClass/string()}</td></tr>  
       <tr><th>Lat/long</th><td>
       
       <a target="_blank" class="external" href="http://www.openstreetmap.org/index.html?mlat={$latitude}&amp;mlon={$longitude}&amp;zoom=16">Open Street Map</a></td></tr>
       <tr><th>Ward</th><td>{$ward/wardname/string()}</td></tr>  
      <tr><th width="30%">Current ?</th><td>{$site-data/Current/string()}</td></tr>
       <tr><th>Pollutants</th><td>{$site-data/pollutants/string()}</td></tr>
       <tr><th>Instrument Type</th><td>{$site-data/InstrumentType/string()}</td></tr>
       <tr><th>Exposure ?</th><td>{$site-data/Exposure/string()}</td></tr>
       <tr><th>AQMA</th><td>{$site-data/AQMA/string()}</td></tr>
        <tr><th>Tube-Kerb distance</th><td>{$site-data/tube_kerb_distance_m/string()} m</td></tr>
       <tr><th>Sample Height</th><td>{$site-data/Sample_Height/string()} m</td></tr>
       <tr><th>Elevation</th><td>{$site-data/Elevation/string()} m</td></tr>    
       {if ($site)
       then 
       <tr><th>NO2</th>
       <td><table>
       {for $year in 2011 to 2016
                let $no2 := $site/no2[year=$year]
                let $value := $no2/value
                return <tr><th>{$year}</th><td>
                          {attribute style {concat("background-color:",aq:severity ($value))}}
                          {$value}
                      </td>
                      </tr>
        }
        </table></td></tr>
        else ()
        }
        {if ($csite)
         then
         
         let $data := if ($csite/operator="BCC") then aq:get-current-data($csite/link[@data]/href) else ()
         return
         (if ($data) then <tr><th>Current Readings</th><td>{$data}</td></tr> else (),
         <tr><th>Links</th>
          <td>{for $link in $csite/link
               return 
                  <div><a href="{$link/href}">{$link/title/string()}</a> </div>
              }
           </td>
         </tr>
         )
        else ()
         }
     </table>
     </div>
     <div class="rightside">
        <img width="500" src="{$site-data/photopath}"/>
     </div>
   </div>
else if ($mode="continuous")
then
   let $sites := $aq:continuous-sites
   return
   <div>
   <h3>Continuous Monitoring stations</h3>
     <table>
     <tr><th>Operator</th><th>Location</th></tr>
       {for $site in $sites
        let $s := $aq:sites[id=$site/id]
        order by $site/operator
        return 
         <tr><th>{$site/operator/string()}</th><th><a href="?mode=site&amp;id={$site/id}"> {$site/name/string()}</a></th>
         </tr>
        }
     </table>
   
   </div>
 
 else ()
   }
</body>
</html>
