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
  end
end

url = ARGV.shift

puts "No url specified" and Kernel.exit(1) if url.nil?

client = ROGC::WMSClient.new(url) # ('http://preprod.osuris.org/geoserver/wms')

capabilities = client.capabilities

capabilities.capability.layers.each do |layer|
  puts layer.name
end
