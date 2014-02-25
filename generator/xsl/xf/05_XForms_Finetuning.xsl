<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:vra="http://www.vraweb.org/vracore4.htm"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:functx="http://www.functx.com"
                xmlns:xf="http://www.w3.org/2002/xforms"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:ev="http://www.w3.org/2001/xml-events"
                xmlns:bf="http://betterform.sourceforge.net/xforms"
                xmlns:bfc="http://betterform.sourceforge.net/xforms/controls"
                exclude-result-prefixes="functx xhtml">
    
    <xsl:output method="xhtml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="*|text()|comment()">
        <xsl:copy>
            <xsl:copy-of select ="@*|text()|comment()"/>
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>
    
        
    <!-- 
        ########## AgentSet ##########
    -->
    
    <!-- vocab + type -->    
    <xsl:template match="xhtml:tbody[@xf:repeat-nodeset eq 'vra:agent']//xf:select1[@ref = 'vra:role']">
        <xsl:copy>
            <xsl:copy-of select ="@*"/>
            <xsl:copy-of select ="xf:label|xf:hint|xf:help|xf:alert"/>
            <xf:action ev:event="xforms-value-changed">
                <xf:insert origin="instance('i-vraAttributes')/vra:vraElement[1]/@vocab"
                           context="instance('i-agentSet')/vra:agent[index('r-vraAgent')]/vra:role"
                           if="not(exists(instance('i-agentSet')/vra:agent[index('r-vraAgent')]/vra:role/@vocab))"></xf:insert>
                <xf:setvalue ref="instance('i-agentSet')/vra:agent[index('r-vraAgent')]/vra:role/@vocab" value="'marcrelator'"/>
                <xf:insert origin="instance('i-vraAttributes')/vra:vraElement[1]/@type"
                    context="instance('i-agentSet')/vra:agent[index('r-vraAgent')]/vra:role"
                    if="not(exists(instance('i-agentSet')/vra:agent[index('r-vraAgent')]/vra:role/@type))"></xf:insert>
                <xf:setvalue ref="instance('i-agentSet')/vra:agent[index('r-vraAgent')]/vra:role/@type" value="'code'"/>
            </xf:action>
            <xsl:copy-of select ="*|text()"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
        ########## DescriptionSet ##########
    -->
    
    <!--
    <xsl:template match="xf:bind[@nodeset eq 'instance()' and ../xf:instance[@id eq 'i-descriptionSet']]/xf:bind[@nodeset eq 'vra:description']/xf:bind[@nodeset eq '@type']" priority="50">
        <xf:bind nodeset="@type" calculate="if( boolean-from-string(instance('i-util')/states/stateOfPreservation[index('r-vraDescription')]) ) then ('stateOfPreservation') else (.)"/>
    </xsl:template> 
    
    <xsl:template match="xf:instance[@id eq 'i-util' and ../xf:instance[@id eq 'i-descriptionSet']]">   
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="*" mode="descriptionSet-util"/>
        </xsl:copy>
        <xf:bind nodeset="instance('i-util')/states">
            <xf:bind nodeset="stateOfPreservation" type="xf:boolean" calculate="boolean-from-string(.)"/>
        </xf:bind>
        <xf:action ev:event="xforms-model-construct-done" while="instance('i-util')/counter &lt;= count(instance()//vra:description)">
            <xf:insert model="m-child-model" nodeset="stateOfPreservation" origin="instance('i-util')/stateOfPreservation" context="instance('i-util')/states" position="after"></xf:insert>
            <xf:setvalue model="m-child-model" ref="instance('i-util')/states/stateOfPreservation[instance('i-util')/counter]" value="if(instance('i-descriptionSet')/vra:description[instance('i-util')/counter]/@type eq 'stateOfPreservation') then (true()) else (false())"/>
            <xf:setvalue model="m-child-model" ref="instance('i-util')/counter" value="instance('i-util')/counter +1"/>
        </xf:action>
    </xsl:template>
    
    <xsl:template match="*" mode="descriptionSet-util">
        <xsl:choose>
            <xsl:when test="name() eq 'currentElement'">
                <xsl:copy/>
                <counter xmlns="">1</counter>
                <stateOfPreservation xmlns="">false</stateOfPreservation>
                <states xmlns=""/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="*" mode="descriptionSet-util"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    
    <xsl:template match='xf:insert[@origin eq "instance(&apos;i-templates&apos;)/vra:description"]'>
        <xsl:copy-of select="."/>
        <xf:insert model="m-child-model" nodeset="stateOfPreservation" origin="instance('i-util')/stateOfPreservation" context="instance('i-util')/states" position="after"></xf:insert>    
    </xsl:template>
    
    <xsl:template match='xf:delete[@nodeset eq "instance(&apos;i-descriptionSet&apos;)/vra:description[index(&apos;r-vraDescription&apos;)]"]'>
        <xsl:copy-of select="."/>
        <xf:delete nodeset="instance('i-util')/states/stateOfPreservation[index('r-vraDescription')]"></xf:delete>
    </xsl:template>
    
    
    
    -->
    <xsl:template match="xhtml:tbody[@xf:repeat-nodeset eq 'vra:description']/xhtml:tr/xhtml:td[@class eq 'contentCol']/xf:group[@appearance eq 'minimal']/xf:input[@ref = '@type']">
        <xf:select1 ref="@type">
            <xf:label>Type</xf:label>
            <xf:item>
                <xf:label>State of preservation</xf:label>
                <xf:value>stateOfPreservation</xf:value>
            </xf:item>
        </xf:select1>
    </xsl:template>
    
    
    <!-- State of preservation -->
    
    <!-- i-descriptionSet -->
    <!--
    <xsl:template match="xf:bind[@nodeset eq 'instance()' and ../xf:instance[@id eq 'i-descriptionSet']]/xf:bind[@nodeset eq 'vra:description']/xf:bind[@nodeset eq '@type']">
        <xf:bind nodeset="@type" calculate="if( boolean-from-string(../@stateOfPreservation) ) then ('stateOfPreservation') else (.)"/>
        <xf:bind nodeset="@stateOfPreservation" type="xf:boolean"/>
    </xsl:template> 
    -->
    <!-- save -->
    <!--
    <xsl:template match="xf:submission[@id eq 's-update']/xf:action[@ev:event eq 'xforms-submit']"> 
        <xsl:copy-of select="."/>
        <xf:action ev:event="xforms-submit">
            <xf:setvalue model="m-child-model" ref="instance('i-util')/counter" value="1"/>
            <xf:action while="instance('i-util')/counter &lt;= count(instance('i-descriptionSet')//vra:description)">
                <xf:delete model="m-child-model" nodeset="instance('i-descriptionSet')/vra:description[instance('i-util')/counter]/@stateOfPreservation" if="exists(instance('i-descriptionSet')/vra:description[instance('i-util')/counter]/@stateOfPreservation)"></xf:delete>
                <xf:setvalue model="m-child-model" ref="instance('i-util')/counter" value="instance('i-util')/counter +1"/>
            </xf:action>    
        </xf:action>
    </xsl:template>  
    
    <xsl:template match="xf:submission[@id eq 's-update']/xf:action[@ev:event eq 'xforms-submit-done']"> 
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*"/>
            <xf:setvalue model="m-child-model" ref="instance('i-util')/counter" value="1"/>
            <xf:action while="instance('i-util')/counter &lt;= count(instance('i-descriptionSet')//vra:description)">
                <xf:insert model="m-child-model" origin="instance('i-util')/stateOfPreservation/@stateOfPreservation" context="instance('i-descriptionSet')/vra:description[instance('i-util')/counter]"/>
                <xf:setvalue model="m-child-model" ref="instance('i-descriptionSet')/vra:description[instance('i-util')/counter]/@stateOfPreservation" value="if(instance('i-descriptionSet')/vra:description[instance('i-util')/counter]/@type eq 'stateOfPreservation') then (true()) else (false())"/>
                <xf:setvalue model="m-child-model" ref="instance('i-util')/counter" value="instance('i-util')/counter +1"/>
            </xf:action>    
        </xsl:copy>
    </xsl:template>  
    
    <xsl:template match="xf:submission[@id eq 's-update']/xf:action[@ev:event eq 'xforms-submit-error']"> 
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*"/>
            <xf:setvalue model="m-child-model" ref="instance('i-util')/counter" value="1"/>
            <xf:action while="instance('i-util')/counter &lt;= count(instance('i-descriptionSet')//vra:description)">
                <xf:insert model="m-child-model" origin="instance('i-util')/stateOfPreservation/@stateOfPreservation" context="instance('i-descriptionSet')/vra:description[instance('i-util')/counter]"/>
                <xf:setvalue model="m-child-model" ref="instance('i-descriptionSet')/vra:description[instance('i-util')/counter]/@stateOfPreservation" value="if(instance('i-descriptionSet')/vra:description[instance('i-util')/counter]/@type eq 'stateOfPreservation') then (true()) else (false())"/>
                <xf:setvalue model="m-child-model" ref="instance('i-util')/counter" value="instance('i-util')/counter +1"/>
            </xf:action>    
        </xsl:copy>
    </xsl:template>
    -->
    
    <!-- i-util -->
    <!--
    <xsl:template match="xf:instance[@id eq 'i-util' and ../xf:instance[@id eq 'i-descriptionSet']]">   
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="*" mode="descriptionSet-util"/>
        </xsl:copy>
        <xf:action ev:event="xforms-ready" while="instance('i-util')/counter &lt;= count(instance('i-descriptionSet')//vra:description)">
            <xf:insert model="m-child-model" origin="instance('i-util')/stateOfPreservation/@stateOfPreservation" context="instance('i-descriptionSet')/vra:description[instance('i-util')/counter]" if="not(exists(instance('i-descriptionSet')/vra:description[instance('i-util')/counter]/@stateOfPreservation))"></xf:insert>
            <xf:setvalue model="m-child-model" ref="instance('i-descriptionSet')/vra:description[instance('i-util')/counter]/@stateOfPreservation" value="if(instance('i-descriptionSet')/vra:description[instance('i-util')/counter]/@type eq 'stateOfPreservation') then (true()) else (false())"/>
            <xf:setvalue model="m-child-model" ref="instance('i-util')/counter" value="instance('i-util')/counter +1"/>
        </xf:action>
    </xsl:template>
    
    <xsl:template match="*" mode="descriptionSet-util">
        <xsl:choose>
            <xsl:when test="name() eq 'currentElement'">
                <xsl:copy/>
                <counter xmlns="">1</counter>
                <stateOfPreservation xmlns="" stateOfPreservation="false"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="*" mode="descriptionSet-util"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    -->
    <!-- ADD -->
    <!--
    <xsl:template match='xf:insert[@origin eq "instance(&apos;i-templates&apos;)/vra:description"]'>
        <xsl:copy-of select="."/>
        <xf:insert model="m-child-model" origin="instance('i-util')/stateOfPreservation/@stateOfPreservation" context="instance()/vra:description[1]" if="not(exists(instance()/vra:description[1]/@stateOfPreservation))"></xf:insert>    
    </xsl:template>
    -->
    <!-- UI -->
    <!--
    <xsl:template match="xhtml:tbody[@xf:repeat-nodeset eq 'vra:description']/xhtml:tr/xhtml:td[@class eq 'contentCol']/xf:group[@appearance eq 'minimal']/xf:input[@ref = '@type']">
        <xf:input ref="@stateOfPreservation">
            <xf:label>State of preservation</xf:label>
            <xf:hint>State of preservation</xf:hint>
        </xf:input>
    </xsl:template>
    -->
    <!-- vocab + type -->
    <xsl:template match="xf:repeat[@ref eq 'vra:author']//xf:select1[@ref = 'vra:role']">
        <xsl:copy>
            <xsl:copy-of select ="@*"/>
            <xsl:copy-of select ="xf:label|xf:hint|xf:help|xf:alert"/>
            <xf:action ev:event="xforms-value-changed">
                <xf:insert origin="instance('i-vraAttributes')/vra:vraElement[1]/@vocab"
                    context="instance('i-descriptionSet')/vra:description[index('r-vraDescription')]/vra:author[index('r-author')]/vra:role"
                    if="not(exists(instance('i-descriptionSet')/vra:description[index('r-vraDescription')]/vra:author[index('r-author')]/vra:role/@vocab))"></xf:insert>
                <xf:setvalue ref="instance('i-descriptionSet')/vra:description[index('r-vraDescription')]/vra:author[index('r-author')]/vra:role/@vocab" value="'marcrelator'"/>
                <xf:insert origin="instance('i-vraAttributes')/vra:vraElement[1]/@type"
                    context="instance('i-descriptionSet')/vra:description[index('r-vraDescription')]/vra:author[index('r-author')]/vra:role"
                    if="not(exists(instance('i-descriptionSet')/vra:description[index('r-vraDescription')]/vra:author[index('r-author')]/vra:role/@type))"></xf:insert>
                <xf:setvalue ref="instance('i-descriptionSet')/vra:description[index('r-vraDescription')]/vra:author[index('r-author')]/vra:role/@type" value="'code'"/>
            </xf:action>
            <xsl:copy-of select ="*|text()"/>
        </xsl:copy>
    </xsl:template>
        
    <!-- 
        ########## SubjectSet ##########
    -->
    <xsl:template match="xhtml:tbody[@xf:repeat-nodeset eq 'vra:subject']//xf:select1[@ref = 'vra:term/@type']">
        <xsl:copy>
            <xsl:copy-of select ="@*"/>
            <xsl:copy-of select ="xf:label|xf:hint|xf:help|xf:alert"/>
            <xf:choices>
                <xf:label>Topics</xf:label>
                <xsl:copy-of select="xf:item[contains(xf:label, 'Topic')]"/>
            </xf:choices>
            <xf:choices>
                <xf:label>Places</xf:label>
                <xsl:copy-of select="xf:item[contains(xf:label, 'Place')]"/>
            </xf:choices>
            <xf:choices>
                <xf:label>Names</xf:label>
                <xsl:copy-of select="xf:item[contains(xf:label, 'Name')]"/>
            </xf:choices>
        </xsl:copy>
    </xsl:template>
    
    
    
    <!-- 
        ########## DateSet ##########
    -->
    <!--   
    <xsl:template match="xhtml:tbody[@xf:repeat-nodeset eq 'vra:date']/xhtml:tr/xhtml:td[@class eq 'contentCol']">
        <table>
            <tbody>
                <tr>
                    <td rowspan="2" class="date">
                        <xsl:copy-of select="xf:group[xf:select1[@ref eq '@type']]"/>
                    </td>
                    <td class="earliestDate">
                        <xf:label>Earliest Date</xf:label>
                        <xsl:apply-templates select="xf:group[xf:input[@ref eq 'vra:earliestDate/vra:date']]"/> 
                    </td>
                </tr>
                <tr>
                    <td class="latestDate">
                        <xf:label>Latest Date</xf:label>
                        <xsl:apply-templates select="xf:group[xf:input[@ref eq 'vra:latestDate/vra:date']]"/> 
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:template>
    
    <xsl:template match="xf:input[@ref eq 'vra:earliestDate/vra:date']">
    
    </xsl:template>
    
    <xsl:template match="xf:input[@ref eq 'vra:latestDate/vra:date']">
    
    </xsl:template>
    
    -->
</xsl:stylesheet>