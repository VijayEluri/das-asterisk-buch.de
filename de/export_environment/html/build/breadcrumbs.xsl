<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:d="http://docbook.org/ns/docbook" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" exclude-result-prefixes="exsl d" version="1.0">
	<xsl:template name="breadcrumbs">
		<xsl:param name="this.node" select="."/>
		<ul class="breadcrumbs">
			<xsl:for-each select="$this.node/ancestor::*">
				<xsl:variable name="node.is.component">
					<xsl:call-template name="is.component">
						<xsl:with-param name="node" select="."/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="this.is.component">
					<xsl:call-template name="is.component">
						<xsl:with-param name="node" select="$this.node"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="$node.is.component != 0 or count(ancestor-or-self::*) = 2">
					<xsl:call-template name="print-previous-components">
						<xsl:with-param name="context" select="$this.node"/>
						<xsl:with-param name="temp-name" select="'print-previous-main-loop-first'"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:call-template name="breadcrumb.href.target">
					<xsl:with-param name="context" select="$this.node"/>
					<xsl:with-param name="temp-name" select="'breadcrumb-first-level'"/>
				</xsl:call-template>
				<xsl:if test="position() = last()">
					<!-- If the selected node is a component or a level2 link, print its previous siblings-->
					<xsl:if test="$this.is.component != 0 or count($this.node/ancestor-or-self::*) = 2">
						<xsl:call-template name="print-previous-components">
							<xsl:with-param name="context" select="$this.node"/>
							<xsl:with-param name="node" select="$this.node"/>
							<xsl:with-param name="temp-name" select="'print-previous-main-loop-second'"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="main-breadcrumb-plus-neighbours">
						<xsl:with-param name="node" select="$this.node"/>
						<xsl:with-param name="context" select="$this.node"/>
					</xsl:call-template>
					<!-- If the selected node is not a component or a level2 link, 
						print all the components or level 2 links which are following siblings of its ancestor-->
					<xsl:if test="$node.is.component != 0 or $this.is.component != 0 or count($this.node/ancestor-or-self::*) = 2">
						<xsl:call-template name="print-following-components">
							<xsl:with-param name="context" select="$this.node"/>
							<xsl:with-param name="node" select="$this.node"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="count($this.node/ancestor::*) = 0">
				<li class="breadcrumb-text highlight indexpage">
					<xsl:apply-templates select="$this.node" mode="title.markup"/>
				</li>
				<xsl:for-each select="$this.node/child::*[local-name() != 'bookinfo' and local-name() != 'info' and local-name() != 'articleinfo']">
					<xsl:call-template name="breadcrumb.href.target">
						<xsl:with-param name="object" select="."/>
						<xsl:with-param name="context" select="$this.node"/>
						<xsl:with-param name="temp-name" select="'indexchild'"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
		</ul>
	</xsl:template>
	
	<xsl:template name="print-following-components">
		<xsl:param name="node" select="."/>
		<xsl:param name="context" select="."/>
		<xsl:param name="temp-name" select="'pfc'"/>
		<xsl:for-each select="$node/ancestor-or-self::*">
			<!-- reversing the node set -->
			<xsl:sort select="position()" data-type="number" order="descending"/>
				<xsl:for-each select="following-sibling::*">	
					<xsl:call-template name="breadcrumb.href.target">
						<xsl:with-param name="object" select="."/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="temp-name" select="$temp-name"/>
					</xsl:call-template>
				</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="print-previous-components">
		<xsl:param name="node" select="."/>
		<xsl:param name="context" select="."/>
		<xsl:param name="temp-name" select="'ppc'"/>
		<xsl:for-each select="$node/preceding-sibling::*">
			<xsl:if test="local-name(.) != 'info' and local-name(.) != 'bookinfo' and local-name() != 'articleinfo'">
				<xsl:call-template name="breadcrumb.href.target">
					<xsl:with-param name="object" select="."/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="temp-name" select="$temp-name"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="main-breadcrumb-plus-neighbours">
	<!--<xsl:param name="node" select="."/>-->
	<!--<xsl:param name="context" select="."/>-->
		<xsl:param name="node"/>
		<xsl:param name="context"/>
