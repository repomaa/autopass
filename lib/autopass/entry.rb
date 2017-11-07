# frozen_string_literal: true

require 'date'

module Autopass
  # A single entry in the password store
  class Entry
    # Signals a missing otp secret
    class OTPSecretMissingError < RuntimeError
      def initialize
        super('No OTP secret found for this entry')
      end
    end

    # Signals a missing key
    class KeyMissingError < RuntimeError
      def initialize(keys)
        super("No key '#{keys.join('+')}' found for this entry")
      end
    end

    # Signals a missing url
    class URLNotFoundError < RuntimeError
      def initialize
        super('No URL found for this entry')
      end
    end

    attr_reader :name, :attributes

    def initialize(name, attributes)
      @name = name
      @attributes = attributes
    end

    def self.load(entry)
      content = Util::Pass.show(entry)
      metadata = parse_content(entry, content)
      new(entry, OpenStruct.new(metadata))
    end

    def self.parse_content(entry, content)
      password, *yaml = content.split("\n")
      yaml = yaml.join("\n")
      (YAML.safe_load(yaml, [Date]) || {}).tap do |metadata|
        metadata[CONFIG.password_key] = password
      end
    rescue RuntimeError => e
      message = "Failed parsing entry '#{entry}'"
      Util.notify(message, console_info: [password, yaml, e.message])
      { error: true }
    end

    def autotype!(index = 0)
      keys = autotype_keys(index)

      raise KeyMissingError, keys if autotype_values(keys).empty?

      sleep CONFIG.alt_delay if index > 0
      Util::Xdo.focus(window_id)
      perform_autotype(autotype_values(keys))
    end

    def autotype_tan
      raise 'This entry has no tan attribute' unless attributes.tan

      tans = attributes.tan.lines
      tan_number = ask_tan_number(tans.size)
      tan = tans[tan_number - 1]
      Util::Xdo.focus(window_id)
      perform_autotype([tan.strip])
    end

    def otp
      raise OTPSecretMissingError unless attributes.otp_secret
      ROTP::TOTP.new(attributes.otp_secret).now
    end

    def autotype_values(keys)
      keys.map { |key| key[0] == ':' ? key : attributes[key] }.compact
    end

    def autotype_keys(index)
      keys = if index.zero?
               attributes.autotype || CONFIG.autotype
             else
               attributes[:"autotype_#{index}"] ||
                 CONFIG.public_send(:"autotype_#{index}") ||
                 []
             end
      keys = keys.split(/\s+/) if keys.is_a?(String)
      keys
    end

    def window_id
      window_search_strings.each do |regex|
        result = Util::Xdo.search(regex)
        return result.first if result.size == 1
      end

      select_window_id_by_user!
    end

    def window_search_strings
      [
        attributes.window, # try window
        Regexp.escape(attributes.url || ''), # try url
        # try window with browser
        "#{attributes.window}.*#{Regexp.union(CONFIG.browsers)}",
        Regexp.escape(name || '') # try name
      ]
    end

    def match(window_name)
      matcher = attributes.window || Regexp.escape(attributes.url || name)
      window_name.match(/#{matcher}/i)
    end

    def select_window_id_by_user!
      Util.notify('Please select the target window')
      window = Util::Xdo.info
      Util::Xclip.copy(window[:title])
      puts "selected window: '#{window[:title]}' copied to clipboard"
      window[:id]
    end

    def open_url!
      raise URLNotFoundError if attributes.url.to_s.empty?
      Process.spawn(ENV['BROWSER'] || 'xdg-open', attributes.url)
    end

    private

    def perform_autotype(values)
      values.each do |value|
        case value
        when ':tab' then Utils::Xdo.key('Tab')
        when ':enter' then Utils::Xdo.key('Return')
        else
          text = value == ':otp' ? otp : value
          Utils::Xdo.type(text)
        end
      end
    end

    def ask_tan_number(tans_size)
      number, * = Utils::Rofi.menu('TAN number:', 1...tans_size)
      number.to_i
    end
  end
end
