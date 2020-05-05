package tink;

import tink.htmlstring.HtmlBuffer;

using StringTools;

abstract HtmlString(String) to String {
  /// Promise the provided string to an HtmlString without any escaping. Use this only on trusted markup.
  public inline function new(s:String)
    this = s;

  /// Takes any string any string and escapes it for safe use
  @:from static public inline function escape(s:String)
    return new HtmlString(if (s == null) '' else htmlEscape(s));

  /// Simply joins multiple html strings into one, but promotes the result to an HtmlString again
  @:from static public function join(a:Array<HtmlString>):HtmlString
    return new HtmlString(a.join(''));

  #if php
  static inline function htmlEscape(s:String)
    return s.htmlEscape(true);
  #else
  static function htmlEscape(s:String) {
    var start = 0,
        pos = 0,
        max = s.length;

    var ret = new RawBuffer();

    inline function flush(?entity:String)
      if (entity == null)
        ret.addSub(s, start, max - start);//https://github.com/HaxeFoundation/haxe/issues/9382
      else {
        ret.addSub(s, start, pos - start - 1);
        start = pos;
        ret.add(entity);
      }

    while (pos < max)
      switch s.fastCodeAt(pos++) {
        case '"'.code: flush('&quot;');
        case "'".code: flush('&#039;');
        case '<'.code: flush('&lt;');
        case '>'.code: flush('&gt;');
        case '&'.code: flush('&amp;');
      }

    flush();
    return ret.toString();
  }
  #end
}