import Config

config :koetex, Koetex,
  provider_global_name: System.get_env("KOETEX_PROVIDER_GLOBAL_NAME") || "koetex_provider",
  max_sharing_count: System.get_env("KOETEX_MAX_SHARING_COUNT") || 1000,
  chromosomes_stock_scale: System.get_env("KOETEX_CHROMOSOMES_STOCK_SCALE") || 100

config :koetex, Koetex.LifeCycle,
  max_survival_count: System.get_env("KOETEX_MAX_SURVIVAL_COUNT") || 10,
  break_time_scale: System.get_env("KOETEX_BREAK_TIME_SCALE") || 10
