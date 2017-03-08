local inspect = require "inspect";
local httpclient = require "httpclient"
local JSON = require "JSON"

local httprequest = function (context, extension)
    
    local hc = httpclient.new();
    local t1 = os.clock();

    local authurl = 'http://192.168.1.41:3030/auth/local';
    
    local headers = {
        ['content-type'] = "application/json";
    };

    local postdata = {
        ['type'] = "local";
        ['password'] = "pulivu";
        ['phone'] = "9135292926";
    }

    local d = JSON:encode(postdata);
    app.noop("json:"..d);
    local res = hc:post(authurl, d, {content_type = "application/json"});


    app.noop("post: "..inspect(res));


    local token = JSON:decode(res.body).token;

    -- local url = "http://192.168.1.41:3000/trunk";
    local url = 'http://192.168.1.41:3030/payments';
    -- local token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwiaWF0IjoxNDg4OTUxODQwLCJleHAiOjE0ODkwMzgyNDAsImlzcyI6ImZlYXRoZXJzIn0.1Ysfrc-JCN9o1vyltxZbnGFLO4AL62zfwofU5oD5QU0";




    app.noop('url: '..url);
    local headers = {
        authorization = token;
    };

    
    local res = hc:get(url, {headers = headers});


    if res.body then
      app.noop(res.body);
    else
      app.noop(res.err);
    end;

    local lua_value = JSON:decode(res.body);
    app.noop(inspect(lua_value));

    app.noop('difftime: '..tostring(os.clock() - t1));
end


return httprequest;