module StyleCop
  require 'style_cop/assert_style'
  require 'style_cop/register_style'
  require 'style_cop/public_methods'
end

RSpec.configure do |c|
  c.include StyleCop::PublicMethods, type: :feature
end

