xquery version "1.0-ml";

(:
 : This is an implementation library, not an interface to the Smart Mastering functionality.
 :)

module namespace not-impl = "http://marklogic.com/smart-mastering/notification-impl";

import module namespace const = "http://marklogic.com/smart-mastering/constants"
  at "/ext/com.marklogic.smart-mastering/constants.xqy";
import module namespace json="http://marklogic.com/xdmp/json"
  at "/MarkLogic/json/json.xqy";

declare namespace sm = "http://marklogic.com/smart-mastering";

declare option xdmp:mapping "false";

declare function not-impl:save-match-notification(
  $threshold-label as xs:string,
  $uris as xs:string*
)
{
  let $existing-notification :=
    not-impl:get-existing-match-notification(
      $threshold-label,
      $uris
    )
  let $new-notification :=
    element sm:notification {
      element sm:meta {
        element sm:dateTime {fn:current-dateTime()},
        element sm:user {xdmp:get-current-user()},
        element sm:status { $const:STATUS-UNREAD }
      },
      element sm:threshold-label {$threshold-label},
      element sm:document-uris {
        let $distinct-uris :=
          fn:distinct-values((
            $uris,
            $existing-notification
            /sm:document-uris
              /sm:document-uri ! fn:string(.)
          ))
        for $uri in $distinct-uris
        return
          element sm:document-uri {
            $uri
          }
      }
    }
  return
    if (fn:exists($existing-notification)) then (
      xdmp:node-replace(fn:head($existing-notification), $new-notification),
      for $extra-doc in fn:tail($existing-notification)
      return
        xdmp:document-delete(xdmp:node-uri($extra-doc))
    ) else
      xdmp:document-insert(
        "/com.marklogic.smart-mastering/matcher/notifications/" ||
        sem:uuid-string() || ".xml",
        $new-notification,
        (
          xdmp:default-permissions(),
          xdmp:permission($const:MDM-USER, "read"),
          xdmp:permission($const:MDM-USER, "update")
        ),
        $const:NOTIFICATION-COLL
      )
};

declare function not-impl:get-existing-match-notification(
  $threshold-label as xs:string,
  $uris as xs:string*
) as element(sm:notification)*
{
  cts:search(fn:collection()/sm:notification,
    cts:and-query((
      cts:element-value-query(
        xs:QName("sm:threshold-label"),
        $threshold-label
      ),
      cts:element-value-query(
        xs:QName("sm:document-uri"),
        $uris
      )
    ))
  )
};

(:
 : Delete the specified notification
 : TODO: do we want to add any provenance tracking to this?
 :)
declare function not-impl:delete-notification($uri as xs:string)
{
  xdmp:document-delete($uri)
};

(:
 : Translate a notifcation into JSON.
 :)
declare function not-impl:notification-to-json($notification as element(sm:notification))
  as object-node()
{
  object-node {
    "meta": object-node {
      "dateTime": $notification/sm:meta/sm:dateTime/fn:string(),
      "user": $notification/sm:meta/sm:user/fn:string(),
      "uri": fn:base-uri($notification),
      "status": $notification/sm:meta/sm:status/fn:string()
    },
    "thresholdLabel": $notification/sm:threshold-label/fn:string(),
    "uris": array-node {
      for $uri in $notification/sm:document-uris/sm:document-uri
      return
        object-node { "uri": $uri/fn:string() }
    },
    "names": xdmp:to-json(
      let $o := json:object()
      let $_ :=
        for $uri in $notification/sm:document-uris/sm:document-uri
        let $doc := fn:doc($uri)
        let $name := $doc//*:PersonGivenName || " " || $doc//*:PersonSurName
        return
          map:put($o, $uri, $name)
      return $o
    )
  }
};

(:
 : Paged retrieval of notifications
 :)
declare function not-impl:get-notifications-as-xml($start as xs:int, $end as xs:int)
as element(sm:notification)*
{
  (fn:collection($const:NOTIFICATION-COLL)[$start to $end])/sm:notification
};

(:
 : Paged retrieval of notifications
 :)
declare function not-impl:get-notifications-as-json($start as xs:int, $end as xs:int)
as array-node()
{
  array-node {
    not-impl:get-notifications-as-xml($start, $end) ! not-impl:notification-to-json(.)
  }
};

(:
 : Return a count of all notifications
 :)
declare function not-impl:count-notifications()
as xs:int
{
  xdmp:estimate(fn:collection($const:NOTIFICATION-COLL))
};

(:
 : Return a count of unread notifications
 :)
declare function not-impl:count-unread-notifications()
as xs:int
{
  xdmp:estimate(
    cts:search(
      fn:collection($const:NOTIFICATION-COLL),
      cts:element-value-query(xs:QName("sm:status"), $const:STATUS-UNREAD))
  )
};

declare function not-impl:update-notification-status(
  $uri as xs:string+,
  $status as xs:string
)
{
  xdmp:node-replace(
    fn:doc($uri)/sm:notification/sm:meta/sm:status,
    element sm:status { $status }
  )
};
