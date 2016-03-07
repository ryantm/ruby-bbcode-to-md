module RubyBBCode
  module Tags
    # tagname => tag, HTML open tag, HTML close tag, description, example
    # All of these entrys are represented as @dictionary in the classes (or as the variable tags)
    # A single item from this file (eg the :b entry) is refered to as a @definition
    @@tags = {
      :b => {
        :html_open => '**', :html_close => '**',
        :description => 'Make text bold',
        :example => 'This is [b]bold[/b].'},
      :i => {
        :html_open => '*', :html_close => '*',
        :description => 'Make text italic',
        :example => 'This is [i]italic[/i].'},
      :u => {
        :html_open => '', :html_close => '',
        :description => 'Underline text',
        :example => 'This is [u]underlined[/u].'},
      :center => {
        :html_open => '', :html_close => '',
        :description => 'Center a text',
        :example => '[center]This is centered[/center].'},
      :list => {
        :html_open => "\n", :html_close => "\n",
        :description => 'Unordered list',
        :example => '[list][*]List item[/*][*]Another list item[/*][/list].',
        :allow_tag_param => true, :allow_tag_param_children => true,
        :tag_param => /(\w*)/,
        :tag_param_tokens => [{:token => :order}],
        :tag_param_lambda => ->(param) {
          if param == "1"
            "1."
          else
            "-"
          end
        },
        :only_allow => [ :* ]},
      :* => {
        :html_open => {
          :list => '  %parent_order% '
        },
        :html_close => "\n",
        :description => 'List item',
        :example => '[list][*]List item[/*][*]Another list item[/*][/list].',
        :only_in => [ :list ]},
      :ul => {
        :html_open => "\n", :html_close => "\n",
        :description => 'Unordered list',
        :example => '[ul][li]List item[/li][li]Another list item[/li][/ul].',
        :only_allow => [ :li ]},
      :ol => {
        :html_open => "\n", :html_close => "\n",
        :description => 'Ordered list',
        :example => '[ol][li]List item[/li][li]Another list item[/li][/ol].',
        :only_allow => [ :li ]},
      :li => {
        :html_open => {
          :ul => '  - ',
          :ol => '  1. '
        },
        :html_close => "\n",
        :description => 'List item',
        :example => '[ul][li]List item[/li][li]Another list item[/li][/ul].',
        :only_in => [ :ul, :ol ]},
      :img => {
        :html_open => '![](%between%)', :html_close => '',
        :description => 'Image',
        :example => '[img]http://www.google.com/intl/en_ALL/images/logo.gif[/img].',
        :only_allow => [],
        :require_between => true,
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /^(\d*)x(\d*)$/,
        :tag_param_tokens => [{:token => :width, :prefix => 'width="', :postfix => '" ' },
                              { :token => :height,  :prefix => 'height="', :postfix => '" ' } ],
        :tag_param_description => 'The image parameters \'%param%\' are incorrect, <width>x<height> excepted'},
      :url => {
        :html_open => '[%between%](%href%)', :html_close => '',
        :description => 'Link to another page',
        :example => '[url=http://www.google.com/]Google[/url].',
        :only_allow => [],
        :require_between => true,
        :allow_tag_param => true,
        :allow_tag_param_between => true,
        :tag_param => /(.*)/,
        :tag_param_tokens => [{:token => :href}]},
      :quote => {
        :first_html_open => "\n", :last_html_close => "\n",
        :html_open => "[quote%author%]", :html_close => "[/quote]\n",
        :description => 'Quote another person',
        :example => '[quote]BBCode is great[/quote]',
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /(.*)/,
        :tag_param_tokens => [{:token => :author, :prefix => '=', :postfix => ""}]},
      :size => {
        :html_open => '[size=%size%]', :html_close => '[/size]',
        :description => 'Change the size of the text',
        :example => '[size=32]This is 32px[/size]',
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /(\d*)/,
        :tag_param_tokens => [{:token => :size}]},
      :color => {
        :html_open => '', :html_close => '',
        :description => 'Change the color of the text',
        :example => '[color=red]This is red[/color]',
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /(([a-z]+)|(#[0-9a-f]{6}))/i,
        :tag_param_tokens => [{:token => :color}]},
      :youtube => {
        :html_open => 'https://www.youtube.com/watch?v=%between%', :html_close => '',
        :description => 'Youtube video',
        :example => '[youtube]E4Fbk52Mk1w[/youtube]',
        :only_allow => [],
        :url_varients => ["youtube.com", "youtu.be", "y2u.be"], # NOT USED
        :url_matches => [/youtube\.com.*[v]=([^&]*)/, /youtu\.be\/([^&]*)/, /y2u\.be\/([^&]*)/],
        :require_between => true},
      :vimeo => {
        :html_open => 'http://vimeo.com/%between%',
        :html_close => '',
        :description => 'Vimeo video',
        :example => '[vimeo]http://vimeo.com/46141955[/vimeo]',
        :only_allow => [],
        :url_matches => [/vimeo\.com\/([^&]*)/],
        :require_between => true},
      :media => {
        :multi_tag => true,
        :supported_tags => [
          :youtube,
          :vimeo
        ]
      }
    }

    def self.tag_list
      @@tags
    end
  end
end
