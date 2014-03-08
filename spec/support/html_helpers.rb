module HtmlHelpers
  def create_html(options = {})
    %{<html>
      <head>
        <style>
    #{options[:style]}
        </style>
      </head>
      <body>
    #{options[:body]}
      </body>
    </html>}
  end
end

RSpec.configure do |config|
  config.include(HtmlHelpers)
end
