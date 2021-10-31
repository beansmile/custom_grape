module CustomGrape
  class Includes
    attr_accessor :entity_name, :includes, :children_includes
    mattr_accessor :collection, default: {}
    mattr_accessor :includes_cache, default: {}

    def self.build(entity_name)
      object = new(entity_name: entity_name)
      collection[entity_name] = object
    end

    def self.fetch(entity_name)
      collection[entity_name]
    end

    def entity
      @entity ||= entity_name.constantize
    end

    def super_entity
      @super_entity ||= entity.superclass
    end

    def super_entity_name
      @super_entity_name ||= super_entity.name
    end

    def initialize(attrs = {})
      @entity_name = attrs[:entity_name]
      @includes = []
      @children_includes = {}
    end

    def fetch_includes(cache: false)
      cache_key = "custom_grape/includes:#{entity_name.underscore}".to_sym

      return self.class.includes_cache[cache_key] if cache && !self.class.includes_cache[cache_key].nil?

      self.class.includes_cache[cache_key] = (includes + children_includes.map do |key, data|
        { key => (CustomGrape::Includes.fetch(data[:entity_name])&.fetch_includes(cache: cache) || []) }
      end) + (self.class.fetch(super_entity_name)&.fetch_includes || [])
    end
  end
end

