local inspect = require "inspect";
local httpclient = require "httpclient"
local JSON = require "JSON"
local redis = require 'redis'

local rclient = redis.connect('127.0.0.1', 6379)


local jwtClient = function (params)
    assert(params.password);
    assert(params.resurl);
    assert(params.phone);
    -- @todo: добавить опцию дебага

    local hc = httpclient.new();
    local token = nil;

    local authByLoginPassword = function ()
        local authurl = params.resurl .. 'auth/local';

        local postdata = {
            ['type'] = "local";
            ['password'] = params.password;
            ['phone'] = params.phone;
        };

        local data = JSON:encode(postdata);
        app.noop("json:"..data);

        local res = hc:post(authurl, data, {content_type = "application/json"});
        app.noop("post: "..inspect(res));

        local token = JSON:decode(res.body).token;
        
        return token;
    end;

    local makeRequest = function (req)
        local url = params.resurl .. req;
        app.noop('url: '..url);

        local headers = {
            authorization = token;
        };

        return hc:get(url, {headers = headers});
    end;
    
    local request = function (resource, tokenIn)
        token = tokenIn or token;   -- токен может сохраниться от предыдущего запроса

        local res = makeRequest(resource)

        -- app.noop('rees:'..inspect(res));
        -- app.noop('code:'..inspect(res.code))

        if res.code == 401 then 
           token = authByLoginPassword()
           res = makeRequest(resource)
        end;

        return token, res;
    end
    
    return {
        request = request;
    };

end;





local httprequest = function (context, extension)
    local params = {
        resurl = 'http://192.168.1.41:3030/';
        phone = '9135292926';
        password = 'pulivu'
    };
    
    local t1 = os.clock();

    local t = rclient:get('token');

--    local t = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwiaWF0IjoxNDg4OTUxODQwLCJleHAiOjE0ODkwMzgyNDAsImlzcyI6ImZlYXRoZXJzIn0.1Ysfrc-JCN9o1vyltxZbnGFLO4AL62zfwofU5oD5QU0";
    local client = jwtClient(params);

    token, res = client.request('payments', t);
    app.noop('r1'..inspect(token))

    token, res = client.request('payments');
    app.noop('r2'..inspect(token))

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