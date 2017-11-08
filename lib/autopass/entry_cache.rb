# frozen_string_literal: true

require 'autopass/util'
require 'autopass/entry'
require 'json'

module Autopass
  # Entry database/cache
  class EntryCache
    attr_reader :entries

    def initialize(entries)
      @entries = entries
      update!
    end

    def self.load
      if CONFIG.cache_file.exist? && CONFIG.use_cache
        decrypt
      else
        new(files.map(&Entry.method(:load)))
      end
    end

    def self.decrypt
      Util::GPG.decrypt do |gpg|
        CONFIG.cache_file.open { |file| gpg.write(file.read) }
        gpg.close_write
        from_json(gpg.read)
      end
    end

    def sorted_entries(focused_window)
      @entries.sort_by do |entry|
        match = entry.match(focused_window)
        match ? "\0" * focused_window.sub(match[0], '').size : entry.name
      end
    end

    def to_json(*args)
      @entries.to_json(*args)
    end

    def self.from_json(json)
      entries = JSON.parse(json).map do |attributes|
        Entry.new(attributes.deep_symbolize_keys, decrypted: true)
      end

      new(entries)
    end

    def self.files
      CONFIG.password_store.find.select { |file| file.extname == '.gpg' }
    end

    def update!
      return unless CONFIG.use_cache

      puts 'Updating cache...'
      @entries.select!(&:exist?)
      @entries.each_with_index do |entry, i|
        print progressbar(i)
        entry.reload!
      end

      puts
      save!
    end

    def save!
      return unless CONFIG.use_cache

      cache_file = CONFIG.cache_file
      FileUtils.mkdir_p(cache_file.dirname.to_s)

      Util::GPG.encrypt(CONFIG.cache_key) do |gpg|
        gpg.puts(to_json)
        gpg.close_write

        cache_file.open('wb+', perm: 0o600) do |file|
          file.write(gpg.read)
        end
      end
    end

    private

    def progressbar(i)
      progress = i * 50 / @entries.size
      "[#{'#' * progress}#{' ' * (49 - progress)}]\r"
    end
  end
end
