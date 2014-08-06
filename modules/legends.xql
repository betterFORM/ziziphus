xquery version "3.0";

import module namespace app="http://www.betterform.de/projects/shared/config/app" at "/apps/cluster-shared/modules/ziziphus/config/app.xqm";

declare %private variable $legends-map := map {
                                              "role-codes" := "role-codes-legend.xml"
                                          };

let $legend := xs:string(request:get-parameter("legend", "role-codes"))
let $data := if($table ne "") then ( $app:legends || $legends-map($table) ) else ( "http://www.example.com/" )
return
    $data