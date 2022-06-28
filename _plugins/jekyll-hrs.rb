module Jekyll
  class HR2Tag < Liquid::Tag

    def render(context)
      '<hr style="border: 2px solid; margin: 2em auto;"/>'
    end
  end

  class HR3Tag < Liquid::Tag

    def render(context)
      '<hr style="width: 10em; margin: 2em auto;"/>'
    end
  end

  class HR4Tag < Liquid::Tag

    def render(context)
      '<p style="text-align:center; font-size: small">—</p>'
    end
  end

end

Liquid::Template.register_tag('hr2', Jekyll::HR2Tag)
Liquid::Template.register_tag('hr3', Jekyll::HR3Tag)
Liquid::Template.register_tag('hr4', Jekyll::HR4Tag)
