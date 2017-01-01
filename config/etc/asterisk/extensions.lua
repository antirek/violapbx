local inspect = require "inspect";
local http_request = require "http.request"
local JSON = require "JSON"

local dial = function (context, extension)
    app.noop("context: " .. context .. ", extension: " .. extension);
    app.dial('SIP/' .. extension, 10);
    
    local dialstatus = channel["DIALSTATUS"]:get();
    app.noop('dialstatus: '..dialstatus);
    app.set("CHANNEL(language)=ru");

    if dialstatus == 'BUSY' then
        app.playback("followme/sorry");        
    elseif dialstatus == 'CHANUNAVAIL' then 
        app.playback("followme/sorry");
    end;

    app.hangup();
end;

local ivr = function (context, extension)        
    app.read("IVR_CHOOSE", "/var/menu/demo", 1, nil, 2, 3);
    local choose = channel["IVR_CHOOSE"]:get();

    if choose == '1' then
        app.queue('1234');
    elseif choose == '2' then
        dial('internal', '101');
    else
        app.hangup();
    end;
end;

local httprequest = function (context, extension)
    
    local t1 = os.clock();
    
    local url = "http://localhost:3000/loko";

    local headers, stream = assert(http_request.new_from_uri(url):go())
    local body = assert(stream:get_body_as_string())
    if headers:get ":status" ~= "200" then
        error(body)
    end
    local lua_value = JSON:decode(body)
    app.noop(inspect(lua_value))

    app.noop('difftime: '..tostring(os.clock() - t1));
end

extensions = {
    ["internal"] = {

        ["*12"] = function ()
            app.sayunixtime();
        end;

        ["100"] = httprequest;

        ["_1XX"] = dial;


        ["200"] = ivr;

        ["_NXXXXXX"] = outgoing_route_function;
    };
};

hints = {};