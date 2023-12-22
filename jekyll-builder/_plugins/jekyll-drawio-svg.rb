# Inspired at some point by
# plantuml-svg  Copyright (c) 2014-2019 Yegor Bugayenko
# but now essentially unrecognisable

require 'digest'
require 'fileutils'
require 'nokogiri'

module Jekyll
  class DrawioBlock < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @html = (markup or '').strip
    end

    def render(context)
      # we want to make temporary SVG files on disk - but ones that persist between runs
      # or else we will continually be generating images on every change
      cache_dir = context.registers[:site].config['cache_dir']

      # use the content of the block as the unique key name
      name = Digest::MD5.hexdigest(super)

      # proposed names for our cached files and make sure the directory that stores them exists
      uml = File.join(cache_dir, "drawio/#{name}.uml")
      svg = File.join(cache_dir, "drawio/#{name}.svg")
      FileUtils.mkdir_p(File.dirname(uml))

      # if we don't have both files cached then lets regenerate
      if !File.exist?(uml) or !File.exist?(svg)
        File.open(uml, 'w') { |f|
          f.write("@startuml\n")
          f.write(super)
          f.write("\n@enduml")
        }
        # by default plantuml creates the SVG with the incoming file path and just changes suffix
        system("plantuml -tsvg -SsvgDimensionStyle=false #{uml}") or raise "PlantUML error: #{super}"
        puts "File #{svg} created (#{File.size(svg)} bytes)"
      end

      # we want to directly insert the SVG content into the rendered page
      svg_content = File.read(svg)
      xml = Nokogiri::XML(svg_content)
      xml.root.to_xml
    end
  end
end

Liquid::Template.register_tag('plantuml', Jekyll::PlantumlBlock)