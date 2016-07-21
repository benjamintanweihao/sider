defmodule Sider.API.Helper do

  defmacro defredis(cmd, args) when is_atom(cmd) and is_list(args) do
    cmd_name = Atom.to_string(cmd) |> String.upcase
    margs    = args |> Enum.map(&({&1, [], Sider.API.Helper}))

    quote do
      def unquote(cmd)(client, unquote_splicing(margs)) do
        Sider.query(client, [unquote(cmd_name)|unquote(margs)] |> List.flatten)
      end
    end
  end

end

defmodule Sider.API do
  import Sider.API.Helper

  defredis :append,       [:key, :value]
  defredis :bitcount,     [:key]
  defredis :bitcount,     [:key, :start, :end]
  defredis :dbsize,       []
  defredis :decr,         [:key]
  defredis :decrby,       [:key, :decrement]
  defredis :flushall,     []
  defredis :flushdb,      []
  defredis :get,          [:key]
  defredis :getbit,       [:key, :offset]
  defredis :getrange,     [:key, :start, :end]
  defredis :getset,       [:key, :value]
  defredis :hdel,         [:key, :field]
  defredis :hexists,      [:key, :field]
  defredis :hget,         [:key, :field]
  defredis :hgetall,      [:key]
  defredis :hincrby,      [:key, :field, :increment]
  defredis :hincrbyfloat, [:key, :field, :increment]
  defredis :hkeys,        [:key]
  defredis :hlen,         [:key]
  defredis :hset,         [:key, :field, :value]
  defredis :incr,         [:key]
  defredis :lastsave,     []
  defredis :sadd,         [:key, :member]
  defredis :set,          [:key, :value]
  defredis :setbit,       [:key, :offset, :value]
  defredis :sdiff,        [:key]
  defredis :sdiffstore,   [:destination, :key]

end
