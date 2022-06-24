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

Second level headers - {% hr2 %}  <hr style="border: 2px solid; margin: 2em auto;"/>
Third level headers - <hr style="width: 10em; margin: 2em auto;"/>
Fourth level headers - <hr style="border: 0; height: 0; margin: 1em auto;"/>

Note that level 5 and 6 headers render smaller than paragraph text and are not
distinctive - and therefore should be avoided.

Use **text** for a 5th level header if required.

The actual HTML for these dividers can be found in `_plugins/jekyll-hrs.rb`.
