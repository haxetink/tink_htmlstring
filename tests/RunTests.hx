package ;

import tink.testrunner.*;
import tink.unit.*;
import tink.htmlstring.HtmlBuffer;

using tink.HtmlString;
using StringTools;

@:asserts
class RunTests {

  public function new() {}

  @:variant('plain')
  @:variant('<>&"\'')
  @:variant('123<bar>blub&boink"beep\'boop')
  public function escaping(canditate:String) {
    asserts.assert(canditate.escape() == canditate.htmlEscape(true));
    return asserts.done();
  }

  public function example() {
    function b(text:HtmlString)
      return new HtmlString('<b>$text</b>');

    function a(attr:{ href:HtmlString}, text:HtmlString)
      return new HtmlString('<a href="${attr.href}">$text</a>');

    asserts.assert(b('an "example"') == '<b>an &quot;example&quot;</b>');
    asserts.assert(
      a({ href: 'http://example.com/?foo&bar' }, ["Let's see ", b('an "example"')])
      == '<a href="http://example.com/?foo&amp;bar">Let&#039;s see <b>an &quot;example&quot;</b></a>'
    );

    return asserts.done();
  }

  public function buffers() {
    asserts.assert(
      h('article', [
        h('h1', ['My first post <3']),
        h('p', ['Enjoy the "content"'])
      ]) == '<article><h1>My first post &lt;3</h1><p>Enjoy the &quot;content&quot;</p></article>'

    );
    return asserts.done();
  }

  static function h(tag:String, ?attr:haxe.DynamicAccess<HtmlString>, content:Array<HtmlString>):HtmlString {
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

  static function main() {
    Runner.run(TestBatch.make([
      new RunTests(),
    ])).handle(Runner.exit);
  }

}