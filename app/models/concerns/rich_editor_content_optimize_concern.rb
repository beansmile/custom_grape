# frozen_string_literal: true

module RichEditorContentOptimizeConcern
  extend ActiveSupport::Concern
  included do
    def self.optimize_rich_editor_content(*attrs)
      attrs.each do |attribute|
        define_method "#{attribute}=" do |value|
          self[attribute] = optimize_rich_editor_content(value)
        end
      end
    end
    def optimize_rich_editor_content(value)
      html = Nokogiri::HTML::DocumentFragment.parse(value)
      html.elements.each do |element|
        element.add_class "_#{element.name}"
        optimize_rich_editor_element_content(element)
      end
      html.to_html
    end
    def optimize_rich_editor_element_content(element)
      element.children&.to_a&.each do |node|
        node.add_class "_#{node.name}"
        # 递归处理所有子节点
        optimize_rich_editor_element_content(node) if node.children.present?
      end
    end
  end
end
