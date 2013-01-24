module ROGC
  module Formats
    module XML
      class VersionedOGC < Base
        class << self
          attr_accessor :version
        end

        cattr_accessor :profile, :default_version

        self.version = nil

        parser = nil
        default_version = nil
        profile = nil

        def initialize
          super
        end

        def get_version(root, options = {})
          lversion = nil

          unless root.nil?
            lversion = self.class.version
            if lversion.nil?
              lversion = root['version']
              lversion ||= default_version
            end
          else
            lversion = options[:version] || self.version || self.default_version
          end
          lversion
        end

        def get_parser(version)
          version ||= default_version
          profile = self.profile.nil? ? "" : "_" + self.profile

          if @parser.nil? || @parser.class.version != version
            # version = 1
            # format = "ROGC::Formats::WMSCapabilities::V#{version}".constantize
            parser_class_name = "V#{version.to_s.gsub(/\./, "_")}" + profile
            begin
              format = "#{self.class.name.deconstantize}::#{parser_class_name}".constantize
            rescue
              format = nil
            end
            if format.nil?
              if !profile.empty? && self.allow_fallback
                profile = ""
                parser_class_name = "V#{version.to_s.gsub(/\./, "_")}" + profile
                begin
                  format = "#{self.class.name.deconstantize}::#{parser_class_name}".constantize
                rescue
                  format = nil
                end
              end
              if format.nil?
                raise "Can't find a parser for version #{version} #{profile}"
              end
            end
                
            @parser = format.new
          else
            puts "Yahoo one parser"
          end

          @parser
        end

        def read(data, options = {})
          if data.is_a?(String)
            data = StringIO.new(data)
          end
          xml_parser = LibXML::XML::Parser.io(data)
          xml = xml_parser.parse
          root = xml.root
          version = get_version(root)

          parser = get_parser(version)
          # puts parser.readers['wms']['Layer'].inspect
          capabilities = OpenStruct.new
          capabilities = parser.read_node(root, capabilities)
          capabilities.version = version
          capabilities
        end
      end
    end
  end
end
