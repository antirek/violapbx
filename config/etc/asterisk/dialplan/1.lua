local inspect = require "inspect";
local httpclient = require "httpclient"
local JSON = require "JSON"
local redis = require 'redis'

local rclient = redis.connect('127.0.0.1', 6379)

local resurl = 'http://192.168.1.41:3030/';

local jwtrequest = function (tokenIn)

    local hc = httpclient.new();
    local authenticated = false;
    local token = tokenIn;

    local authByLoginPassword = function ()
        local authurl = resurl .. 'auth/local';

        local postdata = {
            ['type'] = "local";
            ['password'] = "pulivu";
            ['phone'] = "9135292926";
        };

        local data = JSON:encode(postdata);
        app.noop("json:"..data);

        local res = hc:post(authurl, data, {content_type = "application/json"});
        app.noop("post: "..inspect(res));

        local token = JSON:decode(res.body).token;
        
        return token;
    end

    local makeRequest = function ()
        local url = resurl .. 'payments';
        app.noop('url: '..url);

        local headers = {
            authorization = token;
        };

        local res = hc:get(url, {headers = headers});


        return res;
    end;
    
    local res = makeRequest()

    app.noop('rees:'..inspect(res));
    app.noop('code:'..inspect(res.code))

    if res.code == 401 then 
       token = authByLoginPassword()
       res = makeRequest()
    end;
    
    return res, token;
    
end;


local httprequest = function (context, extension)
    
    
    local t1 = os.clock();

    local t = rclient:get('token');

--    local t = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwiaWF0IjoxNDg4OTUxODQwLCJleHAiOjE0ODkwMzgyNDAsImlzcyI6ImZlYXRoZXJzIn0.1Ysfrc-JCN9o1vyltxZbnGFLO4AL62zfwofU5oD5QU0";
    local res, token = jwtrequest(t);

    rclient:set('token', token);

    app.noop('response:'..inspect(res));

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