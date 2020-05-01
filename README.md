# Tinkerbell HTML String

This library defines a fairly straightforward utility for taking care of escaping text within HTML (to mitigate XSS vulnerability), while preventing double escaping (to avoid showing gibberish to the user). You may be familiar with it, if you have been using [tink_template](https://github.com/haxetink/tink_template) before, as that is where this utility was extracted from to allow for wider use.

This is, what it comes down to:

```haxe
package tink;

abstract HtmlString to String {

  /// Promise the provided string to an HtmlString without any escaping. Use this only on trusted markup.
  function new(s:String):Void;

  /// Takes any string any string and escapes it for safe use
  @:from static function escape(s:String):HtmlString;

  /// Simply joins multiple html strings into one, but promotes the result to an HtmlString again
  @:from static function join(a:Array<HtmlString>):HtmlString;
}
```

As you pass values to places that expect `HtmlString`, plain `String` gets properly escaped, while `HtmlString` can flow through as is. Consider the following:

```haxe
function b(text:HtmlString)
  return new HtmlString('<b>$text</b>');

function a(attr:{ href:HtmlString}, text:HtmlString)
  return new HtmlString('<a href="${attr.href}">$text</a>');

trace(b('an "example"'));
// <b>an &quot;example&quot;</b>
trace(a({ href: 'http://example.com/?foo&bar' }, ["Let's see ', b('an "example"')]));
// <a href="http://example.com/?foo&amp;bar">Let&#039;s see <b>an &quot;example&quot;</b></a>
```

Notice how `b('the "example"')` escapes the quotes, but nesting it in `a(...)` does not lead to double quoting. That's basically all this is about.

## HtmlBuffer

On top of `HtmlString`, the library provides an `HtmlBuffer` that is intended as a building block for template engines, or really any code that composes HTML.

```haxe
package tink.htmlstring;

abstract HtmlBuffer {
  /// constructs a new buffer for aggregating html
  function new():Void;
  /// adds a safe piece of HTML to the buffer
  function add(s:HtmlString):Void;
  /// adds an raw string to the buffer - use with care!
  function addRaw(s:String):Void;
  /// gets the content of the buffer (without clearing it)
  @:to function toString():String;
  /// just like toString, but promotes the type to HtmlString
  @:to function toHtml():HtmlString;
}
```

We could use it like so for building something like hyperscript.

```haxe
function h(tag:String, attr:haxe.DynamicAccess<HtmlString>, content:Array<HtmlString>):HtmlString {
  var buf = new HtmlBuffer();
  buf.addRaw('<$tag');

  for (key => val in attr)
    buf.addRaw(' $key="$val"'); // val is already escaped and we're assuming that key doesn't need escaping, because it comes from our code

  buf.addRaw('>');

  for (c in content)
    buf.add(c);

  buf.addRaw('</$tag>');

  return buf;
}
```