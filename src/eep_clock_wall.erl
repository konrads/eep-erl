%% -------------------------------------------------------------------
%% Copyright (c) 2013 Darach Ennis < darach at gmail dot com > 
%%
%% Permission is hereby granted, free of charge, to any person obtaining a
%% copy of this software and associated documentation files (the
%% "Software"), to deal in the Software without restriction, including
%% without limitation the rights to use, copy, modify, merge, publish,
%% distribute, sublicense, and/or sell copies of the Software, and to permit
%% persons to whom the Software is furnished to do so, subject to the
%% following conditions:
%%
%% The above copyright notice and this permission notice shall be included
%% in all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
%% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
%% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
%% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
%% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
%% USE OR OTHER DEALINGS IN THE SOFTWARE.
%%
%% File: eep_clock_wall.erl. Wall clock, erlang:now/0 based, millisecond
%% tick resolution.
%%
%% -------------------------------------------------------------------

-module(eep_clock_wall).

-include_lib("eep_erl.hrl").

-behaviour(eep_clock).

%% clock behaviour.
-export([name/0]).
-export([at/1]).
-export([new/1]).
-export([inc/1]).
-export([tick/1]).
-export([tock/2]).

%% impl
-export([ts/0]).

name() -> crock.

at(State) -> 
 State#eep_clock.at.

new(Interval) ->
  At = ts(),
  Mark = At + Interval,
  #eep_clock{at = At, interval = Interval, mark=Mark}.

inc(State) -> 
  State#eep_clock{at = ts()}.

tick(State) ->
  NewState = inc(State),
  {(NewState#eep_clock.at - NewState#eep_clock.mark) >= 0, NewState}.

tock(State, Elapsed) ->
  Delta = State#eep_clock.at - Elapsed,
  case Delta >= State#eep_clock.interval of
    true -> {true, State#eep_clock{mark = State#eep_clock.mark + State#eep_clock.interval}};
    false -> {false, State}
  end.

ts() ->
  {MegaSecs,Secs,MicroSecs} = erlang:now(),
  erlang:round((MegaSecs*1000000 + Secs)*1000 + (MicroSecs/1000)).
