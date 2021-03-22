# frozen_string_literal: true

module ApplicationHelper
  def sanitize_rich_text(text)
    Sanitize.fragment(text, Sanitize::Config.merge(
      Sanitize::Config::RELAXED,
      elements: Sanitize::Config::RELAXED[:elements] + ["video", "img", "link", "iframe"],
      attributes: {
        "video" => ["src", "controls", "style", "width", "height"],
        "img" => ["src", "style", "data", "data-lazy"],
        "a" => ["href", "hreflang", "name", "rel", "data-slide", "target"],
        "link" => ["href", "rel", "media"]
      },
      protocols: {
        # adding data to image_src attributes
        # for supporting base64 image src
        # https://github.com/rgrove/sanitize/issues/149#issuecomment-211478312
        "img" => { "src" => ["http", "https", :relative, "data"] },
        "video" => { "src" => ["http", "https"] }
      }
    )).html_safe
  end
end
