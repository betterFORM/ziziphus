<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.vraweb.org/vracore4.htm"
                xmlns:vra="http://www.vraweb.org/vracore4.htm"
                xmlns:xforms="http://www.w3.org/2002/xforms"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xpath-default-namespace= "http://www.vraweb.org/vracore4.htm">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    <xsl:strip-space elements="*"/>



    <!--
        ########################################################################################
            EXTERNAL PARAMETERS
        ########################################################################################
    -->
    <xsl:param name="debug" select="'TAKEN_FROM_BUILD.XML'" as="xsd:string"/>

    <!--
        ########################################################################################
            GLOBAL VARIABLES
        ########################################################################################
    -->

    <xsl:variable name="debugEnabled" as="xsd:boolean">
        <xsl:choose>
            <xsl:when test="$debug eq 'true' or $debug eq 'true()' or number($debug) gt 0">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- helper variable to generate a valid instance -->
    <xsl:variable name="imageId" select="generate-id()"/>
    <!--
        ########################################################################################
            TEMPLATE RULES
        ########################################################################################
    -->

    <!-- handle xsd:sequence -->
    <xsl:template match="xsd:schema">
        <xsl:apply-templates select="xsd:element[@name='vra']"/>
    </xsl:template>


    <xsl:template match="xsd:element">
        <xsl:if test="$debugEnabled">
            <xsl:message>create element '<xsl:value-of  select="@name"/>' with [type='<xsl:value-of  select="@type"/>', maxOccurs='<xsl:value-of  select="@maxOccurs"/>',  minOccurs='<xsl:value-of  select="@minOccurs"/>']</xsl:message>
        </xsl:if>


        <xsl:element name="{@name}" namespace="http://www.vraweb.org/vracore4.htm">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="xsd:element[xsd:complexType/xsd:sequence]">

        <xsl:if test="$debugEnabled">
            <xsl:message>create complex element with sequence'<xsl:value-of  select="@name"/>' with [type='<xsl:value-of  select="@type"/>', maxOccurs='<xsl:value-of  select="@maxOccurs"/>',  minOccurs='<xsl:value-of  select="@minOccurs"/>']</xsl:message>
        </xsl:if>


        <xsl:element name="{@name}" namespace="http://www.vraweb.org/vracore4.htm">
            <xsl:for-each select="xsd:complexType/xsd:attribute">
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="xsd:complexType/xsd:sequence"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="xsd:element[xsd:complexType/xsd:all]">

        <xsl:if test="$debugEnabled">
            <xsl:message>create complex element with all'<xsl:value-of  select="@name"/>' with [type='<xsl:value-of  select="@type"/>', maxOccurs='<xsl:value-of  select="@maxOccurs"/>',  minOccurs='<xsl:value-of  select="@minOccurs"/>']</xsl:message>
        </xsl:if>


        <xsl:element name="{@name}" namespace="http://www.vraweb.org/vracore4.htm">
            <xsl:for-each select="xsd:complexType/xsd:attribute">
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="xsd:complexType/xsd:all"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="xsd:element[xsd:complexType/xsd:simpleContent/xsd:extension]">

        <xsl:if test="$debugEnabled">
            <xsl:message>create simple element '<xsl:value-of  select="@name"/>' with [type='<xsl:value-of  select="@type"/>', maxOccurs='<xsl:value-of  select="@maxOccurs"/>',  minOccurs='<xsl:value-of  select="@minOccurs"/>']</xsl:message>
        </xsl:if>

        <xsl:element name="{@name}" namespace="http://www.vraweb.org/vracore4.htm">
            <xsl:variable name="extension" select="xsd:complexType/xsd:simpleContent/xsd:extension"/>
            <!--<xsl:attribute name="type" select="$extension/@base"/>-->
            <xsl:for-each select="$extension/*">
                <xsl:choose>
                    <xsl:when test="local-name(.) eq 'attribute'">
                        <xsl:apply-templates select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes">extension with other child element than attribute</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>



    <xsl:template match="xsd:attribute">
        <xsl:if test="$debugEnabled">
            <xsl:message>create attribute [name: '<xsl:value-of  select="@name"/>' , type: '<xsl:value-of  select="@type"/>', ref: '<xsl:value-of  select="@ref"/>']</xsl:message>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="exists(@name)">
                <xsl:choose>
                    <xsl:when test="@name eq 'pref' or @name eq 'circa'">
                        <xsl:attribute name="{@name}">false</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="@name eq 'dataDate'">
                        <xsl:attribute name="dataDate"></xsl:attribute>
                    </xsl:when>
                    <xsl:when test="@name eq 'id'">
                        <xsl:attribute name="id" select="generate-id(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{@name}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@ref='xml:lang'">
                <xsl:attribute name="xml:lang"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Error creating attribute</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="xsd:element[@name='vra']/xsd:complexType/xsd:sequence/xsd:element[@name='image']" priority="30">
        <xsl:if test="$debugEnabled">
            <xsl:message>create (root) image element [name: '<xsl:value-of  select="@name"/>' , type: '<xsl:value-of  select="@type"/>', ref: '<xsl:value-of  select="@ref"/>']</xsl:message>
        </xsl:if>

        <xsl:element name="image" namespace="http://www.vraweb.org/vracore4.htm">
            <xsl:attribute name="id" select="$imageId"/>
            <xsl:for-each select="xsd:complexType/xsd:attribute[@name ne 'id']">
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="xsd:complexType/xsd:sequence"/>
        </xsl:element>
    </xsl:template>

    <!-- handle xsd:complexType-->
    <xsl:template match="xsd:complexType">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- handle xsd:sequence -->
    <xsl:template match="xsd:sequence">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="xsd:all">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="xsd:annotation"/>
    <xsl:template match="xsd:include"/>

    <!--
        ########################################################################################
            HELPER TEMPLATE RULES (simply copying nodes and comments)
        ########################################################################################
    -->

    <xsl:template match="*|@*|text()">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="*|@*|text()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="comment()" priority="20">
        <xsl:copy/>
    </xsl:template>

</xsl:stylesheet>