import Config

config :my_app, MyApp.MonitoringTools.MemoryWatcher, enabled: true
config :my_app, MyApp.MonitoringTools.ReductionWatcher, enabled: false
config :my_app, MyApp.MonitoringTools.Supervisor, enabled: true
