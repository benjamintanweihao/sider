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
  defredis :geoadd,       [:key, :members]
  defredis :geodist,      [:key, :member1, :member2]
  defredis :geohash,      [:key, :members]
  defredis :georadius,    [:key, :longitude, :latitude, :radius, :unit]
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
  defredis :hmget,        [:key, :field]
  defredis :hmset,        [:key, :field]
  defredis :hsetnx,       [:key, :field, :value]
  defredis :hset,         [:key, :field, :value]
  defredis :hstrlen,      [:key, :field]
  defredis :hvals,        [:key]
  defredis :incr,         [:key]
  defredis :incrby,       [:key, :increment]
  defredis :incrbyfloat,  [:key, :increment]
  defredis :lastsave,     []
  defredis :keys,         [:pattern]
  defredis :lindex,       [:key, :index]
  defredis :lpush,        [:key, :value]
  defredis :lpushx,       [:key, :value]
  defredis :lrem,         [:key, :count, :value]
  defredis :lrange,       [:key, :start, :stop]
  defredis :lset,         [:key, :index, :value]
  defredis :ltrim,        [:key, :start, :stop]
  defredis :mget,         [:key]
  defredis :mset,         [:members]
  defredis :msetnx,       [:members]
  defredis :rpush,        [:key, :value]
  defredis :ping,         []
  defredis :ping,         [:message]
  defredis :sadd,         [:key, :member]
  defredis :set,          [:key, :value]
  defredis :setbit,       [:key, :offset, :value]
  defredis :sdiff,        [:key]
  defredis :sdiffstore,   [:destination, :key]

  defredis :zadd,         [:key, :member]
  defredis :zcard,        [:key]
  defredis :zcount,       [:key, :min, :max]
  defredis :zincrby,      [:key, :increment, :member]
  defredis :zlexcount,    [:key, :min, :max]
  defredis :zrange,       [:key, :start, :stop]
  defredis :zrange,       [:key, :start, :stop, :withscores]
  defredis :zrank,        [:key, :member]
  defredis :zrem,         [:key, :member]
  defredis :zrevrank,     [:key, :member]
  defredis :zscore,       [:key, :member]
end
