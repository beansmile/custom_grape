module CustomGrape
  class Includes
    attr_accessor :entity_name, :includes, :only, :except, :children_entities
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

    def initialize(attrs = {})
      @entity_name = attrs[:entity_name]
      @includes = {}
      @children_entities = {}
      @only = {}
      @except = {}
    end

    # 参数
    # - cache
    # - only
    # - except
    def fetch_includes(options = {})
      options.reverse_merge!({
        only: nil,
        except: nil
      })

      array = includes.values.flatten
      array += children_entities.select { |_, value| value[:includes] }.select do |key, _|
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
        { key => (data[:entity].includes(only: only[key], except: except[key]) || []) }
      end

      array += super_entity.includes(options)
    end
  end
end

