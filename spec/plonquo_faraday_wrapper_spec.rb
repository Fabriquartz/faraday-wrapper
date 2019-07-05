require './lib/plonquo_faraday_wrapper.rb'
describe PlonquoFaradayWrapper do
  it 'initailizes a faraday instance with the correct url' do
    wrapper = PlonquoFaradayWrapper.new('https://json-api-staging.rail.io/')
    expect(wrapper.conn.url_prefix.to_s).to eq 'https://json-api-staging.rail.io/'
  end

  it 'raises a error when no token or credentials are given' do
    wrapper = PlonquoFaradayWrapper.new('https://json-api-staging.rail.io/')
    expect { wrapper.authenticate }.to raise_error(ArgumentError, 'No access token or (complete) login credentials found in options hash')
  end

  it 'raises a error when partial credentials are given' do
    wrapper = PlonquoFaradayWrapper.new('https://json-api-staging.rail.io/')
    expect { wrapper.authenticate(username: 'cedric.remond@fabriquartz.nl') }.to raise_error(ArgumentError, 'No access token or (complete) login credentials found in options hash')
  end

  it 'raises a error when the get method is called without being authenticated' do
    wrapper = PlonquoFaradayWrapper.new('https://json-api-staging.rail.io/')
    expect { wrapper.get('/users') }.to raise_error(StandardError, 'Not authenticated, use the authenticate method to login by token or credentials')
  end

  it 'raises a error when the post method is called without being authenticated' do
    wrapper = PlonquoFaradayWrapper.new('https://json-api-staging.rail.io/')
    expect { wrapper.post('/users') }.to raise_error(StandardError, 'Not authenticated, use the authenticate method to login by token or credentials')
  end

  it 'raises a error when the request method is called without being post or get defined' do
    wrapper = PlonquoFaradayWrapper.new('https://json-api-staging.rail.io/')
    options = { url: 'http://localhost:3000/', path: '/users/current', headers: { 'Content-Type': 'application/json', Authorization: 'Basic Y2VkcmljLnJlbW9uZEBmYWJyaXF1YXJ0ei5jb206V2FhbG5vcmQxMDIx' } }
    expect { wrapper.request(options) }.to raise_error(ArgumentError, 'Please define post or get in the method call')
  end

  it 'raises a error when the request method is called without being post or get defined' do
    wrapper = PlonquoFaradayWrapper.new('https://json-api-staging.rail.io/')
    options = { url: 'http://localhost:3000/', path: '/users/current', headers: { 'Content-Type': 'application/json', Authorization: 'Basic Y2VkcmljLnJlbW9uZEBmYWJyaXF1YXJ0ei5jb206V2FhbG5vcmQxMDIx' } }
    expect { wrapper.request(options) }.to raise_error(ArgumentError, 'Please define post or get in the method call')
  end

  it 'raises a error when the request method is called without a path in the options hash' do
    wrapper = PlonquoFaradayWrapper.new('https://json-api-staging.rail.io/')
    options = { url: 'http://localhost:3000/', headers: { 'Content-Type': 'application/json', Authorization: 'Basic Y2VkcmljLnJlbW9uZEBmYWJyaXF1YXJ0ei5jb206V2FhbG5vcmQxMDIx' } }
    expect { wrapper.request('post', options) }.to raise_error(ArgumentError, 'Please define a path in the options hash to call')
  end
end
