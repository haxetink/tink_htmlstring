package tink.htmlstring;

abstract HtmlBuffer(RawBuffer) {
  /// constructs a new buffer for aggregating html
  public inline function new()
    this = new RawBuffer();

  /// adds a safe piece of HTML to the buffer
  public inline function add(s:HtmlString)
    this.add(s);

  /// adds an raw string to the buffer - use with care!
  public inline function addRaw(s:String)
    this.add(s);

  /// gets the content of the buffer (without clearing it)
  @:to public inline function toString():String
    return this.toString();

  /// just like toString, but promotes the type to HtmlString
  @:to public inline function toHtml():HtmlString
    return new HtmlString(this.toString());

}

#if (js || php)
class RawBuffer {
  var out:String = '';
  public inline function new() {}
  public inline function add(value:String)
    out += value;
  public inline function addSub(value:String, start:Int, ?len:Int)
    out += value.substr(start, len);
  public inline function toString()
    return out;
}
#else
typedef RawBuffer = StringBuf;
#end