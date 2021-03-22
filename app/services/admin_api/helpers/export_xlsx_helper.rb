# frozen_string_literal: true

module AdminAPI::Helpers
  module ExportXlsxHelper
    def export_xlsx(result, model_name, title = "")
      initialize_data
      @result, @title, @model = result, title, Object.const_get(model_name)
      @wb.add_worksheet(name: title) do |sheet|
        add_content(sheet)
      end

      stream_file
    end

    def initialize_data
      content_type "application/octet-stream"
      header "Content-Transfer-Encoding", "binary"
      @file = ::Tempfile.new("temp")
      @package = ::Axlsx::Package.new
      @wb = @package.workbook
    end

    def stream_file
      @package.use_shared_strings = true
      @package.serialize(@file)
      stream @file
    end

    def add_content(sheet)
      add_header(sheet)
      add_body(sheet)
    end

    def sheet_style(options = {})
      @sheet_style = @wb.styles.add_style(
        { alignment: { horizontal: :center, vertical: :center, wrap_text: true } }.merge(options)
      )
    end

    def add_header(sheet)
      add_title(sheet) if @title.present?

      if @result.first
        sheet.add_row @result.first.pluck(:name).map { |key| @model.human_attribute_name(key) }, style: sheet_style
        # 设置每列宽度
        @result.first.pluck(:width).each_with_index do |width, index|
          sheet.column_info[index].width = width
        end
      end
    end

    def add_title(sheet)
      sheet.add_row [@title], height: 20, style: sheet_style
      sheet.merge_cells "A1:#{('A'.ord + @result.first.count - 1).chr}1"
    end

    def add_body(sheet)
      @result.each do |re|
        sheet.add_row re.pluck(:value), style: sheet_style, types: re.pluck(:type)
      end
    end
  end
end
