-module(rebar3_elixir_generate_lib).

-behaviour(provider).

-export([init/1,
         do/1,
         format_error/1]).

-define(PROVIDER, generate_lib).
-define(DEPS, [{default, compile}]).

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
  {ok, rebar_state:add_provider(State, providers:create([{name, ?PROVIDER},
                                                         {module, ?MODULE},
                                                         {namespace, elixir},
                                                         {bare, true},
                                                         {deps, ?DEPS},
                                                         {example, "rebar3 elixir generate_lib"},
                                                         {short_desc, "Generate Elixir bindings."},
                                                         {desc, "Generate Elixir bindings."},
                                                         {opts, []}]))}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
  rebar_api:info("Generate Elixir bindings", []),
  {ok, State}.

-spec format_error(any()) -> iolist().
format_error(Reason) ->
  io_lib:format("~p", [Reason]).
