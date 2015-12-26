task :default => [:make]

desc "make xlst transform"
task :make do
  require 'nokogiri'
  require 'wicked_pdf'

  transform 'monsters.xml', 'monster_template.xsl', 'monsters.html'
  transform 'spells.xml', 'spell_template.xsl', 'spells.html'
  transform 'items.xml', 'item_template.xsl', 'items.html'
  transform 'references.xml', 'reference_template.xsl', 'references.html'

end


def transform input, templateFile, output
  validate input
  validate templateFile

  document = Nokogiri::XML(File.read(input))
  template = Nokogiri::XSLT(File.read(templateFile))
  File.open(output, 'w').write(template.transform(document))

end

def validate xmlfile
  result = `xmllint --noout #{xmlfile}`
  puts result unless '' == result
end
