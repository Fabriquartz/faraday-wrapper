# frozen_string_literal: true

class PlonquoFaradayWrapper
  require 'faraday'
  require 'json'
  attr_accessor :conn
  attr_accessor :token
  attr_accessor :user

  def initialize(url)
    raise ArgumentError, 'Please enter url without a trailing /' if url.end_with?('/')

    @conn = Faraday.new(url: url)
  end

  def authenticate(options = {})
    return authenticate_by_token(options[:token]) if options.key?(:token)
    return authenticate_by_credentials(options[:username], options[:password]) if options.key?(:username) && options.key?(:password)

    raise ArgumentError, 'No access token or  (complete)  login credentials found in options hash'
  end

  def get(path, options = {})
    response = conn.get do |req|
      req.url path
      req.headers['Content-Type'] = options[:content_type] || 'application/json'
      req.headers['Authorization'] = @token
      options[:params]&.each do |param, value|
        req.params[param] = value
      end
    end
    check_auth(response)
    attributes = JSON.parse(response.body)['data']
    create_hash(attributes)
  end

  def post(path, options = {})
    raise StandardError, 'Not authenticated, use the authenticate method to login by token or credentials' if @token.nil? || @token.empty?

    response = conn.post do |req|
      req.url path
      req.headers['Content-Type'] = options[:content_type] || 'application/json'
      req.headers['Authorization'] = @token
      options[:headers]&.each do |param, value|
        req.headers[param] = value
      end
      req.body = options[:body]
      options[:params]&.each do |param, value|
        req.params[param] = value
      end
    end
    check_auth(response)
    attributes = JSON.parse(response.body)['data']
    create_hash(attributes)
  end

  private

  def check_auth(response = nil)
    raise StandardError, 'Not authenticated, use the authenticate method to login by token or credentials' if @token.nil? || @token.empty?

    unless response
      raise StandardError, 'Unauthorized are you sure  your token or credentials are still valid?' if response.status == 401
    end
  end

  def authenticate_by_token(token)
    raise ArgumentError, 'Please enter token beginning with \'Basic\' ' unless token.start_with?('Basic')

    response = conn.get do |req|
      req.url '/users/current'
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = token
    end

    if response.status == 200
      attributes = JSON.parse(response.body)['data']['attributes']
      @user = create_hash(attributes)
      @token = token
      return @user
    end
    raise StandardError, 'Invalid token or credentials: could not authenticate user.'
  end

  def authenticate_by_credentials(username, password)
    authenticate_by_token(@conn.basic_auth(username, password))
  end

  def create_hash(attributes)
    user_hash = {}
    attributes.each do |key, value|
      user_hash[key] = value
    end
    user_hash
  end
end
