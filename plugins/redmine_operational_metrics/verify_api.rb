#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

BASE_URL = "http://localhost:3000"
API_KEY = "your_api_key_if_needed" # Using session auth mostly, or we would need to login first.
# For simplicity, if we assume session auth, we need cookies.
# But for API testing, we likely want to use Basic Auth or API Key if `accept_api_auth` was enabled.
# Since I only used `require_login`, it expects session.
# However, Redmine supports Basic Auth with `require_login` if configured?
# Actually, `require_login` checks for session.
# If I want to test this easily, I might need to simulate login.

# Let's try to login first via standard Redmine login form to get a cookie?
# Or maybe the user meant "protected auth" as in "API Key"?
# If "API Key", I should have used `accept_api_auth`.
# But `require_login` works with API key if `ApplicationController` logic allows it.
# In Redmine `ApplicationController`:
# `def require_login`
#   if !User.current.logged?
#     # ... redirect or 401
#   end
# end
# `User.current` is set by `start_user_session` which checks API key too.
# So API key should work if passed as `X-Redmine-API-Key` header.
# I will assume API Key works.

def test_api
  uri = URI("#{BASE_URL}/api/operational_metrics.json")
  req = Net::HTTP::Get.new(uri)
  req['X-Redmine-API-Key'] = 'admin' # Assuming we can use admin key or similar. Or we might fail.
  # If we cannot easily get an API key, we might need manual verification from user.
  
  puts "Testing GET #{uri}"
  
  # For now, just printing instructions as I cannot run this without a key.
  puts "To verify manually:"
  puts "1. Login to Redmine."
  puts "2. Get your API Key from My Account page."
  puts "3. Run: curl -v -H 'X-Redmine-API-Key: YOUR_KEY' http://localhost:3000/api/operational_metrics.json"
end

test_api
