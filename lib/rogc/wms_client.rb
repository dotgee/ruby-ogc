$:.unshift File.dirname(__FILE__)

require 'formats'
require 'open-uri'
require 'cgi'


module ROGC
  class WMSClient
    def initialize(wms_url)
      @wms_url = wms_url
      @capabilities = nil
    end

    def capabilities
      return @capabilities if @capabilities
      doc = open(self.class.build_wms_url(@wms_url))
      format = ROGC::Formats::WMSCapabilities::Base.new

      @capabilities = format.read(doc)
      @capabilities
    end

    class << self
      def get_map(wms_url, layer_name, bbox = [], width = 128, height = 128, srs = 'EPSG:4326', params = {})
        build_map_request(wms_url, layer_name, bbox, width, height, srs, params)
      end

      def build_wms_url(wms_url, request = 'GetCapabilities', version = "1.3.0", params = {})
        params.merge!({
          'service' => 'wms',
          'request' => request,
          'version' => version
        })

        query_string = params.map { |k,v| "#{CGI::escape(k)}=#{CGI::escape(v.to_s)}" }.join('&')
        "#{wms_url}?#{query_string}"
      end

      def build_map_request(wms_url, layer_name, bbox = [], width = 128, height = 128, srs = 'EPSG:4326', params = {})
        params.merge!({
          'format' => 'image/png',
          'transparent' => true,
          'layers' => layer_name,
          'style' => '',
          'height' => height,
          'width' => width,
          'crs'   => srs,
          'bbox'  => bbox.any? ? bbox.join(',') : [11.544243804517265, -0.2895834470186168, 11.802380437565015, -0.0314468139708675].join(',')
        })

        build_wms_url(wms_url, 'GetMap', '1.3.0', params)
      end
    end

  end
end
