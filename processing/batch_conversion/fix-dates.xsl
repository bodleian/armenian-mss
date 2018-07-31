<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
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
    
    <xsl:template match="tei:origDate | tei:date[not(parent::tei:publicationStmt)]">
        <xsl:choose>
            <xsl:when test="text() = ('Gregorian','Armenian') and not(@when or @notBefore or @notAfter or @from or @to)">
                <!-- Remove placeholders -->
            </xsl:when>
            <xsl:when test="@calendar = '#Armenian'">
                <!-- The few manuscripts that have been catalogued with dates in the Armenian calendar have the 
                     Gregorian equivalent alongside, so no need to convert these -->
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="@calendar = '#Gregorian'">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:if test="not(@when or @notBefore or @notAfter or @from or @to)">
                        <xsl:variable name="textval" select="normalize-space(replace(replace(replace(text(), 'c\.', ''), 'circa\.?', ''), 'fl\.', ''))"/>
                        <!-- Normalize -->
                        <xsl:choose>
                            <xsl:when test="matches($textval, '^\d\d\d\d?\??$')">
                                <!-- A year -->
                                <xsl:attribute name="when" select="tokenize($textval, '\?')[1]"/>
                            </xsl:when>
                            <xsl:when test="matches($textval, '^\d\d\d\d?\-\d\d\d\d?$')">
                                <!-- A year range -->
                                <xsl:attribute name="from" select="tokenize($textval, '\-')[1]"/>
                                <xsl:attribute name="to" select="tokenize($textval, '\-')[2]"/>
                            </xsl:when>
                            <xsl:when test="matches($textval, '^\d\d\d\d?\??\-$')">
                                <!-- An open-ended year range -->
                                <xsl:attribute name="notBefore" select="tokenize($textval, '\D')[1]"/>
                            </xsl:when>
                            <xsl:when test="matches($textval, '\d(st|nd|rd|th)', 'i') and not(matches($textval, '(early|late|half)', 'i'))">
                                <!-- Centuries: Doesn't work for BCE dates, but there aren't any of those in Armenian -->
                                <xsl:variable name="centuries" as="xs:string*">
                                    <xsl:analyze-string select="$textval" regex="([\d/]+)(st|nd|rd|th)" flags="i">
                                        <xsl:matching-substring>
                                            <xsl:value-of select="regex-group(1)"/>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:variable>
                                <xsl:variable name="centuriesint" select="for $x in $centuries return for $y in tokenize($x, '/')[string-length(.) gt 0] return xs:integer($y)"/>
                                <xsl:variable name="earliestyear" select="(min($centuriesint) - 1) * 100"/>
                                <xsl:variable name="latestyear" select="max($centuriesint) * 100"/>
                                <xsl:attribute name="notBefore" select="string($earliestyear)"/>
                                <xsl:attribute name="notAfter" select="string($latestyear)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Multiple different date formats have been used, so for anything else just 
                                     create empty attributes to aid in manual fixing -->
                                <xsl:attribute name="when" select="''"/>
                                <xsl:attribute name="notBefore" select="''"/>
                                <xsl:attribute name="notAfter" select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!-- This shouldn't trigger in Armenian as all dates are marked up as either Gregorian or (rarely) Armenian -->
                <xsl:message>Date in unknown calendar</xsl:message>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()"><xsl:copy/></xsl:template>
    
</xsl:stylesheet>