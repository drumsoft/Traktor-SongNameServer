<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl = "http://www.w3.org/1999/XSL/Transform" version = "1.0" >
<xsl:template match = "/icestats" >

<status>
<xsl:for-each select="source">
	<source>
		<mountpoint><xsl:value-of select="@mount" /></mountpoint>
		<xsl:if test="artist">
		<artist><xsl:value-of select="artist" /></artist>
		</xsl:if>
		<xsl:if test="title">
		<title><xsl:value-of select="title" /></title>
		</xsl:if>
	</source>
</xsl:for-each>
</status>

</xsl:template>
</xsl:stylesheet>
