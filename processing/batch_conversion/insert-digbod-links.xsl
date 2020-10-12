<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="/"
    exclude-result-prefixes="xs tei local"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
    
    <!-- Save the response from the following Solr query run on whichever Digital Bodleian core is the current production copy:
         http://<solr_server>:<solr_port>/solr/<core_name>/select?fl=id,shelfmark_s,surface_count_i,completeness_s&fq=all_collections_id_sm%3Aarmenian&q=*%3A*&rows=9999&wt=xml-->
    <xsl:variable name="dbsolrresponse" as="document-node()" select="document('/tmp/armenian_db.xml')"/>
    
    <!-- Match up results in the Solr response to the current TEI record, based on the same (or differing only by punctuation) shelfmarks -->
    <xsl:variable name="shelfmark" as="xs:string" select="/tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:sourceDesc[1]/tei:msDesc[1]/tei:msIdentifier[1]/tei:idno[1]/string()"/>
    <xsl:variable name="normshelfmark" as="xs:string" select="local:normalizeShelfmark($shelfmark)"/>
    <xsl:variable name="matchedonshelfmark" as="element(doc)*" select="for $doc in $dbsolrresponse/response/result/doc return if (local:isSameShelfmark($normshelfmark, $doc/str[@name='shelfmark_s']/string(), true(), false())) then $doc else ()"/>
    
    <xsl:variable name="newline" as="xs:string" select="'&#10;'"/>

    <xsl:template match="/">
        <xsl:value-of select="$newline"/>
        <xsl:for-each select="processing-instruction()">
            <xsl:copy/>
            <xsl:value-of select="$newline"/>
        </xsl:for-each>
        <xsl:apply-templates select="comment()[following-sibling::tei:TEI]"/>
        <xsl:choose>
            <xsl:when test="count($matchedonshelfmark) gt 0">
                <xsl:apply-templates select="tei:TEI"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="tei:TEI"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"/>
        <xsl:apply-templates select="comment()[preceding-sibling::tei:TEI]"/>
    </xsl:template>
    
    <xsl:template match="tei:additional[not(tei:surrogates)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <!-- Add new links to Digital Bodleian -->
            <xsl:element name="surrogates" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:call-template name="AddLinks"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:additional/tei:surrogates">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <!-- Add new links to Digital Bodleian, but do not overwrite any already linked -->
            <xsl:call-template name="AddLinks">
                <xsl:with-param name="excludeuuids" as="xs:string*" select="for $target in tei:bibl/tei:ref/@target return tokenize($target, '/')[matches(., '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')]"/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template name="AddLinks">
        <xsl:param name="excludeuuids" as="xs:string*"/>
        <xsl:for-each select="$matchedonshelfmark">
            <xsl:sort select="./int[@name='surface_count_i']/string() cast as xs:integer" order="descending"/>
            <xsl:variable name="uuid" as="xs:string" select="./str[@name='id']/string()"/>
            <xsl:if test="not($uuid = $excludeuuids)">
                <xsl:variable name="isfull" as="xs:boolean" select="if (./str[@name='completeness_s']/string() eq 'complete') then true() else false()"/>
                <xsl:variable name="numimages" as="xs:integer" select="./int[@name='surface_count_i']/string() cast as xs:integer"/>
                <bibl xmlns="http://www.tei-c.org/ns/1.0" type="digital-facsimile" subtype="{ if ($isfull) then 'full' else 'partial' }">
                    <ref target="https://digital.bodleian.ox.ac.uk/inquire/p/{ $uuid }">
                        <title>Digital Bodleian</title>
                    </ref>
                    <xsl:text> </xsl:text>
                    <note>
                        <xsl:choose>
                            <xsl:when test="$isfull">
                                <xsl:text>(full digital facsimile)</xsl:text>
                            </xsl:when>
                            <xsl:when test="$numimages gt 1">
                                <xsl:text>(</xsl:text>
                                <xsl:value-of select="$numimages"/>
                                <xsl:text> selected images only)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>(single sample image)</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </note>
                </bibl>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:function name="local:normalizeShelfmark" as="xs:string">
        <xsl:param name="shelfmark" as="xs:string"/>
        <xsl:value-of select="lower-case(replace(replace(normalize-space(replace($shelfmark, '\([^\)]+\)', '')), '[^A-Za-z0-9]', '_'), 'Wardrop', 'Wardr_'))"/>
    </xsl:function>
    
    <xsl:function name="local:isSameShelfmark" as="xs:boolean">
        <xsl:param name="shelfmark1" as="xs:string"/>
        <xsl:param name="shelfmark2" as="xs:string"/>
        <xsl:param name="prenormalized1" as="xs:boolean"/>
        <xsl:param name="prenormalized2" as="xs:boolean"/>
        <xsl:choose>
            <xsl:when test="$prenormalized1 and $prenormalized2">
                <xsl:copy-of select="boolean($shelfmark1 eq $shelfmark2)"/>
            </xsl:when>
            <xsl:when test="$prenormalized1">
                <xsl:copy-of select="boolean($shelfmark1 eq local:normalizeShelfmark($shelfmark2))"/>
            </xsl:when>
            <xsl:when test="$prenormalized2">
                <xsl:copy-of select="boolean(local:normalizeShelfmark($shelfmark1) eq $shelfmark2)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="boolean(local:normalizeShelfmark($shelfmark1) eq local:normalizeShelfmark($shelfmark2))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>