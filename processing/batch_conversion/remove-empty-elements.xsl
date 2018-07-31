<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:bod="https://www.bodleian.ox.ac.uk/bdlss"
	exclude-result-prefixes="xs tei bod"
	version="2.0">
       
	<xsl:variable name="newline" select="'&#10;'"/>

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
    
    <xsl:template match="*[not(.//comment()) and not(.//@*[not(name() = ('xml:lang', 'role'))]) and string-length(normalize-space(string-join(.//text(), ''))) eq 0]">
        <!-- Remove any element (except the origin) that is self-closing, or just contains whitespace, 
             or contains nothing but child elements which themselves contains nothing. Attributes are
             counted as something worth keeping, unless they are xml:langs or roles. -->
    </xsl:template>

</xsl:stylesheet>