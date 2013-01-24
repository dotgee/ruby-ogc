module ROGC
  module Formats
    module WMSCapabilities
      class V1_1 < V1
        def initialize
          super
          @xml_readers = xml_readers.merge({ 'wms' =>  xml_readers['wms'].merge({
          'WMT_MS_Capabilities' => lambda { |node, obj|
            read_child_nodes(node, obj)
          },
          'Keyword' => lambda { |node, obj|
            obj.keywords ||= Array.new
            obj.keywords << child_value(node)
          },
          'DescribeLayer' => lambda { |node, obj|
            obj.describelayer = OpenStruct.new({ formats: Array.new })
            read_child_nodes(node, obj.describelayer)
          },
          'GetLegendGraphic' => lambda { |node, obj|
            obj.getlegendgraphic = OpenStruct.new({ formats: Array.new })
            read_child_nodes(node, obj.getlegendgraphic)
          },
          'GetStyles' => lambda { |node, obj|
            obj.getstyles = OpenStruct.new({ formats: Array.new })
            read_child_nodes(node, obj.getstyles)
          },
          'PutStyles' => lambda { |node, obj|
            obj.putstyles = OpenStruct.new({ formats: Array.new })
            read_child_nodes(node, obj.putstyles)
          },
          'UserDefinedSymbolization' => lambda { |node, obj|
            obj.user_symbols = OpenStruct.new({
              supports_SLD: node['SupportSLD'].to_i == 1,
              user_layer: node['UserLayer'].to_i == 1,
              user_style: node['UserStyle'].to_i == 1,
              remote_WFS: node['RemoteWFS'].to_i == 1
            })
          },
          'LatLonBoundingBox' => lambda { |node, obj|
            obj.llbox = [
              node['minx'].to_f,
              node['miny'].to_f,
              node['maxx'].to_f,
              node['maxy'].to_f
            ]
          },
          'BoundingBox' => lambda { |node, obj|
              # raise super['wms']['BOundingBox'].inspect
              bbox = get_bounding_box(node, obj)
              # bbox = obj.bbox
              bbox.srs = node['SRS']
              obj.bbox ||= {}
              obj.bbox[bbox.srs] = bbox 

              obj.bbox
          }
            
        }) })
        end
      end
    end
  end
end
