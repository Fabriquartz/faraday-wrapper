# frozen_string_literal: true

class PlonquoFaradayWrapper
  require 'faraday'
  require 'json'
  attr_accessor :conn
  attr_accessor :token
  attr_accessor :user
  attr_accessor :no_auth_required

  METHODS = %i[post get put patch delete].freeze

  METHODS.each do |method|
    define_method(method) do |*args|
      check_auth
      response = conn.send(method) do |req|
        path = args[0]
        options = args[1] || {}
        req.url path
        req.options.timeout = options[:timeout] || 30
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
      return response.status if response.body.empty?

      begin
        attributes = JSON.parse(response.body)
        create_hash(attributes)
      rescue JSON::ParserError
        { error: 'Could not parse response to json', response_body: response.body }
      end
    end
  end

  def initialize(url, options = {})
    @conn = Faraday.new(url: url)
    @no_auth_required = options[:no_auth_required] || false
  end

  def authenticate(options = {})
    return authenticate_by_token(options[:token]) if options.key?(:token)
    return authenticate_by_credentials(options[:username], options[:password]) if options.key?(:username) && options.key?(:password)

    raise ArgumentError, 'No access token or (complete) login credentials found in options hash'
  end

  def request(method, options = {})
    check_options(method, options)
    conn.send(method) do |req|
      req.url options[:path]
      req.options.timeout = options[:timeout] || 30
      options[:headers]&.each do |param, value|
        req.headers[param] = value
      end

      req.body = options[:body]
      options[:params]&.each do |param, value|
        req.params[param] = value
      end
    end
  end

  private

  def check_options(method, options)
    raise ArgumentError, 'Please define post or get in the method call' unless method == 'post' || method == 'get'
    raise ArgumentError, 'Please define a path in the options hash to call' if options[:path].nil? || options[:path].empty?
  end

  def check_auth(response = nil)
    unless response.nil?
      raise StandardError, 'Unauthorized, are you sure  your token or credentials are still valid?' if response.status == 401
    end
    return if @no_auth_required
    raise StandardError, 'Not authenticated, use the authenticate method to login by token or credentials' if @token.nil? || @token.empty?
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
