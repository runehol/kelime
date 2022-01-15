import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ordle, OrdleWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "R6JqW0B1/P4HkA2MOGLfV72blt0G4j8BXw64B2Iv7tkHW9kYF9ICwB6kc1lD2eCF",
  server: false

# In test we don't send emails.
config :ordle, Ordle.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
