require 'English'

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

    def notify(message, type: :normal, duration: 5000, console_info: [])
      system(
        'notify-send', '-a', 'autopass', '-u', type.to_s, '-t', duration.to_s,
        message.to_s
      )
      STDERR.puts(message, *console_info)
    end

    # Wrapper around xclip
    module Xclip
      def copy(string)
        IO.popen(CONFIG.clip_command, 'w+') { |io| io.print(string) }
      end
    end

    # Wrapper around pass
    module Pass
      module_function

      def show(entry)
        IO.popen(['pass', 'show', entry.to_s], &:read)
      end
    end

    # Wrapper around xdotool
    module Xdo
      module_function

      def key(key)
        system('xdotool', 'key', key.to_s)
      end

      def type(text)
        command = %w[xdotool type --clearmodifiers --file -]
        IO.popen(command, 'w+') { |io| io.write(text) }
      end

      def search(regex)
        command = ['xdotool', 'search', '--onlyvisible', '--name', regex.to_s]
        result = IO.popen(command) { |xdotool| xdotool.read.chomp }
        result.split("\n")
      end

      def focus(id)
        system('xdotool', 'windowfocus', '--sync', id.to_s)
      end

      def info
        xwininfo = IO.popen(%w[xwininfo -int]) { |io| io.read.chomp }
        xwininfo.match(/Window id: (?<id>\d+) "(?<title>.*)"$/)
      end
    end

    # Wrapper around rofi
    module Rofi
      module_function

      def menu(prompt, list = [])
        command = ['rofi', '-dmenu', '-p', prompt.to_s]
        result = IO.popen(command, 'w+') do |io|
          io.puts list
          io.close_write
          io.gets
        end

        [result && result.chomp, $CHILD_STATUS]
      end
    end

    # Wrapper around gpg
    module GPG
      module_function

      def encrypt(key, &block)
        gpg_cmd = ['gpg', '-eq', '--batch', '-r', key]
        IO.popen(gpg_cmd, 'w+', &block)
      end

      def decrypt(&block)
        gpg_cmd = ['gpg', '-dq', '--batch']
        IO.popen(gpg_cmd, 'w+', &block)
      end
    end
  end
end
