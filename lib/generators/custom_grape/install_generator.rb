# frozen_string_literal: true


module CustomGrape
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_template
        template("../templates/custom.rb", "lib/custom_grape/custom.rb")
      end
    end
  end
end
