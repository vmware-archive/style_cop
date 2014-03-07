class FakePage
  def initialize(html)
    @session = Capybara::Session.new(:webkit, TestApp)
    @session.app.set_html(html)
    @session.visit "/"
  end

  def method_missing(method, *args)
    @session.public_send(method, *args)
  end

  class TestApp < Sinatra::Base
    def self.set_html(html)
      @@html = html
    end

    get '/' do
      @@html
    end
  end
end
