local https = require "ssl.https";
local inspect = require "inspect";

local request = require('/etc/asterisk/dialplan/1');

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

local ssl = function (context, extension)

    local body, code, headers, status = https.request({
        url = "https://requestb.in/yd4qv8yd";
        protocol = "tlsv1_1"
    });
    
    app.noop('check:'..inspect({body, code, headers, status}));
    app.hangup();

end;


local Dialplan = {
    getExtensions = function ()
        return {
            ["internal"] = {
                ["*12"] = function ()
                    app.sayunixtime();
                end;

                ["_100"] = request;

                ["_1XX"] = dial;

                ["200"] = ivr;

                ["300"] = ssl;
            };           
        };
    end;

    getHints = function ()
        return {

        };
    end;
};

return Dialplan;