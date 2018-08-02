<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs tei"
	version="2.0">

	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:variable name="newline" select="'&#10;'"/>
    
	<xsl:variable name="works" select="document('../../authority/works_base.xml')//tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl"/>
	
	<xsl:template match="/">
	    <xsl:apply-templates/>
	    <xsl:value-of select="$newline"/>
	</xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>

    <xsl:template match="tei:msItem/tei:title">
		<xsl:copy>
			<xsl:copy-of select="@*[not(name()='key')]"/>
		    <xsl:variable name="title" select="normalize-space(string())"/>
			<xsl:variable name="matchingentries" select="$works[tei:title/text() = $title]"/>
            <xsl:choose>
            	<xsl:when test="count($matchingentries) eq 1">
            		<xsl:attribute name="key" select="$matchingentries/@xml:id"/>
            	</xsl:when>
            	<xsl:when test="count($matchingentries) gt 1">
            		<xsl:message>Multiple matches for <xsl:value-of select="$title"/> in <xsl:value-of select="parent::tei:msItem/@xml:id"/></xsl:message>
            		<xsl:attribute name="key" select="$matchingentries[1]/@xml:id"/>
            	</xsl:when>
            	<xsl:when test="count($matchingentries) eq 0">
            		<xsl:message>No matches for <xsl:value-of select="$title"/> in <xsl:value-of select="parent::tei:msItem/@xml:id"/></xsl:message>
            	</xsl:when>
            </xsl:choose>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>