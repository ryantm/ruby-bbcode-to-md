module RubyBBCode
  # As you parse a string of text, say:
  #     "[b]I'm bold and the next word is [i]ITALLICS[/i][b]"
  # ...you build up a tree of nodes (@bbtree).  The above string converts to 4 nodes when the parse has completed.
  # Node 1)  An opening tag node representing "[b]"
  # Node 2)  A text node         representing "I'm bold and the next word is "
  # Node 3)  An opening tag node representing "[i]"
  # Node 4)  A text node         representing "ITALLICS"
  #
  # The closing of the nodes seems to be implied which is fine by me --less to keep track of.
  #
  class BBTree
    include ::RubyBBCode::DebugBBTree
    attr_accessor :current_node, :tags_list
    attr_reader :tag_collection
    alias :nodes :tag_collection
    alias :children :nodes

    def initialize(dictionary, tag_collection = TagCollection.new)
      @tag_collection = tag_collection
      @current_node = TagNode.new({nodes: tag_collection})
      @tags_list = []
      @dictionary = dictionary
    end

    def type
      :bbtree
    end

    def within_open_tag?
      @tags_list.length > 0
    end
    alias :expecting_a_closing_tag? :within_open_tag?  # just giving this method multiple names for semantical purposes

    def parent_tag
      return nil if !within_open_tag?
      @tags_list.last.to_sym
    end

    def escalate_bbtree(element)
      element[:parent_tag] = parent_tag
      element[:parent_node] = @current_node
      @tags_list.push element[:tag]
      @current_node = TagNode.new(element)
    end

    # Step down the bbtree a notch because we've reached a closing tag
    def retrogress_bbtree
      return if !within_open_tag?

      @tags_list.pop
      @current_node = @current_node[:parent_node]
    end

    def redefine_parent_tag_as_text
      @tags_list.pop
      @current_node[:is_tag] = false
      @current_node[:closing_tag] = false
      @current_node.element[:text] = "[#{@current_node[:tag].to_s}]"
    end

    def build_up_new_tag(element)
      @current_node.children << TagNode.new(element)
    end

    def to_html(tags = {})
      self.nodes.to_html(tags)
    end

  end
end
