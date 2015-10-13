xquery version "3.0";

declare namespace vra = "http://www.vraweb.org/vracore4.htm";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace app="http://github.com/hra-team/rosids-shared/config/app" at "/apps/rosids-shared/modules/ziziphus/config/app.xqm";
import module namespace security="http://exist-db.org/mods/security" at "/apps/rosids-shared/modules/search/security.xqm";
import module namespace app="http://github.com/hra-team/rosids-shared/config/app" at "/apps/rosids-shared/modules/ziziphus/config/app.xqm";

declare variable $user := security:get-user-credential-from-session()[1];
declare variable $userpass := security:get-user-credential-from-session()[2];

declare %private function local:dataDate($record) {
    let $transform := "xmldb:exist:///db/apps/ziziphus/resources/xsl/save-dataDate.xsl"
    return
        transform:transform($root, $transform, ())
};

declare %private function local:cleanupData($record) {
    let $transform := "xmldb:exist:///db/apps/ziziphus/resources/xsl/save-cleanup.xsl"
    return
        transform:transform($root, $transform, ())
};

let $id := request:get-parameter('id','')
let $workdir :=  request:get-parameter('workdir','')
let $workdir := if($workdir eq "") then (xmldb:encode($app:ziziphus-default-record-dir)) else (xmldb:encode($workdir))
let $vraSet := request:get-parameter('set','')

let $log1 := util:log('info',concat('id=',$id,' vraSet=',$vraSet))

(: get the new data from the form :)
let $newData := request:get-data()
let $oldData := app:get-resource($uuid)//*[local-name() eq $vraSet]
let $toSave :=
<save:data xmlns:save="http://www.betterform.de/save">
    <save:originalInstance>
        {$oldData}
    </save:originalInstance>
    <save:newInstance>
        {$newData}
    </save:newInstance>
</save:data>
let $newData := function local:dataDate($toSave)

let $security := system:as-user($user, $userpass,
    (
        (: fetch original record from database :)
        let $record := collection($workdir)//vra:vra/*[./@id=$id]
        let $log2 := util:log('info', "RECORD ID: " || data($record/@id))
        let $log3 := util:log('info', "WORKDIR: " || $workdir)
        let $log4 := util:log("info", "xmldb:get-current-user before: " || xmldb:get-current-user())

        let $canWrite := true()
        (: let $canWrite := security:can-write-collection(xs:anyURI($workdir)) :)
        let $log11 := util:log("info", "xmldb:get-current-user after: " || xmldb:get-current-user())
        (: let $log12 := util:log("info", "security:can-write-collection: " || security:can-write-collection(xs:anyURI($workdir))) :)
        let $log13 := util:log("info", "sm:get-permissions Collection: " ||  sm:get-permissions(xs:anyURI($workdir))/sm:permission/@mode)
        let $log14 := util:log("info", "sm:get-permissions File: " ||  sm:get-permissions(xs:anyURI(util:collection-name($record) || "/" || util:document-name($record)))/sm:permission/@mode)
        return
            if($canWrite)
            then (
                let $update :=
                    if(exists($record/*[local-name() eq $vraSet]))
                    then (
                        if(count($newData/*[local-name() eq $vraSet]/*) = 0)
                        then (
                            let $log21 := util:log("info", "Update delete!")
                            return
                                try {
                                    update delete $record/*[local-name() eq $vraSet]/*
                                } catch * {
                                    let $log211 := util:log("info", "Update delete failed! <"|| $err:code ||'>:<'|| $err:description ||'>:<'|| $err:value || '>')
                                    let $error-code := if($err:code = 'java:org.exist.security.PermissionDeniedException' )then (response:set-status-code('403')) else (response:set-status-code('500'))
                                    return <error>$err:description</error>
                                }
                        ) else (
                            let $log21 := util:log("info", "Update replace!")
                            return
                                try {
                                    update replace $record/*[local-name(.)=$vraSet] with $newData
                                } catch * {
                                    let $log211 := util:log("info", "Update replace failed! <"|| $err:code ||'>:<'|| $err:description ||'>:<'|| $err:value || '>')
                                    let $error-code := if($err:code = 'java:org.exist.security.PermissionDeniedException' )then (response:set-status-code('403')) else (response:set-status-code('500'))
                                    return <error>$err:description</error>
                                }
                        )
                    ) else (
                        if(exists($record/*[local-name(.) > $vraSet][1]))
                        then (
                            let $log22 := util:log("info", "Update insert preceding!")
                            return
                                try {
                                    update insert $newData preceding $record/*[local-name(.) > $vraSet][1]
                                } catch * {
                                    let $log221 := util:log("info", "Update insert preceding failed! <"|| $err:code ||'>:<'|| $err:description ||'>:<'|| $err:value || '>')
                                    let $error-code := if($err:code = 'java:org.exist.security.PermissionDeniedException' )then (response:set-status-code('403')) else (response:set-status-code('500'))
                                    return <error>$err:description</error>
                                }
                        ) else (
                            let $log23 := util:log("info", "Update insert following!")
                            return
                                try {
                                    update insert $newData following ($record/vra:*[local-name(.) < $vraSet])[last()]
                                } catch * {
                                    let $log231 := util:log("info", "Update insert following failed! <"|| $err:code ||'>:<'|| $err:description ||'>:<'|| $err:value || '>')
                                    let $error-code := if($err:code = 'java:org.exist.security.PermissionDeniedException' )then (response:set-status-code('403')) else (response:set-status-code('500'))
                                    return <error>$err:description</error>
                                }
                        )
                    )
                return $update
            ) else (
                let $error-code := response:set-status-code('403')
                let $log24 := util:log("info", "User can not write into collection")
                return <error>User can not write intocollection</error>
            )
    )
)
return $security

(:
    if($security)
    then (
        let $record := app:get-resource($uuid)
        let $dataDate := local:dataDate($record)
        let $cleanup := local:cleanupData($dataDate)
        let $return :=
            try {
                let $store := system:as-user($app:dba-credentials[1], $app:dba-credentials[2], xmldb:store(util:collection-name($record), util:document-name($record), $cleanup) )
                return true()
            catch * {
                let $log := util:log("ERROR", "Ziziphus: Savining of cleaned record " || $uuid || " failed: " || $err:description)
                return false()
            }
        return
            if($return)
            then (
            ) else (
                (: TODO: FAILURE! :)
            )
    ) else (
        (: TODO: FAILURE! :)
    )

:)