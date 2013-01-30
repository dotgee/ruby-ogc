require 'libxml'
require 'open-uri'
require 'ostruct'
require 'active_support/all'

unless Object.respond_to?(:blank)
  class Object
    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end
end

unless Object.respond_to?(:to_bool)
  class Object
    def to_bool
      return false if self == false || self.blank? || self.to_s =~ (/(false|f|no|n|0)$/i)
      return true if self == true || self.to_s =~ (/(true|t|yes|y|1)$/i)
      raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
    end
  end
end

unless OpenStruct.respond_to?(:to_hash)

  class OpenStruct
    def xx_to_hash
      return {} unless self._table_hash
      return @table.inject({}) do |h, (key, value)|
        value = value.to_hash if value.respond_to?(:to_hash)
        h.merge!({ key: value })
        h
      end
    end

    private

    def _table_hash
      @table
    end

  end
end

#
# TODO: OnlineResource
#

module ROGC
  module Formats
    module XML
      class Base

        # class_attribute :readers
        cattr_accessor :namespace_alias, :default_prefix, :xmldom
        
        attr_accessor :xml_readers

        def initialize
          # @io = io
          # @parser = LibXML::XML::Parser.io(io)
          # @raw = @parser.parse
          # @capabilities = OpenStruct.new
          # @root = @raw.root
          # self.class.read_node(@root, @capabilities)
          @xml_readers = {}
        end
      
        # class << self
          def read_node(node, obj)
            if (obj.nil?)
              obj = OpenStruct.new
            end
      
            # reader = self.readers['wms'][node.name]
            reader = xml_readers['wms'][node.name]
            if (reader)
              reader.call(node, obj)
            end
            obj
          end
      
          def read_child_nodes(node, obj)
            if (obj.nil?)
              obj = OpenStruct.new
            end
      
            children = node.children
            children.each do |child|
              if (child.node_type == 1)
                read_node(child, obj)
              end
            end
      
            obj
          end
       
          def child_value(node, default = nil)
            value = default || ""
      
            node.each do |child|
              case child.node_type
              when 3,4 # Text: 3 or CDATA: 4 use cdata? or text?
                value << child.content
              end
            end
            value.strip!
      
            value
          end
        # end
         
        # def read_node(node, obj)
        #   self.class.read_node(node, obj)
        # end
      end
    end
  end
end
      
