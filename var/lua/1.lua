local http_request = require "http.request"

local url = "http://localhost:3000/loko";

local headers, stream = assert(http_request.new_from_uri(url):go())
local body = assert(stream:get_body_as_string())
if headers:get ":status" ~= "200" then
    error(body)
end
print(body)