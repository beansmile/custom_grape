# frozen_string_literal: true

module Bean
  module Stock
    module Splitter
      class Base
        attr_reader :packer, :next_splitter

        # constants

        # concerns

        # attr related macros
        delegate :stock_location, to: :packer

        # association macros

        # validation macros

        # callbacks

        # other macros

        # scopes

        # class methods

        # instance methods
        def initialize(packer, next_splitter = nil)
          @packer = packer
          @next_splitter = next_splitter
        end

        def split(packages)
          return_next(packages)
        end

        private

        def return_next(packages)
          next_splitter ? next_splitter.split(packages) : packages
        end

        def build_package(contents = [])
          Bean::Stock::Package.new(stock_location, contents)
        end
      end
    end
  end
end
