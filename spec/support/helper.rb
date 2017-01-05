module Helper
  include Rack::Test::Methods

  def app
    APP
  end

  def json_body
    JSON.parse(last_response.body, symbolize_names: true)
  end
end
