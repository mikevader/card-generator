<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:key name="traitRef" match="traits/trait[not(ancestor::monster)]" use="@id" />

  <xsl:param name="rows" select="2" />
  <xsl:param name="cols" select="2" />
  <xsl:variable name="pageSize" select="$rows * $cols" />
  <xsl:variable name="pageFormat" select="'A6'" />

  <xsl:include href="template.xsl"/>

  <xsl:template match="monster" mode="front">
    <div class="card monster card-{(count(preceding-sibling::monster) mod $pageSize) + 1}">
      <xsl:apply-templates select="*[@side = 'front'] | *[not(@side = 'back')]" />
<!--       <xsl:apply-templates select="traits"/>
      <xsl:apply-templates select="actions"/>
      <xsl:apply-templates select="description"/>
 -->    
    </div>
  </xsl:template>

  <xsl:template match="monster" mode="back">
    <div class="card monster cardb-{(count(preceding-sibling::monster) mod $pageSize) + 1}">
      <xsl:apply-templates select="name" />

      <xsl:apply-templates select="*[@side = 'back'] | *[@side = 'both']" />
    </div>
  </xsl:template>

  <xsl:template match="type">
    <div class="type"><xsl:value-of select="." /></div>
  </xsl:template>

  <xsl:template match="cite">
    <div class="cite"><xsl:value-of select="." /></div>
  </xsl:template>

  <xsl:template match="stats">
    <xsl:variable name="pb" select="proficiency" />
    <div class="stats">
      <div class="stat">
        <div class="title">Armor Class</div>
        <div class="value"><xsl:value-of select="ac"/></div>
      </div>
      <div class="stat">
        <div class="title">Hip Points</div>
        <div class="value"><xsl:value-of select="hp"/></div>
      </div>
      <div class="stat">
        <div class="title">Speed</div>
        <div class="value"><xsl:value-of select="speed"/></div>
      </div>
      <xsl:apply-templates select="abilities"/>
      <xsl:apply-templates select="savingThrows">
        <xsl:with-param name="pb" select="$pb"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="skills">
        <xsl:with-param name="pb" select="$pb"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="dmgVulnerability"/>
      <xsl:apply-templates select="dmgResistance"/>
      <xsl:apply-templates select="dmgImmunity"/>
      <xsl:apply-templates select="condImmunity"/>
      <xsl:apply-templates select="senses">
        <xsl:with-param name="pb" select="$pb"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="cr"/>
    </div>
  </xsl:template>

  <xsl:template match="abilities">
    <div class="abilities">
      <xsl:for-each select="@*">
        <div class="ability">
          <xsl:variable name="modifier" select="floor((. - 10) div 2)" />
          <div class="title"><xsl:value-of select="name()"/></div>
          <div class="value"><xsl:value-of select="."/>
          <xsl:if test="$modifier &gt;= 0">
            (+<xsl:value-of select="$modifier"/>)
          </xsl:if>
          <xsl:if test="$modifier &lt; 0">
            (<xsl:value-of select="$modifier"/>)
          </xsl:if>
          </div>
        </div>
      </xsl:for-each>
      <span class="stretch"></span>
    </div>
  </xsl:template>

  <xsl:template match="savingThrows">
    <xsl:param name="pb" />
    <div class="savingThrows">
      <div class="title">Saving throws</div>
      <xsl:for-each select="@*">
        <xsl:variable name="attName" select="name()" />
        <xsl:variable name="modifier" select="floor((../preceding-sibling::abilities/@*[name()=$attName] - 10) div 2) + $pb" />
        <div class="ability">
          <div class="title"><xsl:value-of select="name()"/></div>
          <div class="value">+<xsl:value-of select="$modifier"/></div>
        </div>
      </xsl:for-each>
      <span class="stretch"></span>
    </div>
  </xsl:template>

  <xsl:template match="skills">
    <xsl:param name="pb" />
    <div class="list">
      <div class="title">Skills</div>
      <xsl:apply-templates select="skill">
        <xsl:with-param name="pb" select="$pb"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  <xsl:template match="skill">
    <xsl:param name="pb" />
    <xsl:variable name="attName">
      <xsl:choose>
        <xsl:when test="@name = 'Athletics'">str</xsl:when>
        <xsl:when test="@name = 'Acrobatics'">dex</xsl:when>
        <xsl:when test="@name = 'Sleight of Hand'">dex</xsl:when>
        <xsl:when test="@name = 'Stealth'">dex</xsl:when>
        <xsl:when test="@name = 'Arcana'">int</xsl:when>
        <xsl:when test="@name = 'History'">int</xsl:when>
        <xsl:when test="@name = 'Investigation'">int</xsl:when>
        <xsl:when test="@name = 'Nature'">int</xsl:when>
        <xsl:when test="@name = 'Religion'">int</xsl:when>
        <xsl:when test="@name = 'Animal Handling'">wis</xsl:when>
        <xsl:when test="@name = 'Insight'">wis</xsl:when>
        <xsl:when test="@name = 'Medicine'">wis</xsl:when>
        <xsl:when test="@name = 'Perception'">wis</xsl:when>
        <xsl:when test="@name = 'Survival'">wis</xsl:when>
        <xsl:when test="@name = 'Deception'">cha</xsl:when>
        <xsl:when test="@name = 'Intimidation'">cha</xsl:when>
        <xsl:when test="@name = 'Performance'">cha</xsl:when>
        <xsl:when test="@name = 'Persuasion'">cha</xsl:when>
        <xsl:otherwise><xsl:value-of select="@att"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="modifier">
      <xsl:choose>
        <xsl:when test="current() = ''"><xsl:value-of select="floor((../preceding-sibling::abilities/@*[name()=$attName] - 10) div 2) + $pb" /></xsl:when>
        <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="listElement">
      <div class="title"><xsl:value-of select="@name"/></div>
      <div class="value">+<xsl:value-of select="$modifier"/></div>
    </div>
  </xsl:template>

  <xsl:template match="dmgVulnerability">
    <xsl:call-template name="damageType">
      <xsl:with-param name="title">Vulnerable</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="dmgResistance">
    <xsl:call-template name="damageType">
      <xsl:with-param name="title">Resistance</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="dmgImmunity">
    <xsl:call-template name="damageType">
      <xsl:with-param name="title">Immune</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="condImmunity">
    <xsl:call-template name="damageType">
      <xsl:with-param name="title">Cond Immune</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="damageType">
    <xsl:param name="title"/>
    <div class="list vertical">
      <div class="title"><xsl:value-of select="$title"/></div>
      <xsl:for-each select="*">
        <div class="listElement"><xsl:value-of select="name()"/></div>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="senses">
    <xsl:param name="pb" />
    <xsl:variable name="wisModifier" select="floor((preceding-sibling::abilities/@wis - 10) div 2)" />
    <div class="list">
      <div class="title">Senses</div>
      <xsl:apply-templates select="sense"/>
      <div class="listElement">
        <div class="title">passive Perception</div>
        <xsl:choose>
          <xsl:when test="preceding-sibling::skills/skill[@name = 'Perception']">
            <div class="value"><xsl:value-of select="10 + $wisModifier + $pb"/></div>
          </xsl:when>
          <xsl:otherwise>
            <div class="value"><xsl:value-of select="10 + $wisModifier"/></div>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>
  <xsl:template match="sense">
    <div class="listElement">
      <div class="title"><xsl:value-of select="@name"/></div>
      <div class="value"><xsl:value-of select="."/></div>
    </div>
  </xsl:template>

  <xsl:template match="cr">
    <div class="stat">
      <div class="title">Challenge</div>
      <div><xsl:value-of select="."/></div>
    </div>
  </xsl:template>

  <xsl:template match="traits">
    <div class="bulletlist">
      <xsl:apply-templates select="trait"/>
    </div>
  </xsl:template>

  <xsl:template match="actions">
    <div class="bulletlist">
      <div class="title">
        <xsl:if test="not(@title)">
          Actions
        </xsl:if>
        <xsl:value-of select="@title"/>
      </div>
      <xsl:apply-templates select="action | meleeWeaponAttack | rangedWeaponAttack"/>
    </div>
  </xsl:template>

  <xsl:template match="meleeWeaponAttack | rangedWeaponAttack | action">
    <div class="bulletpoint">
      <div class="title"><xsl:value-of select="@name"/>.</div>
      <xsl:if test="name() = 'meleeWeaponAttack'">
        <i>Melee Weapon Attack: </i>
      </xsl:if>
      <xsl:if test="name() = 'rangedWeaponAttack'">
        <i>Ranged Weapon Attack: </i>
      </xsl:if>
      <xsl:copy-of select="."/>
    </div>
  </xsl:template>

  <xsl:template match="monster//trait">
    <div class="bulletpoint">
      <xsl:choose>
        <xsl:when test="@id">
          <xsl:for-each select="key('traitRef', @id)">
            <div class="title"><xsl:value-of select="@name"/>.</div>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <div class="title"><xsl:value-of select="@name"/>.</div>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

</xsl:stylesheet>
