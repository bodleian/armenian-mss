declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace saxon="http://saxon.sf.net/";
declare option saxon:output "indent=yes";

processing-instruction xml-model {'href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schamtypens="http://relaxng.org/ns/structure/1.0"'},
processing-instruction xml-model {'href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schamtypens="http://purl.oclc.org/dsdl/schematron"'},
processing-instruction xml-model {'href="authority-schematron.sch" type="application/xml" schamtypens="http://purl.oclc.org/dsdl/schematron"'},
<TEI xmlns="http://www.tei-c.org/ns/1.0">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title>Title</title>
            </titleStmt>
            <publicationStmt>
                <p>Publication Information</p>
            </publicationStmt>
            <sourceDesc>
                <p>Information about the source</p>
            </sourceDesc>
        </fileDesc>
    </teiHeader>
    <text>
        <body>
            <list>
{

    let $collection := collection('../../collections/?select=*.xml;recurse=yes')
    let $linebreak := '&#10;&#10;'
    
    (: First, extract all terms and places from the TEI files and build in-memory XML structure :)
       
    let $allsubjects as element()* := (
    
        for $p in $collection//tei:term[not(ancestor::tei:revisionDesc or ancestor::tei:respStmt) and (@target or @ref)]
            (: In Armenian, there are no marked up placeNames and all terms contain nothing but text and have a LoC URI :)
            let $uri := ($p/@target/data(), $p/@ref/data())[1]
            let $locid := replace($uri, '.*?([a-z]+[0-9]+).*', '$1')
            return
            <subject>
                <name>{ $p/text() }</name>
                <locid>{ $locid }</locid>
                <ref>{ concat(substring-after(base-uri($p), 'collections/'), '#', $p/ancestor::*[@xml:id][1]/@xml:id) }</ref>
            </subject>
    )
   
    (: Now de-duplicate, generating keys :)
    
    let $dedupedsubjects as element()* := (
    
        for $t in distinct-values($allsubjects/locid)
            return
            <item xml:id="{ concat('subject_', $t) }">
                {
                for $n at $i in distinct-values($allsubjects[locid/text() = $t]/name/text())
                    return
                    <term type="{ if ($i eq 1) then 'display' else 'variant' }">{ $n }</term>
                }
                <note type="links">
                    <list type="links">
                        <item>
                            <ref target="{
                                if (starts-with($t, 'sh')) then concat('https://id.loc.gov/authorities/subjects/', $t, '.html')
                                else if (starts-with($t, 'n')) then concat('https://id.loc.gov/authorities/names/', $t, '.html')
                                else concat('https://lccn.loc.gov/', $t)
                                }">
                                <title>LC</title>
                            </ref>
                        </item>
                    </list>
                </note>
                {
                for $r in $allsubjects[locid/text() = $t]/ref/text()
                    return
                    comment{concat(' ../collections/', replace($r, '\-', '%2D'), ' ')}
                }
            </item>
    )
    
    (: Output the authority file :)
    for $s in $dedupedsubjects
        order by lower-case($s/term[1]/text())
        return ($linebreak, $s)

}
            </list>
        </body>
    </text>
</TEI>




        
