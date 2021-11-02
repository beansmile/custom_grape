module CustomGrape
  class Includes
    attr_accessor :entity_name, :includes, :children_includes, :only, :except
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
      @includes = {}
      @children_includes = {}
      @only = {}
      @except = {}
    end

    # 参数
    # - cache
    # - only
    # - except
    def fetch_includes(options = {})
      options.reverse_merge!({
        cache: false,
        only: nil,
        except: nil
      })

      options_dup = options.dup
      cache = options_dup.delete(:cache)

      signature = ActiveSupport::Digest.hexdigest(options_dup.sort.to_s)
      cache_key = "custom_grape/includes:#{entity_name.underscore}-#{signature}".to_sym

      return self.class.includes_cache[cache_key] if cache && !self.class.includes_cache[cache_key].nil?

      self.class.includes_cache[cache_key] = includes.values.flatten

      self.class.includes_cache[cache_key] += children_includes.select do |key, _|
        flag = if options[:only] && options[:except]
                 options[:only].include?(key) && !options[:except].include?(key)
               elsif options[:only]
                 options[:only].include?(key)
               elsif options[:except]
                 !options[:except].include?(key)
               else
                 true
               end

        flag
      end.map do |key, data|
        { key => (CustomGrape::Includes.fetch(data[:entity_name])&.fetch_includes(cache: cache, only: only[key], except: except[key]) || []) }
      end

      self.class.includes_cache[cache_key] += self.class.fetch(super_entity_name)&.fetch_includes(options) || []
    end
  end
end

