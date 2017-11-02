module Autopass
  # Utility functions
  module Util
    module_function

    def silence_warnings
      verbose_was = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = verbose_was
    end
  end
end
