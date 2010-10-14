module I18n
  module Backend
    module Collector

      def self.dump!
        file_path = File.join(Rails.root, %w{config locales application_en.yml})
        keys = File.exists?(file_path) ? YAML.load(File.read(file_path)) : {}
        File.open(file_path, "w") do |file|
          file.write(Collected.deep_merge(keys).to_yaml)
        end
      end

      Collected = {}

      def translate(locale, key, options = {})
        exception = nil
        translation = begin
          super
        rescue I18n::MissingTranslationData => e
          exception = e
          nil
        end

        return translation if translation && translation != options[:default]

        keys = I18n.normalize_keys(locale, key, options[:scope], options[:separator])

        keys_hash = {}
        last_hash = keys[0..-2].inject(keys_hash) do |result, scope_or_key|
          result[scope_or_key] = {}
        end

        last_hash[keys[-1]] = options[:default] || translation || "missing!"

        Collected.deep_merge!(keys_hash)
        raise exception if exception
        translation
      end
    end
  end
end

if %w{test cucumber development}.include?(Rails.env)
  I18n::Backend::Simple.send(:include, I18n::Backend::Collector)
  at_exit do
    I18n::Backend::Collector.dump!
  end
end

