module ROGC
  module Formats
    module WMSCapabilities
      class V1_1_1 < V1_1
        self.version = '1.1.1'

        def initialize
          super
          @xml_readers = xml_readers.merge({ 'wms' =>  @xml_readers['wms'].merge({}) })
        end
      end 
    end
  end
end
