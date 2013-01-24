module ROGC
  module Formats
    module WMSCapabilities
      class V1 < Base
        self.version = '1.0.0'

        def initialize
          super
          @xml_readers = xml_readers.merge({
          'wms' => {
            'Service' => lambda { |node, obj|
                          obj.service ||= OpenStruct.new
                          read_child_nodes(node, obj.service)
            },
            'Name' => lambda { |node, obj|
                          obj.name = child_value(node)
            },
            'Title' => lambda { |node, obj|
              obj.title = child_value(node)
            },
            'Abstract' => lambda { |node, obj|
                          obj.abstract = child_value(node)
            },
            'BoundingBox' => lambda { |node, obj|
              return get_bounding_box(node, obj)
              bbox = OpenStruct.new
              bbox.bbox = [
                node['minx'].to_f,
                node['miny'].to_f,
                node['maxx'].to_f,
                node['maxy'].to_f
              ]
        
              res = OpenStruct.new
              res.x = node['resx'].to_f if node['resx']
              res.y = node['resy'].to_f if node['resy']
        
              bbox.res = res unless res.x.nil? || res.y.nil?
        
              # obj.bbox = bbox
              # obj
              bbox
            },
            'OnlineReource' => lambda { |node, obj|
              # obj.contact_information = OpenStruct.new
              # read_child_nodes(node, obj.contact_information)
            },
            'ContactInformation' => lambda { |node, obj|
              obj.contact_information = OpenStruct.new
              read_child_nodes(node, obj.contact_information)
            },
            'ContactPersonPrimary' => lambda { |node, obj|
              obj.person_primary = OpenStruct.new
              read_child_nodes(node, obj.person_primary)
            },
            'Capability' => lambda { |node, obj|
              obj.capability = OpenStruct.new
              obj.capability.nested_layers = Array.new
              obj.capability.layers = Array.new
        
              read_child_nodes(node, obj.capability)
            },
            'Request' => lambda { |node, obj|
              obj.request = OpenStruct.new
              read_child_nodes(node, obj.request)
            },
            'GetCapabilities' => lambda { |node, obj|
              obj.getcapabilities = OpenStruct.new(formats: Array.new)
              read_child_nodes(node, obj.getcapabilities)
            },
            'Format' => lambda { |node, obj|
              if obj.formats.is_a?(Array)
                obj.formats << node.child.content if node.child?
              else
                obj.format = node.child.content if node.child?
              end
            },
            'DCPType' => lambda { |node, obj|
              read_child_nodes(node, obj)
            },
            'HTTP' => lambda { |node, obj|
              read_child_nodes(node, obj)
            },
            'Get' => lambda { |node, obj|
              obj.get = OpenStruct.new
              read_child_nodes(node, obj.get)
        
              if obj.href.nil? || obj.href == ''
                obj.href = obj.get.href
              end
            },
            'Post' => lambda { |node, obj|
              obj.post = OpenStruct.new
              read_child_nodes(node, obj.post)
        
              if obj.href.nil? || obj.href == ''
                obj.href = obj.get.href
                # obj.href = obj.post.href # Isn't it better?
              end
            },
            'GetMap' => lambda { |node, obj|
              obj.getmap = OpenStruct.new(formats: Array.new)
              read_child_nodes(node, obj.getmap)
            },
            'GetFeatureInfo' => lambda { |node, obj|
              obj.getfeatureinfo = OpenStruct.new(formats: Array.new)
              read_child_nodes(node, obj.getfeatureinfo)
            },
            'Exception' => lambda { |node, obj|
              obj.exception = OpenStruct.new(formats: Array.new)
              read_child_nodes(node, obj.exception)
            },
            'Layer' => lambda { |node, obj|
              parent_layer, capability = nil
        
              if (obj.capability)
                capability = obj.capability
                parent_layer = obj
              else
                capability = obj
              end
        
              #
              # List of attributes
              #
        
              queryable = node['queryable']
              cascaded = node['cascaded']
              opaque = node['opaque']
              no_subsets = node['noSubsets']
              fixed_width = node['fixed_width']
              fixed_height = node['fixed_height']
        
              parent = parent_layer || OpenStruct.new
              #
              # Create layer
              #
              layer = OpenStruct.new(
                {
                  nested_layers: Array.new,
                  styles: parent_layer.nil? ? Array.new : [] + parent_layer.styles,
                  srs: parent_layer.nil? ? {} : {}.merge(parent.srs),
                  metadata_urls: [],
                  bbox: parent_layer.nil? ? {} : {}.merge(parent.bbox),
                  llbbox: parent.llbbox,
                  dimensions: parent_layer.nil? ? {} : {}.merge(parent.dimensions),
                  authority_urls: parent_layer.nil? ? {} : {}.merge(parent.authority_urls),
                  identifiers: OpenStruct.new,
                  keywords: Array.new,
                  queryable?: queryable.to_bool || parent.queryable?.to_bool, # TODO
                  cascaded: cascaded.to_i || parent.cascaded.to_i, # TODO
                  opaque: opaque.to_bool || parent.opaque.to_bool, # TODO
                  no_subsets: no_subsets.to_bool || parent.no_subsets.to_bool, # TODO
                  fixed_width: fixed_width.to_i || parent.fixed_width.to_i, # TODO
                  fixed_height: fixed_height.to_i || parent.fixed_height.to_i, # TODO
                  min_scale: parent.min_scale,
                  max_scale: parent.max_scale,
                  attribution: parent.attribution
                }
              )
        
              obj.nested_layers ||= Array.new
              obj.nested_layers << layer
              layer.capability = capability
              read_child_nodes(node, layer)
              layer.delete_field(:capability)
        
              unless layer.name.nil? || layer.name.strip == ''
                parts = layer.name.split(':')
                request = capability.request
                gfi = request.getfeatureinfo
        
                if parts.length > 0
                  layer.prefix = parts.first
                end
                capability.layers << layer
        
                if layer.formats.nil?
                  layer.formats = request.getmap.formats
                end
        
                if layer.info_formats.nil? && gfi
                  layer.info_formats = gfi.formats
                end
              end
              #
              # Handle layer name
              #
            },
            'Request' => lambda { |node, obj|
              obj.request = OpenStruct.new
              read_child_nodes(node, obj.request)
            },
            'KeywordList' => lambda { |node, obj|
              read_child_nodes(node, obj)
            },
            'Style' => lambda { |node, obj|
              style = OpenStruct.new
              obj.styles << style
              read_child_nodes(node, style)
            },
            'SRS' => lambda { |node, obj|
              get_srs(node, obj)
              #obj.srs[child_value(node)] = true
            }
            
          }
        })
        end

        def get_srs(node, obj)
          obj.srs ||= Hash.new
          obj.srs[child_value(node)] = true
        end

        def get_bounding_box(node, obj)
          bbox = OpenStruct.new
          bbox.bbox = [
            node['minx'].to_f,
            node['miny'].to_f,
            node['maxx'].to_f,
            node['maxy'].to_f
          ]
        
          res = OpenStruct.new
          res.x = node['resx'].to_f if node['resx']
          res.y = node['resy'].to_f if node['resy']
        
          bbox.res = res unless res.x.nil? || res.y.nil?
        
          # obj.bbox = bbox
          # obj
          bbox
        end
      end
    end
  end
end
