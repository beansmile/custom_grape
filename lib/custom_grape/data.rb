module CustomGrape
  class Data
    extend Util

    attr_accessor :entity_name, :includes, :children_entities
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

      # TODO only except
      array = includes.values.flatten
      array += children_entities.select { |_, value| value[:includes] }.select do |key, _|
        flag = if options[:only] && options[:except]
                 options[:only].include?(key) && !options[:except].include?(key)
               elsif options[:only]
                 options[:only].include?(key) || options[:only].any? { |element| element.is_a?(Hash) && element.detect { |k, _| key == k } }
               elsif options[:except]
                 !options[:except].include?(key)
               else
                 true
               end

        flag
      end.map do |key, data|
        options_except = []
        options_only = nil

        if options[:except]
          options[:except].each do |element|
            if element.is_a?(Hash)
              array = element.detect { |k, _| key == k }
              options_except = array[1] and break if array
            end
          end
        end

        if options[:only]
          options[:only].each do |element|
            if element.is_a?(Hash)
              array = element.detect { |k, _| key == k }
              options_only = array[1] and break if array
            end
          end
        end

        merged_except = self.class.merge_except(options_except, data[:except])
        merged_only = if options_only && data[:only]
                        self.class.merge_only(options_only, data[:only])
                      elsif options_only
                        options_only
                      else
                        data[:only]
                      end

        { data[:name].to_sym => (data[:entity].includes(only: merged_only, except: merged_except) || []) }
      end

      array
    end
  end
end

