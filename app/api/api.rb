class API < Grape::API
  prefix 'api'
  version 'v1'
  logger Rails.logger
  rescue_from :all, :backtrace => true
  error_formatter :json, API::ErrorFormatter
  format :json
  use ApiLogger

  mount V1::GroupEvents

end
