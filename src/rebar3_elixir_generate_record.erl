-module(rebar3_elixir_generate_record).
-behaviour(provider).

-export([init/1,
         do/1,
         format_error/1]).

-define(PROVIDER, generate_record).
-define(DEPS, [{default, compile}]).

-include("../include/rebar3_elixir.hrl").

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
  {ok, rebar_state:add_provider(State, providers:create([{name, ?PROVIDER},
                                                         {module, ?MODULE},
                                                         {namespace, elixir},
                                                         {bare, true},
                                                         {deps, ?DEPS},
                                                         {example, "rebar3 elixir generate_record"},
                                                         {short_desc, "Generate records for Elixir."},
                                                         {desc, "Generate records for Elixir."},
                                                         {opts, []}]))}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
  Apps = case rebar_state:current_app(State) of
           undefined ->
             rebar_state:project_apps(State);
           AppInfo ->
             [AppInfo]
         end,
  [begin
     LibDir = filename:join(rebar_app_info:dir(App), "lib"),
     [generate_records(Mod, LibDir) ||
      Mod <- rebar_state:get(State, elixir_records, [])]
   end || App <- Apps],
  {ok, State}.

-spec format_error(any()) -> iolist().
format_error(Reason) ->
  io_lib:format("~p", [Reason]).

generate_records({ModuleName, Records}, LibDir) ->
  Module = rebar3_elixir_utils:modularize(ModuleName),
  LibFile = filename:join(LibDir, Module ++ ".ex"),
  IO = case filelib:ensure_dir(LibFile) of
         ok ->
           case file:open(LibFile, [write]) of
             {ok, IO0} ->
               rebar_api:info("Generate ~s", [LibFile]),
               IO0;
             {error, Reason1} ->
               rebar_api:abort("Can't create file ~s: ~p", [LibFile, Reason1])
           end;
         {error, Reason2} ->
           rebar_api:abort("Can't create ~s: ~p", [LibDir, Reason2])
       end,
  io:format(IO, "# File: ~s.ex\n", [Module]),
  io:format(IO, "# This file was generated by rebar3_elixir (https://github.com/G-Corp/rebar3_elixir)\n", []),
  io:format(IO, "# MODIFY IT AT YOUR OWN RISK AND ONLY IF YOU KNOW WHAT YOU ARE DOING!\n", []),
  io:format(IO, "defmodule ~s do\n", [Module]),
  io:format(IO, "  require Record\n", []),
  io:format(IO, "  import Record, only: [defrecord: 2, extract: 2]\n\n", []),
  [io:format(IO, "  defrecord :~s, extract(:~s, from_lib: \"~s\")\n", [Record, Record, Include]) ||
   {Record, Include} <- Records],
  io:format(IO, "end\n", []),
  file:close(IO).
