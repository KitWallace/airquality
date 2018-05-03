module namespace aq ="http://kitwallace.co.uk/lib/ag" ;
declare variable $aq:site-path := "/db/apps/airquality/data/BCC-NO2-2016.xml";
declare variable $aq:sites := doc($aq:site-path)//site;
declare variable $aq:wards := doc("/db/apps/airquality/data/site-wards.xml")//site;
declare variable $aq:site-data := doc("/db/apps/airquality/data/site-data.xml")//site;
declare variable $aq:continuous-sites := doc("/db/apps/airquality/data/continuous-sites.xml")//site;
declare variable $aq:glossary := doc("/db/apps/airquality/data/glossary.xml")//term;
declare variable $aq:centre :=  (51.460499,-2.594697);
declare variable $aq:googlekey  := "AIzaSyB-sB9Nwqkh-imfUd1-w3_lz4KFhL-_VqU";
declare variable $aq:years := 2011 to 2016;

declare function aq:severity ($value){
  if (empty($value)) then "gray" else if ($value <= 40) then "yellow" else  if ($value <=60) then "coral"  else "plum"
};

declare function aq:aq-markers($sites as element(site)* ) as element(script) {
<script type="text/javascript">

var sites = [
   { string-join(
       for $site in $sites
       let $title := replace($site/name,"'","\\'")                     
       let $popup :=  util:serialize(
         <div><h1><a href="?mode=site&amp;id={$site/id}">{$title}</a></h1>
         <table>
           {for $no2 in $site/no2
            return 
             <tr><th>{$no2/year/string()}</th><td>{$no2/value/string()}</td></tr>
           }       
         </table></div>,
          "method=xhtml media-type=text/html indent=no") 

       return
          concat("['",$title,"',",
                  $site/latitude,",",$site/longitude,
                  ",'",$popup,"',[",string-join(for $year in $aq:years
                                    let $no2 := $site/no2[year=$year]
                                    let $color := if ($no2) then aq:severity($no2/value) else "gray"
                                    return concat("'", $color,"'"),",")
                                     ,"]]")
       ,",&#10;")
     }
     ];
</script> 
};

declare function aq:get-current-data($href) {
  let $table := httpclient:get(xs:anyURI($href),false(),())//table[starts-with(@summary,"Current Readings")]
  return $table
};

declare function aq:glossary() {

    let $terms := $aq:glossary
    return
    <div>
       <h2>Glosssary of Air Quality Terminology</h2>
       {for $term in $terms
        order by $term/name[1]
        return
          <div id="{$term/name[1]}">
             <h3>{$term/name[1]/string()}
                 {
                 if (count($term/name) > 1)
                 then concat( " (", string-join(subsequence($term/name,2),", "),")")
                 else ()
                 }
             </h3>
              <div class="def">
             {for $sa in $term/seealso
              return <div> See also <a href="#{$sa}">{$sa}</a></div>
             }
             
            
                {$term/definition/div}
             {if ($term/link)
              then 
                 <div>
                   <h4>References</h4>
                   {for $link in $term/link
                    return 
                      <div><a href="{$link/url}">{$link/title/string()}</a></div>
                   }
                   
                   </div>
              else ()
              }
              </div>
            </div>
       }
    </div>
 };

