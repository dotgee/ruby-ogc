require 'forwardable'

module ROGC
  class LayerPresenter
    extend Forwardable

    attr_reader :olayer

    def_delegators :@olayer, :name, :title, :abstract, :bbox

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
      
  end
end
