module CustomGrape
  module Util
    def merge_includes(first_data, second_data)
      first_array = first_data.is_a?(Array) ? first_data : [first_data]
      second_array = second_data.is_a?(Array) ? second_data : [second_data]

      (first_array.inject({}) do |hash, element|
        if element.is_a?(Hash)
          element.each { |key, value| hash[key] = value }
        else
          hash[element] = true
        end

        hash
      end).merge(
        second_array.inject({}) do |hash, element|
        if element.is_a?(Hash)
          element.each { |key, value| hash[key] = value }
        else
          hash[element] = true
        end

        hash
      end) do |key, first_value, second_value|
        if first_value == true
          second_value
        elsif second_value == true
          first_value
        else
          merge_except(first_value, second_value)
        end
      end.inject([]) do |array, hash_array|
        key, value = hash_array

        if value == true
          array << key
        else
          array << { key => value }
        end

        array
      end
    end

    def merge_except(first_data, second_data)
      first_array = first_data.is_a?(Array) ? first_data : [first_data]
      second_array = second_data.is_a?(Array) ? second_data : [second_data]

      (first_array.inject({}) do |hash, element|
        if element.is_a?(Hash)
          element.each { |key, value| hash[key] = value }
        else
          hash[element] = true
        end

        hash
      end).merge(
        second_array.inject({}) do |hash, element|
        if element.is_a?(Hash)
          element.each { |key, value| hash[key] = value }
        else
          hash[element] = true
        end

        hash
      end) do |key, first_value, second_value|
        first_value == true || second_value == true ? true : merge_except(first_value, second_value)
      end.inject([]) do |array, hash_array|
        key, value = hash_array

        if value == true
          array << key
        else
          array << { key => value }
        end

        array
      end
    end

    def merge_only(first_array, second_array)
      first_array.inject([]) do |array, element|
        if element.is_a?(Hash)
          element.keys.each do |key|
            second_array.each do |second_array_element|
              if second_array_element.is_a?(Hash)
                array << { key => merge_only(element[key], second_array_element[key]) } and break if second_array_element[key]
              else
                array << element and break if key == second_array_element
              end
            end
          end
        else
          second_array.each do |second_array_element|
            if second_array_element.is_a?(Hash)
              second_array_element_array = second_array_element.detect { |key, _| element == key }

              array << { second_array_element_array[0] => second_array_element_array[1] } and break if second_array_element_array
            else
              array << element and break if element == second_array_element
            end
          end
        end

        array
      end
    end
  end
end
