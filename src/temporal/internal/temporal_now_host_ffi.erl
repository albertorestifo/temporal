-module(temporal_now_host_ffi).

-export([epoch_milliseconds/0, local_offset_minutes/0]).

epoch_milliseconds() ->
    erlang:system_time(millisecond).

%% The local time is derived from a single universal reading so the two values
%% cannot straddle a second boundary.
local_offset_minutes() ->
    Universal = calendar:universal_time(),
    Local = calendar:universal_time_to_local_time(Universal),
    UniversalSeconds = calendar:datetime_to_gregorian_seconds(Universal),
    LocalSeconds = calendar:datetime_to_gregorian_seconds(Local),
    (LocalSeconds - UniversalSeconds) div 60.
