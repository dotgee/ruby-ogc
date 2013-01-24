module ROGC
  module Formats
    module WMSCapabilities
      class V1_3 < ::ROGC::Formats::WMSCapabilities::V1_1

        READERS_v1_3 = {
          'wms' => {
            'WMS_Capabilities' => lambda { |node, obj|
              read_child_nodes(node, obj)
            }
          }
        }

        def initialize
          super
          #@xml_readers= xml_readers.merge(
          #  'wms' => READERS_v1_3_0['wms']
          #)
          @xml_readers= xml_readers.merge( {
              'wms' => @xml_readers['wms'].merge({
                'WMS_Capabilities' => lambda { |node, obj|
                  read_child_nodes(node, obj)
                },
                'LayerLimit' => lambda { |node, obj|
                  obj.layer_limit = child_value(node).to_i
                },
                'MaxWidth' => lambda { |node, obj|
                  obj.layer_limit = child_value(node).to_i
                },
                'MaxHeight' => lambda { |node, obj|
                  obj.layer_limit = child_value(node).to_i
                },
                'BoundingBox' => lambda { |node, obj|
                  # raise super['wms']['BOundingBox'].inspect
                  bbox = get_bounding_box(node, obj)
                  bbox.srs = node['CRS']
                  obj.bbox ||= {}
                  obj.bbox[bbox.srs] = bbox

                  obj.bbox
                },
                'CRS' => lambda { |node, obj|
                  get_srs(node, obj)
                },
                'EX_GeographicBoundingBox' => lambda { |node, obj|
                  # replacement of LatLonBoundingBox
                  obj.llbbox = [];
                  read_child_nodes(node, obj.llbbox)
                },
                'westBoundLongitude' => lambda { |node, obj|
                  obj[0] = child_value(node)
                },
                'eastBoundLongitude' => lambda { |node, obj|
                  obj[2] = child_value(node)
                },
                'southBoundLatitude' => lambda { |node, obj|
                  obj[1] = child_value(node)
                },
                'northBoundLatitude' => lambda { |node, obj|
                  obj[3] = child_value(node)
                },
                'MinScaleDenominator' => lambda { |node, obj|
                  # obj.maxScale = parseFloat(this.getChildValue(node)).toPrecision(16);
                  obj.max_scale = child_value(node).to_f.round(16)
                },
                'MaxScaleDenominator' => lambda { |node, obj|
                  # obj.minScale = parseFloat(this.getChildValue(node)).toPrecision(16);
                  obj.max_scale = child_value(node).to_f.round(16)
                },
                'Keyword' => lambda { |node, obj|
                  keyword = {
                    'value' => child_value(node),
                    'vocabulary' => node['vocabulary']
                  }

                  obj.keywords << keyword if (obj.keywords)
                }
              })
          })
        end
      end 
    end
  end
end
