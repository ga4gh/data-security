module Jekyll
  class AlertDeprecationBlock < Liquid::Block

    def render(context)
      text = super
      "<p style=\"padding:1em; border: solid 2px blue\">#{text}</p>"
    end
  end

  class AlertWarningBlock < Liquid::Block

    def render(context)
      text = super
      "<p style=\"padding:1em; border: solid 2px orange\">#{text}</p>"
    end
  end

end

Liquid::Template.register_tag('alert_deprecation', Jekyll::AlertDeprecationBlock)
Liquid::Template.register_tag('alert_warning', Jekyll::AlertWarningBlock)
