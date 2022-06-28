# data-security

This is the repository for the source of any specifications/documentation
of the GA4GH Data Security working group.

The source is written in Markdown and processed via Jekyll.

To produce a local copy, you can

```shell
make
```

or alternatively run the simple `docker` command shown in the Makefile (runs Jekyll in `serve` mode).

The local copy can then be browsed at

```
http://localhost:4000/local/
```

## Use of Jekyll

The following Liquid tags are used to separate

Second level headers - {% hr2 %} 
Third level headers - {% hr3 %}
Fourth level headers - {% hr4 %}

Note that level 5 and 6 headers render smaller than paragraph text and are not
distinctive - and therefore should be avoided.

Use **text** for a 5th level header if required.

The actual HTML for these dividers can be found in `_plugins/jekyll-hrs.rb`.
