local inspect = require "inspect";
--local http_request = require "http.request"
local JSON = require "JSON"

local httprequest = function (context, extension)
    
    local t1 = os.clock();
    
    local url = "http://192.168.1.41:3000/loko";

    hc = require('httpclient').new()
    res = hc:get(url)
    if res.body then
      print(res.body)
    else
      print(res.err)
    end

    --[[
    local headers, stream = assert(http_request.new_from_uri(url):go())
    local body = assert(stream:get_body_as_string())
    if headers:get(":status") ~= "200" then
        error(body)
    end;
    ]]
    local lua_value = JSON:decode(res.body);
    app.noop(inspect(lua_value));
    

    app.noop('difftime: '..tostring(os.clock() - t1));
end


return httprequest;