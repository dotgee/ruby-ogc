require 'forwardable'

module ROGC
  class LayerPresenter
    extend Forwardable

    attr_reader :olayer

    def_delegators :@olayer, :name, :title, :abstract, :bbox, :llbbox, :metadata_urls, :srs, :dimensions

    def initialize(olayer)
      @olayer = olayer || OpenStruct.new
    end

    def description
      abstract
    end

    def keywords(vocabulary = nil)
      @keywords ||= {}
      return @keywords[vocabulary] if @keywords[vocabulary]

      @keywords[vocabulary] = @olayer.keywords.select { |k| vocabulary.nil? || k['vocabulary'] == vocabulary }.map { |kv| kv['value'] }
      @keywords[vocabulary]
    end
      
    def native_srs
      return @native_srs if @native_srs
      if @olayer.layer_srs.empty?
        @native_srs = "EPSG:4326"
        return @native_srs
      end

      if @olayer.layer_srs.first != 'CRS:84'
        @native_srs = @olayer.layer_srs.first
        return @native_srs
      end

      filtered_srs = @olayer.layer_srs.select { |s| s != 'CRS:84' }
      if filtered_srs.any?
        @native_srs = filtered_srs.first
        return @native_srs
      end

      @native_srs = 'EPSG:4326'
      @native_srs
    end

    def bounding_box(srs = 'CRS:84')
      if @olayer.bbox && @olayer.bbox[srs]
        return @olayer.bbox[srs].bbox
      end

      return @olayer.first.bbox
    end
      
    def native_bounding_box
      bounding_box(native_srs)
    end

    def time_dimension
      @olayer.dimensions['time']
    end

    def time_dimension_values
      return [] unless time_dimension && time_dimension.any?
      time_dimension.values
    end
  end
end
