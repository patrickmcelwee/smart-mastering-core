xquery version "1.0-ml";

(:~
 : This module provides a set of defined constants that are intended to be used
 : both within the smart-mastering-core libraries as well as in application code
 : that uses Smart Mastering.
 :)
module namespace constants = "http://marklogic.com/smart-mastering/constants";

(: Collections :)
declare variable $ALGORITHM-COLL as xs:string := "mdm-algorithm";

(:~ Contains entity documents that have been merged with other entity documents.
 : Applications should avoid searching this collection.
 :)
declare variable $ARCHIVED-COLL as xs:string := "mdm-archived";

(:~ Contains documents that track the history of the entity documents. :)
declare variable $AUDITING-COLL as xs:string := "mdm-auditing";

(:~ Contains master entity documents. Applications should limit search to this collection. :)
declare variable $CONTENT-COLL as xs:string := "mdm-content";
declare variable $DICTIONARY-COLL as xs:string := "mdm-dictionary";
declare variable $MATCH-OPTIONS-COLL as xs:string := "mdm-match-options";
declare variable $MERGE-COLL as xs:string := "mdm-merge";
declare variable $MERGED-COLL as xs:string := "mdm-merged";
declare variable $MODEL-MAPPER-COLL as xs:string := "mdm-model-mapper";
declare variable $NOTIFICATION-COLL as xs:string := "mdm-notification";
declare variable $OPTIONS-COLL as xs:string := "mdm-options";

(: Roles :)
declare variable $MDM-USER as xs:string := "mdm-user";
declare variable $MDM-ADMIN as xs:string := "mdm-admin";

(: Actions :)
declare variable $MERGE-ACTION as xs:string := "merge";
declare variable $NOTIFY-ACTION as xs:string := "notify";

(: Notification statuses :)
declare variable $STATUS-READ as xs:string := "read";
declare variable $STATUS-UNREAD as xs:string := "unread";

(: Predicate for recording match blocks between two documents :)
declare variable $PRED-MATCH-BLOCK := sem:iri("http://marklogic.com/smart-mastering/match-block");

(: Formats for functions that accept a format parameter :)
declare variable $FORMAT-JSON as xs:string := "json";
declare variable $FORMAT-XML  as xs:string := "xml";
