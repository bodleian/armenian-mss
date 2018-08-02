<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs tei"
	version="2.0">

	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:variable name="newline" select="'&#10;'"/>
    
	<xsl:variable name="subjects" select="document('../../authority/subjects_base.xml')//tei:TEI/tei:text/tei:body/tei:list/tei:item"/>
	
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

	<xsl:template match="tei:term">
		<xsl:copy>
			<xsl:copy-of select="@*[not(name()='key')]"/>
		    <xsl:if test="@target or @ref">
		        <xsl:variable name="uri" select="(@target, @ref)[1]"/>
		    	<xsl:variable name="locid" select="replace($uri, '.*?([a-z]+[0-9]+).*', '$1')"/>
		    	<xsl:variable name="subjectkey" select="concat('subject_', $locid)"/>
		        <xsl:variable name="matchingentries" select="$subjects[@xml:id = $subjectkey]"/>
		        <xsl:choose>
		            <xsl:when test="count($matchingentries) eq 1">
		                <xsl:attribute name="key" select="$matchingentries/@xml:id"/>
		            </xsl:when>
		            <xsl:when test="count($matchingentries) gt 1">
		            	<xsl:message>Multiple matches for <xsl:value-of select="$uri"/></xsl:message>
		                <xsl:attribute name="key" select="$matchingentries[1]/@xml:id"/>
		            </xsl:when>
		        	<xsl:when test="count($matchingentries) eq 0">
		        		<xsl:message>No matches for <xsl:value-of select="$uri"/></xsl:message>
		        	</xsl:when>
		        </xsl:choose>
		    </xsl:if>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>