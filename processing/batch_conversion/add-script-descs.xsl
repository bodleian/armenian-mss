<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:saxon="http://saxon.sf.net/"
	exclude-result-prefixes="xs"
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

    <xsl:template match="tei:handNote[@script and string-length(normalize-space(string())) eq 0]">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@script != 'unknown'">
                    <xsl:apply-templates select="@*[not(local-name()='script')]"/>
                    <xsl:attribute name="script" select="lower-case(@script)"/>
                    <xsl:text>Written in </xsl:text>
                    <xsl:element name="ref" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="target">
                            <xsl:text>https://armenian.bodleian.ox.ac.uk/about#</xsl:text>
                            <xsl:value-of select="lower-case(@script)"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="@script = 'Erkatagir'">Erkat‘agir</xsl:when>
                            <xsl:when test="@script = 'Bolorgir'">Bolorgir</xsl:when>
                            <xsl:when test="@script = 'Notrgir'">Nōtrgir</xsl:when>
                            <xsl:when test="@script = 'Slagir'">Šłagir</xsl:when>
                            <xsl:otherwise><xsl:value-of select="@script"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:text> script</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*"/>
                    <xsl:text>Unknown script</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
	</xsl:template>

	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
    	
	<xsl:template match="@*|comment()|processing-instruction()">
		<xsl:copy/>
	</xsl:template>

</xsl:stylesheet>