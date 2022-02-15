module CustomGrape
  class Data
    extend Util

    attr_accessor :entity_name, :extra
    mattr_accessor :collection, default: {}

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
      @extra = {}
    end

    # 参数
    # - only
    # - except
    def fetch_includes(options = {})
      options.reverse_merge!({
        only: nil,
        except: nil
      })

      array = extra.select do |key, _|
        flag = if options[:only].present? && options[:except].present?
                 options[:only].include?(key) && !options[:except].include?(key)
               elsif options[:only].present?
                 options[:only].include?(key) || options[:only].any? { |element| element.is_a?(Hash) && element.detect { |k, _| key == k } }
               elsif options[:except].present?
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

        arr = []

        if data[:includes].is_a?(Hash)
          arr += handle_hash_includes(data[:includes], only: options_only, except: options_except)
        elsif data[:includes].is_a?(Array)
          arr += handle_array_includes(data[:includes], only: options_only, except: options_except)
        else
          arr << data[:includes]
        end

        arr
      end

      array.inject([]) do |merged_array, element|
        merged_array = self.class.merge_includes(element, merged_array)
      end
    end

    def handle_hash_includes(hash, only:, except:)
      arr = []

      hash.map do |key, value|
        if value.is_a?(Array)
          arr += [{ key => handle_array_includes(value, only: only, except: except) }]
        elsif value.is_a?(Hash)
          arr += handle_hash_includes(value, only: only, except: except)
        else
          result = value.respond_to?(:includes) ? value.includes(only: only, except: except) : value

          arr << (result.blank? ? key : { key => result })
        end
      end

      arr
    end

    def handle_array_includes(array, only:, except:)
      array.inject([]) do |arr, element|
        if element.is_a?(Array)
          arr += handle_array_includes(element, only: only, except: except)
        elsif element.is_a?(Hash)
          arr += handle_hash_includes(element, only: only, except: except)
        else
          result = (element.respond_to?(:includes) ? element.includes(only: only, except: except) : element)
          arr << result if result.present?
        end

        arr
      end
    end
  end
end

