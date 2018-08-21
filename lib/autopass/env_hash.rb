module Autopass
  ENV_HASH = ENV.each_with_object({}) do |(var, value), result|
    result[var.to_sym] = value
  end
end
