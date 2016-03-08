require_relative 'test_helper'

class RubyBbcodeTest < MiniTest::Unit::TestCase

  def test_list_tag
    assert_equal "\n  1. item 1\n  1. item 2\n\n",
                 "[list=1]\n[*]item 1[/*]\n[*]item 2[/*]\n[/list]".bbcode_to_md
    assert_equal "\n  - item 1\n  - item 2\n\n",
                 "[list][*]item 1[/*][*]item 2[/*][/list]".bbcode_to_md
    assert_equal "\n  - item 1\n  - item 2\n\n",
                 "[list=a][*]item 1[/*][*]item 2[/*][/list]".bbcode_to_md
    assert_equal "\n  - item 1\n  - item 2\n\n",
                 "[list]\n[*]item 1[/*]\n[*]item 2[/*]\n[/list]".bbcode_to_md
  end

  def test_multiline
    assert_equal "line1\nline2", "line1\nline2".bbcode_to_md
    assert_equal "line1\nline2", "line1\r\nline2".bbcode_to_md
  end

  def test_strong
    assert_equal '**simple**', '[b]simple[/b]'.bbcode_to_md
    assert_equal "**line 1\nline 2**", "**line 1\nline 2**".bbcode_to_md
  end

  def test_em
    assert_equal '*simple*', '[i]simple[/i]'.bbcode_to_md
    assert_equal "*line 1\nline 2*", "[i]line 1\nline 2[/i]".bbcode_to_md
  end

  def test_u
    assert_equal 'simple', '[u]simple[/u]'.bbcode_to_md
    assert_equal "line 1\nline 2", "[u]line 1\nline 2[/u]".bbcode_to_md
  end

  def test_size
    assert_equal '[size=32]32px Text[/size]', '[size=32]32px Text[/size]'.bbcode_to_md
  end

  def test_color
    assert_equal 'Red Text', '[color=red]Red Text[/color]'.bbcode_to_md
    assert_equal 'Hex Color Text', '[color=#ff0023]Hex Color Text[/color]'.bbcode_to_md
  end

  def test_center
    assert_equal 'centered', '[center]centered[/center]'.bbcode_to_md
  end

  def test_ordered_list
    assert_equal "\n  1. item 1\n  1. item 2\n\n", '[ol][li]item 1[/li][li]item 2[/li][/ol]'.bbcode_to_md