<!-- And display the current node, but not as a link -->
		<xsl:variable name="node.is.component">
			<xsl:call-template name="is.component">
				<xsl:with-param name="node" select="$node"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$node.is.component = 0 and count($node/ancestor-or-self::*) > 2">
			<xsl:call-template name="print-previous-components">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="node" select="$node"/>
				<xsl:with-param name="temp-name" select="'print-previous-main-breadcrumb-preceding'"/>
			</xsl:call-template>
		</xsl:if>	
		<xsl:call-template name="breadcrumb.href.target">
			<xsl:with-param name="object" select="$node"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="temp-name" select="'main-breadcrumb'"/>
		</xsl:call-template>

		<xsl:for-each select="$node/child::*[position() != 1]">
			<xsl:call-template name="breadcrumb.href.target">
				<xsl:with-param name="context" select="$node"/>
				<xsl:with-param name="temp-name" select="'main-breadcrumb-link'"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="breadcrumb.href.target">
		<xsl:param name="object" select="."/>
		<xsl:param name="context" select="."/>
		<xsl:param name="temp-name" select="'bhf'"/>
		<xsl:if test="$object/child::*[local-name() = 'title'] or $object/info/child::*[local-name() = 'title'] or local-name($object) = 'set' or local-name($object) = 'partintro' or local-name($object) = 'book' or local-name($object) = 'article' or local-name($object) = 'index'">
			<li>
				<xsl:attribute name="class">
					<xsl:call-template name="breadcrumb-classes">
						<xsl:with-param name="node" select="$object"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="temp-name" select="$temp-name"/>
					</xsl:call-template>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="$object = $context">
						<xsl:apply-templates select="$object" mode="title.markup"/>
					</xsl:when>
					<xsl:otherwise>
						<a>
							<xsl:attribute name="href">
								<xsl:call-template name="href.target">
									<xsl:with-param name="object" select="$object"/>
									<xsl:with-param name="context" select="$context"/>
								</xsl:call-template>
							</xsl:attribute>
							<xsl:attribute name="title">
								<xsl:call-template name="breadcrumb-classes">
									<xsl:with-param name="node" select="$object"/>
									<xsl:with-param name="context" select="$context"/>
									<xsl:with-param name="temp-name" select="$temp-name"/>
								</xsl:call-template>
							</xsl:attribute>
							<xsl:apply-templates select="$object" mode="title.markup"/>
						</a>
					</xsl:otherwise>
				</xsl:choose>
			</li>
		</xsl:if>
	</xsl:template>

	<xsl:template name="breadcrumb-classes">
		<xsl:param name="node" select="."/>
		<xsl:param name="context" select="."/>
		<xsl:param name="temp-name">
			<xsl:text></xsl:text>
		</xsl:param>
		<xsl:value-of select="$temp-name"/>
		<xsl:text> level</xsl:text>
		<xsl:value-of select="count($node/ancestor-or-self::*)"/>
		<xsl:text> breadcrumb-link </xsl:text>
		<xsl:value-of select="local-name($node)"/>
		<xsl:if test="$node = $context">
			<xsl:text> highlight </xsl:text>	
		</xsl:if>
		<xsl:variable name="node.is.section">
			<xsl:call-template name="is.section">
				<xsl:with-param name="node" select="$node"/>
			</xsl:call-template>
		</xsl:variable>						
		<xsl:if test="$node.is.section != 0">
			<xsl:variable name="sectionlevel">
				<xsl:text> sectlevel</xsl:text>
				<xsl:call-template name="section.level">
					<xsl:with-param name="node" select="$node"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="$sectionlevel"/>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
