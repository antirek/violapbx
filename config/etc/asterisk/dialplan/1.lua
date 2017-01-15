local inspect = require "inspect";
local httpclient = require "httpclient"
local JSON = require "JSON"

local httprequest = function (context, extension)

    local t1 = os.clock();

    local url = "http://192.168.1.41:3000/trunk";

    local hc = httpclient.new();
    local res = hc:get(url);

    if res.body then
      print(res.body);
    else
      print(res.err);
    end;

    local lua_value = JSON:decode(res.body);
    app.noop(inspect(lua_value));

    app.noop('difftime: '..tostring(os.clock() - t1));
end


return httprequest;