#    assert_equal "\n  1. item 1\n  1. item 2\n\n", "[ol]\n[li]item 1[/li]\n[li]item 2[/li]\n[/ol]".bbcode_to_md
  end

  def test_unordered_list
    assert_equal "\n  - item 1\n  - item 2\n\n", '[ul][li]item 1[/li][li]item 2[/li][/ul]'.bbcode_to_md
  end

  def test_two_lists
    assert_equal "\n  - item1\n  - item2\n\n\n  - item1\n  - item2\n\n",
                   "[ul][li]item1[/li][li]item2[/li][/ul][ul][li]item1[/li][li]item2[/li][/ul]".bbcode_to_md
  end

  def test_whitespace_in_only_allowed_tags
    assert_equal "\n  1. item 1\n  1. item 2\n\n", "[ol]\n[li]item 1[/li]\n[li]item 2[/li]\n[/ol]".bbcode_to_md
    assert_equal "\n  1. item 1\n  1.  item 2\n\n", "[ol] [li]item 1[/li]  [li] item 2[/li][/ol]".bbcode_to_md
  end

  def test_quote
    assert_equal "\n[quote]quoting[/quote]\n\n",  '[quote]quoting[/quote]'.bbcode_to_md
    assert_equal "\n[quote=someone]quoting[/quote]\n\n", '[quote=someone]quoting[/quote]'.bbcode_to_md
  end

  def test_nested_quotes
    assert_equal "\n[quote=Kitten]\n[quote=creatiu]f1[/quote]\n\nf2[/quote]\n\n",
                  '[quote=Kitten][quote=creatiu]f1[/quote]f2[/quote]'.bbcode_to_md
  end

  def test_link
    assert_equal '[http://www.google.com](http://www.google.com)', '[url]http://www.google.com[/url]'.bbcode_to_md
    assert_equal '[Google](http://google.com)', '[url=http://google.com]Google[/url]'.bbcode_to_md
    assert_equal '[Home](/index.html)', '[url=/index.html]Home[/url]'.bbcode_to_md
    assert_equal "[Google](http://google.com) and [Bing](http://bing.com) are both search engines.",
                  '[url=http://google.com]Google[/url] and [url=http://bing.com]Bing[/url] are both search engines.'.bbcode_to_md
  end

  def test_image
    assert_equal '![](http://www.ruby-lang.org/images/logo.gif)',
                   '[img]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_to_md
    assert_equal '![](http://www.ruby-lang.org/images/logo.gif)',
                   '[img=95x96]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_to_md
  end

  def test_youtube
    assert_equal 'https://www.youtube.com/watch?v=E4Fbk52Mk1w', '[youtube]E4Fbk52Mk1w[/youtube]'.bbcode_to_md
  end

  def test_youtube_with_full_url
    full_url = "http://www.youtube.com/watch?feature=player_embedded&v=E4Fbk52Mk1w"
    assert_equal "https://www.youtube.com/watch?v=E4Fbk52Mk1w", "[youtube]#{full_url}[/youtube]".bbcode_to_md
  end

  def test_youtube_with_url_shortener
    full_url = "http://www.youtu.be/cSohjlYQI2A"
    assert_equal "https://www.youtube.com/watch?v=cSohjlYQI2A", "[youtube]#{full_url}[/youtube]".bbcode_to_md
  end


  def test_html_escaping
    assert_equal '**&lt;i&gt;foobar&lt;/i&gt;**', '[b]<i>foobar</i>[/b]'.bbcode_to_md
    assert_equal '**<i>foobar</i>**', '[b]<i>foobar</i>[/b]'.bbcode_to_md(false)
    assert_equal '1 is &lt; 2', '1 is < 2'.bbcode_to_md
    assert_equal '1 is < 2', '1 is < 2'.bbcode_to_md(false)
    assert_equal '2 is &gt; 1', '2 is > 1'.bbcode_to_md
    assert_equal '2 is > 1', '2 is > 1'.bbcode_to_md(false)
  end

  def test_disable_tags
    assert_equal "[b]foobar[/b]", "[b]foobar[/b]".bbcode_to_md(true, {}, :disable, :b)
    assert_equal "[b]*foobar*[/b]", "[b][i]foobar[/i][/b]".bbcode_to_md(true, {}, :disable, :b)
    assert_equal "[b][i]foobar[/i][/b]", "[b][i]foobar[/i][/b]".bbcode_to_md(true, {}, :disable, :b, :i)
  end

  def test_enable_tags
    assert_equal "**foobar**" , "[b]foobar[/b]".bbcode_to_md(true, {}, :enable, :b)
    assert_equal "**[i]foobar[/i]**", "[b][i]foobar[/i][/b]".bbcode_to_md(true, {}, :enable, :b)
    assert_equal "***foobar***", "[b][i]foobar[/i][/b]".bbcode_to_md(true, {}, :enable, :b, :i)
  end

  def test_to_html_bang_method
    foo = "[b]foobar[/b]"
    assert_equal "**foobar**", foo.bbcode_to_md!
    assert_equal "**foobar**", foo
  end

  # commented this out, it kinda just gets in the way of development atm
  #def test_self_tag_list
  #  assert_equal 16, RubyBBCode::Tags.tag_list.size
  #end

  def test_addition_of_tags
    mydef = {
      :test => {
        :html_open => '<test>', :html_close => '</test>',
        :description => 'This is a test',
        :example => '[test]Test here[/test]'}
    }
    assert_equal 'pre <test>Test here</test> post', 'pre [test]Test here[/test] post'.bbcode_to_md(true, mydef)
    assert_equal 'pre **<test>Test here</test>** post', 'pre [b][test]Test here[/test][/b] post'.bbcode_to_md(true, mydef)
  end

  def test_multiple_tag_test
    assert_equal "**bold***italic*underline\n[quote]quote[/quote]\n\n[link](https://test.com)",
                   "[b]bold[/b][i]italic[/i][u]underline[/u][quote]quote[/quote][url=https://test.com]link[/url]".bbcode_to_md
  end

  def test_no_ending_tag
    assert_equal "this **should be handled**", "this [b]should be handled".bbcode_to_md
  end

  def test_no_start_tag
    assert_equal "this should not be bold", "this should not be bold[/b]".bbcode_to_md
  end

  def test_different_start_and_ending_tags
    assert_equal "this **should be tolerated**", "this [b]should be tolerated[/i]".bbcode_to_md
  end

    # TODO:  This stack level problem should be validated during the validations
  def test_stack_level_too_deep
    num = 2300  # increase this number if the test starts failing.  It's very near the tipping point
    openers = "[s]hi i'm" * num
    closers = "[/s]" * num
    assert_raises( RuntimeError ) do
      (openers+closers).bbcode_to_md
    end

  end

  def test_mulit_tag
    input1 = "[media]https://www.youtube.com/watch?v=cSohjlYQI2A[/media]"
    input2 = "[media]http://vimeo.com/46141955[/media]"

    output1 = "https://www.youtube.com/watch?v=cSohjlYQI2A"
    output2 = "http://vimeo.com/46141955"

    assert_equal output1, input1.bbcode_to_md
    assert_equal output2, input2.bbcode_to_md
  end

  def test_vimeo_tag
    input = "[vimeo]http://vimeo.com/46141955[/vimeo]"
    input2 = "[vimeo]46141955[/vimeo]"
    output = 'http://vimeo.com/46141955'

    assert_equal output, input.bbcode_to_md
    assert_equal output, input2.bbcode_to_md
  end

  def test_failing_multi_tag
    input1 = "[media]http://www.youtoob.com/watch?v=cSohjlYQI2A[/media]"

    assert_equal input1, input1.bbcode_to_md
  end

  def test_nested_inside_url_tag
    assert_equal "[**Google**](http://google.com)", "[url=http://google.com][b]Google[/b][/url]".bbcode_to_md
    assert_equal "[Go to **Google**](http://google.com)", "[url=http://google.com]Go to [b]Google[/b][/url]".bbcode_to_md
    assert_equal "[**Google**](http://google.com)", "[url=http://google.com][color=#008000][b]Google[/b][/color][/url]".bbcode_to_md
  end

  def test_code
    assert_equal "```\nx = x+1;\n```", '[code]x = x+1;[/code]'.bbcode_to_md
  end

end
