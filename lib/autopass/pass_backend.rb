# frozen_string_literal: true

require 'autopass/entry'

module Autopass
  # Interface to password store
  class PassBackend
    def initialize
      init_cache
      @needs_saving = false
      update_cache
      save_cache if needs_saving?
    end

    def entries
      @cache[:entries]
    end

    def sorted_entries(focused_window)
      entries.sort_by do |name, entry|
        match = entry.match(focused_window)
        match ? "\0" * focused_window.sub(match[0], '').size : name
      end.to_h
    end

    private

    def save_cache
      cache_file = CONFIG.cache_file
      cache_file.delete if cache_file.exist?
      FileUtils.mkdir_p(cache_file.dirname.to_s)

      GPG.encrypt(CONFIG.cache_key) do |gpg|
        gpg.puts(Marshal.dump(@cache))
        gpg.close_write

        cache_file.open('wb+', perm: 0o600) do |file|
          IO.copy_stream(gpg, file)
        end
      end
    end

    def files
      CONFIG.password_store.find.select { |file| file.extname == '.gpg' }
    end

    def needs_saving?
      @needs_saving
    end

    def update_cache
      checksums.each do |name, checksum|
        next if @cache[:checksums][name] == checksum
        @cache[:entries][name] = Autopass::Entry.load(name)
        @cache[:checksums][name] = checksum
        @needs_saving = true
      end
    end

    def checksums
      files.each_with_object({}) do |file, result|
        relative_path = file.relative_path_from(CONFIG.password_store)
        result[relative_path.sub(/\.gpg$/, '').to_s] = file.read.hash
      end
    end

    def init_cache
      @cache = if CONFIG.cache_file.exist?
                 Marshal.load(`gpg -dq --batch #{CONFIG.cache_file}`)
               else
                 @cache = { checksums: {}, entries: {} }
               end
    end
  end
end
