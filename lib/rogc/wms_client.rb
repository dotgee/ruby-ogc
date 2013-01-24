$:.unshift File.dirname(__FILE__)

require 'formats'
require 'open-uri'


module ROGC
  class WMSClient
    def initialize(wms_url)
      @wms_url = wms_url
      @capabilities = nil
    end

    def capabilities
      return @capabilities if @capabilities
      doc = open(build_wms_url)
      format = ROGC::Formats::WMSCapabilities::Base.new

      @capabilities = format.read(doc)
      @capabilities
    end

    def map(layer, srs = 'CRS:84')
      build_map_request(layer, srs)
    end

    private
      def build_wms_url(request = 'GetCapabilities', version = "1.3.0", params = {})
        params.merge!({
          'service' => 'wms',
          'request' => request,
          'version' => version
        })

        query_string = params.map { |k,v| "#{k}=#{v}" }.join('&')
        "#{@wms_url}?#{query_string}"
      end

      def build_map_request(layer, width = 128, heigth = 128, srs = 'CRS:84', params = {})
        params.merge!({
          'format' => 'image/png',
          'transparent' => true,
          'layers' => layer.name,
          'style' => '',
          'height' => height,
          'width' => width,
          'srs'   => srs,
          'bbox'  => layer.bbox[srs] ? layer.bbox[srs].bbox.join(',') : [11.544243804517265, -0.2895834470186168, 11.802380437565015, -0.0314468139708675].join(',')
        })

        build_wms_url('GetMap', '1.3.0', params)
      end

  end
end
