<xsl:stylesheet exclude-result-prefixes="bfn" version="2.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:bfc="http://betterform.sourceforge.net/xforms/controls"
    xmlns:bfn="http://www.betterform.de/XSL/Functions"
    xmlns:ev="http://www.w3.org/2001/xml-events"
    xmlns:vra="http://www.vraweb.org/vracore4.htm"
    xmlns:xf="http://www.w3.org/2002/xforms"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.w3.org/2002/xforms">
    <xsl:output encoding="UTF-8" indent="yes" method="xhtml"
        omit-xml-declaration="no" version="1.0"/>
    <xsl:strip-space elements="*"/>
    <!-- 'work' or 'image' -->
    <xsl:param name="recordType" select="'GIVEN BY CALLER'"/>
    <!-- UUID of Record e.g w_****** -->
    <xsl:param name="recordId" select="'GIVEN BY CALLER'"/>
    <!-- URI to codetables  -->
    <xsl:param name="codetables-uri" select="'GIVEN BY CALLER'"/>
    <xsl:param name="resources-uri" select="'GIVEN BY CALLER'"/>
    <xsl:param name="lang" select="'GIVEN BY CALLER'"/>
    <!-- cluster || vra -->
    <xsl:param name="schema" select="'GIVEN BY CALLER'"/>
    <!--<xsl:variable name="root_id" select="if($type='work') then 'workrecord' else 'imagerecord'"/>-->
    <xsl:variable name="title" select="if($recordType='work') then 'Work Record' else 'Image Record'"/>
    <xsl:variable name="id_pref" select="if($recordType='work') then 'w_' else 'i_'"/>
    <!-- code-tables and legends -->
    <xsl:variable name="role-codes-legend" select="document(concat($codetables-uri, 'legends/role-codes-legend.xml'))"/>
    <xsl:variable name="language-3-type-codes" select="document(concat($codetables-uri, 'language-3-type-codes.xml'))"/>
    <xsl:variable name="language-files" select="document(concat($resources-uri, 'lang_' , $lang, '.xml'))"/>
    <!-- parameter is only used if a single section is rendered -->
    <xsl:param name="setname" select="''"/>
    <!--
        VIEW GENERATION - includes embed actions for switching to forms
    -->
    <!--<xsl:variable name="rootPath" select="'vraSets'"/>-->
    <!-- include transforms for sections in VRA dataset -->
    <xsl:include href="../../view/AgentSet.xsl"/>
    <xsl:include href="../../view/CulturalContextSet.xsl"/>
    <xsl:include href="../../view/DateSet.xsl"/>
    <xsl:include href="../../view/DescriptionSet.xsl"/>
    <xsl:include href="../../view/InscriptionSet.xsl"/>
    <xsl:include href="../../view/LocationSet.xsl"/>
    <xsl:include href="../../view/MaterialSet.xsl"/>
    <xsl:include href="../../view/MeasurementsSet.xsl"/>
    <xsl:include href="../../view/RelationSet.xsl"/>
    <xsl:include href="../../view/RightsSet.xsl"/>
    <xsl:include href="../../view/SourceSet.xsl"/>
    <xsl:include href="../../view/StateEditionSet.xsl"/>
    <xsl:include href="../../view/StylePeriodSet.xsl"/>
    <xsl:include href="../../view/SubjectSet.xsl"/>
    <xsl:include href="../../view/TechniqueSet.xsl"/>
    <xsl:include href="../../view/TextrefSet.xsl"/>
    <xsl:include href="../../view/TitleSet.xsl"/>
    <xsl:include href="../../view/WorktypeSet.xsl"/>
    <!-- top level - entry template - handles a work or an image record -->
    <xsl:include href="vraSectionTemplate.xsl"/>
    <xsl:template match="vra:work/vra:image" mode="titlePane" priority="40"/>
    <!--
        single section - expandable section in view. Uses a XForms switch to toggle between VIEW and EDIT mode
    -->
    <xsl:template name="titlePane">
        <xsl:param name="vraSetName"/>
        <xsl:param as="node()?" name="vraSetNode"/>
        <xsl:param name="visible"/>
        <!--<xsl:variable name="schema" select="'cluster'"/>-->
        <xsl:variable name="title" select="bfn:sectionTitle($vraSetName)"/>
        <xsl:variable name="id" select="concat($id_pref,$title)"/>
        <!--<xsl:variable name="formName" select="$vraSetName"/>-->
        <xsl:variable name="sectionWithData" select="if(string-length(string-join($vraSetNode//*/text(),'')) != 0) then 'true' else 'false'"/>
        <div data-dojo-props="title: '{$title}',open:{$sectionWithData}"
            data-dojo-type="dijit.TitlePane" id="{$id}">
            <xsl:if test="$visible='false'">
                <xsl:attribute name="class">hidden</xsl:attribute>
            </xsl:if>
            <xsl:variable name="mountPoint" select="concat($id,'_MountPoint')"/>
            <xsl:variable name="caseId" select="concat('c-',$id)"/>
            <xsl:variable name="tableId" select="concat('table-',$id)"/>
            <div class="t-edit">
                <xf:group id="handler-{$id}" style="display: none;">
                    <xf:action ev:event="load-form">
                        <xf:dispatch name="unload-subform" targetid="controlCenter"/>
                        <xf:setvalue model="m-main"
                            ref="instance('i-control-center')/currentform" value="'{$id}'"/>
                        <xf:setvalue model="m-main"
                            ref="instance('i-control-center')/uuid" value="'{$recordId}'"/>
                        <!--<xf:setvalue model="m-main" ref="instance('i-control-center')/recordType" value="'{$recordType}'"/>-->
                        <xf:load show="embed" targetid="{$mountPoint}">
                            <xf:resource value="'forms/{$schema}/{$vraSetName}.xhtml#xforms'"/>
                            <!-- new extension for load to be added -> if returnUI="false" this means that the subform is embedded and initialized on the server
                            but no UI transformation takes place and therefore no UI is returned via the embed event. -->
                            <xf:extension includeCSS="true"
                                includeScript="false" returnUI="false"/>
                        </xf:load>
                        <!--
                        This is not used for the time being. It was a test to use xquery to generate the
                        forms which might get interesting later again when it comes to optimization e.g.
                        the data instances can probably be inlined within the forms when requesting the form
                        thus avoiding additional submissions to load the data. This *might* improve overall
                        performance.

                         <xf:load show="embed" targetid="{$mountPoint}">
                            <xf:resource value="'modules/forms/{$schema}/{$vraSetName}.xql#xforms?recordId={$recordId}'"/>
                            <xf:extension includeCSS="false" includeScript="false"/>
                        </xf:load>
                        -->
                        <script
                            type="text/javascript">
                            $('.editHighlight').removeClass('editHighlight');
                            $('#'+ '<xsl:value-of select="$id"/>' + ' &gt; .dijitTitlePaneTitle').addClass('editHighlight');</script>
                        <xf:toggle case="{$caseId}-edit"/>
                    </xf:action>
                </xf:group>
                <xf:trigger class="button-edit -toolbarbutton">
                    <xf:label/>
                    <xf:hint>edit</xf:hint>
                    <!-- prevent subform from loading twice (when already in edit mode) -->
                    <xf:action if="instance('i-control-center')/currentform != '{$id}' and instance('i-control-center')/isDirty='false'">
                        <xf:dispatch name="load-form" targetid="handler-{$id}"/>
                    </xf:action>
                    <!-- this fires whe,open:{$sectionWithData}n one subform has been changed and another is requested for editing -->
                    <xf:action if="instance('i-control-center')/currentform != '{$id}' and instance('i-control-center')/isDirty='true'">
                        <script
                            type="text/javascript">editOtherForm('handler-<xsl:value-of select="$id"/>');</script>
                    </xf:action>
                </xf:trigger>
                <span>
                    <!--<button type="button" onclick="toggleDetail(this, '{$tableId}');" class="icon icon-zoom-in"/>-->
                    <button class="toolbarbutton button-zoom-in"
                            onclick="toggleDetail(this, '{concat($id,'_HtmlContent')}');"
                            title="view details" type="button"/>
                </span>
            </div>
            <xf:switch>
                <!-- ############ VIEW CASE ######### -->
                <!-- ############ VIEW CASE ######### -->
                <!-- ############ VIEW CASE ######### -->
                <xf:case class="view" id="{$caseId}-view" selected="true">
                    <xf:action ev:event="xforms-select">
                        <script type="text/javascript">
                            $('.editHighlight').removeClass('editHighlight');

                        </script>
                    </xf:action>
                    <div class="vraSection simple"
                         data-bf-form="/db/apps/ziziphus/forms/{$schema}/{$vraSetName}.xhtml" id="{concat($id,'_HtmlContent')}">
                        <!-- all markup within this div must be generated by the specific Subforms stylesheets, e.q. AgentSet.xsl -->
                        <xsl:choose>
                            <xsl:when test="exists($vraSetNode/vra:display/text())">
                                <xsl:apply-templates select="$vraSetNode/vra:display"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- drill down into single stylesheets (the ones include at top of this file.-->
                                <xsl:apply-templates select="$vraSetNode">
                                    <xsl:with-param name="vraTableId" select="$tableId"/>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="$vraSetNode/vra:notes"/>
                    </div>
                </xf:case>
                <!-- ############ EDIT CASE ############### -->
                <!-- ############ EDIT CASE ############### -->
                <!-- ############ EDIT CASE #######vraSetName######## -->
                <xf:case class="edit" id="{$caseId}-edit">
                    <xf:action ev:event="xforms-select">
                        <script
                            type="text/javascript">scrollToPanel('<xsl:value-of select="$id"/>');</script>
                    </xf:action>
                    <div id="{$mountPoint}"/>
                </xf:case>
            </xf:switch>
        </div>
    </xsl:template>
    <!--    <xsl:template match="*[exists(*)]"  priority="20">
            <xsl:variable name="nodeName" select="local-name(.)"/>
            <div class="{$nodeName}">
                <div class="{$nodeName}Label complexLabel">
                    <xsl:value-of select="bfn:upperCase($nodeName)"/>:</div>
                <div class="attrEntry">
                    <xsl:apply-templates select="@*" />
                </div>
                <xsl:apply-templates select="*" />
            </div>
        </xsl:template>
    -->
    <xsl:template match="*[not(exists(*))]" priority="10">
        <xsl:choose>
            <xsl:when test="string-length(.) gt 0">
                <xsl:variable name="nodeName" select="local-name(.)"/>
                <div class="nodeEntry">
                    <span class="{$nodeName}Label simpleLabel">
                        <xsl:value-of select="bfn:upperCase($nodeName)"/>:</span>
                    <span class="{$nodeName}Value simpleValue">
                        <xsl:value-of select="normalize-space(.)"/>
                    </span>
                    <div class="attrEntry">
                        <xsl:apply-templates select="@*"/>
                    </div>
                </div>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="@*">
        <xsl:choose>
            <xsl:when test="string-length(.) gt 0">
                <xsl:variable name="attrName" select="local-name(.)"/>
                <span class="{$attrName}Label attrLabel">
                    <xsl:value-of select="$attrName"/>:</span>
                <span class="{$attrName}Value attrValue">
                    <xsl:value-of select="normalize-space(.)"/>
                </span>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*"/>
    <xsl:template match="@*|text()" priority="5"/>
    <xsl:template match="comment()" priority="5"/>
    <xsl:function as="xsd:string?" name="bfn:sectionTitle">
        <xsl:param as="xsd:string?" name="arg"/>
        <xsl:sequence select="substring-before(bfn:upperCase($arg),'Set')"/>
    </xsl:function>
    <xsl:function as="xsd:string?" name="bfn:upperCase">
        <xsl:param as="xsd:string?" name="arg"/>
        <xsl:sequence select="concat(upper-case(substring($arg,1,1)),substring($arg,2))"/>
    </xsl:function>
    <xsl:template name="renderVraAttr">
        <xsl:param name="attrName"/>
        <xsl:param name="mode">inline</xsl:param>
        <xsl:param name="ifAbsent"/>
        <xsl:choose>
            <xsl:when test="@*[name()=$attrName]">
                <xsl:choose>
                    <xsl:when test="'inline'=$mode">
                        <span class="vraAttr">
                            <span class="vraAttrName">
                                <xsl:value-of select="$attrName"/>
                            </span>
                            <span class="vraAttrValue">
                                <xsl:value-of select="@*[name()=$attrName]"/>
                            </span>
                        </span>
                    </xsl:when>
                    <xsl:when test="'simple'=$mode">
                        <xsl:value-of select="@*[name()=$attrName]"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$ifAbsent"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="vra:display" priority="40">
        <xsl:if test="text()">
            <div class="display-container" property="{name()}">
                <xsl:value-of select="text()"/>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="vra:notes" priority="40">
        <xsl:if test="text()">
            <div class="notes-container detail">
                <span class="notes" property="{name()}">
                    <xsl:value-of select="text()"/>
                </span>
            </div>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
