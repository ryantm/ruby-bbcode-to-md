module RubyBBCode
  # This class holds TagNodes and helps build them into html when the time comes.  It's really just a simple array, with the addition of the #to_html method
  class TagCollection < Array

    def to_html(tags)
      html_string = ""
      self.each do |node|
        if node.type == :tag
          # let child node render:
          children_html = node.has_children? ? node.children.to_html(tags) : nil

          t = HtmlTemplate.new node

          t.inlay_between_text!(children_html)

          if node.allow_tag_param? and node.param_set?
            t.inlay_inline_params!
          elsif node.allow_tag_param? and node.param_not_set?
            t.remove_unused_tokens!
          end

          if node.allow_tag_param_children?
            t.substitute_children_html_params(children_html)
          end

          html_string += t.opening_html

          html_string += children_html if children_html && !node.definition[:require_between]

          t.inlay_closing_html!

          html_string += t.closing_html
        elsif node.type == :text
          html_string += node[:text] unless node[:text].nil?
        end
      end

      html_string
    end

    # This class is designed to help us build up the HTML data.  It starts out as a template such as...
    #   @opening_html = '<a href="%url%">%between%'
    #   @closing_html = '</a>'
    # and then slowly turns into...
    #   @opening_html = '<a href="http://www.blah.com">cool beans'
    #   @closing_html = '</a>'
    # TODO: Think about creating a separate file for this or something... maybe look into folder structures cause this project
    # got huge when I showed up.
    class HtmlTemplate
      attr_accessor :opening_html, :closing_html

      def initialize(node)
        @node = node
        @tag_definition = node.definition # tag_definition

        @opening_html = ""
        @closing_html = ""

        # this bit doesn't really work because parent_type isn't set correctly.
        # if this is a nested tag, then don't prefix first_html_open
        if !node.definition[:first_html_open].nil? && node.type != node.parent_type then
          @opening_html << node.definition[:first_html_open]
        end

        if node.definition[:html_open].is_a?(Hash) then
          @opening_html << node.definition[:html_open][node.parent_type].dup
        else
          @opening_html << node.definition[:html_open].dup
        end

        if node.definition[:html_close].is_a?(Hash) then
          @closing_html << node.definition[:html_close][node.parent_type].dup
        else
          @closing_html << node.definition[:html_close].dup
        end

        if !node.definition[:last_html_close].nil? && node.type != node.parent_type then
          @closing_html << node.definition[:last_html_close]
        end
      end

      def inlay_between_text!(child_html=nil)
        if between_text_goes_into_html_output_as_param? && !@opening_html.nil? && (!@node[:between].nil? || !child_html.nil?)
          @opening_html.gsub!('%between%', (@node[:between] || "") + (child_html || "") )
        end
      end

      def inlay_inline_params!
        # Get list of paramaters to feed
        match_array = @node[:params][:tag_param].scan(@tag_definition[:tag_param])[0]

        # for each parameter to feed
        match_array.each.with_index do |match, i|
          if i < @tag_definition[:tag_param_tokens].length

            # Substitute the %param% keyword for the appropriate data specified
            @opening_html.gsub!("%#{@tag_definition[:tag_param_tokens][i][:token].to_s}%",
                      @tag_definition[:tag_param_tokens][i][:prefix].to_s +
                        match +
                        @tag_definition[:tag_param_tokens][i][:postfix].to_s)
          end
        end
      end

      def inlay_closing_html!
        @closing_html.gsub!('%between%',@node[:between]) if @tag_definition[:require_between] and !@closing_html.nil? and !@node[:between].nil?
      end

      def remove_unused_tokens!
        @tag_definition[:tag_param_tokens].each do |token|
          @opening_html.gsub!("%#{token[:token]}%", '')
        end
      end

      def substitute_children_html_params(children_html)
        return if children_html.nil?
        @tag_definition[:tag_param_tokens].each do |token|
          param = (@node[:params] && @node[:params][:tag_param]) || nil
          sub = @tag_definition[:tag_param_lambda][param]
          children_html.gsub!("%parent_#{token[:token]}%", sub)
        end
      end

      private
      def between_text_goes_into_html_output_as_param?
        @tag_definition[:require_between]
      end
    end

  end
end
