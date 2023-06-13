# 2021 Modified by Patto to directly insert the rendered SVG content as a
# SVG DOM tree, not as an <object> source (which makes the browser create iframes etc).
# Because the file is not sourced it also does not need to live in the static site
# and so the code was also changed to use the Jekyll cache_dir

# (The MIT License)
#
# Copyright (c) 2014-2019 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'digest'
require 'fileutils'
require 'nokogiri'

module Jekyll
  class PlantumlBlock < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @html = (markup or '').strip
    end

    def render(context)
      # we want to make temporary SVG and UML files on disk - but ones that persist between runs
      # or else we will continually be generating images on every change
      cache_dir = context.registers[:site].config['cache_dir']

      # use the content of the block as the unique key name
      name = Digest::MD5.hexdigest(super)

      # proposed names for our cached files and make sure the directory that stores them exists
      uml = File.join(cache_dir, "plantuml/#{name}.uml")
      svg = File.join(cache_dir, "plantuml/#{name}.svg")
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