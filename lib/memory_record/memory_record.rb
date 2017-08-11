# frozen_string_literal: true
require "active_support/concern"
require "active_support/core_ext/module/concerning"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/array/wrap"
require "active_model"

module MemoryRecord
  extend ActiveSupport::Concern

  class_methods do
    def memory_record(list, **options, &block)
      return if memory_record_defined?

      extend ActiveModel::Translation
      extend Enumerable
      include ::MemoryRecord::SingletonMethods

      class_attribute :memory_record_configuration
      self.memory_record_configuration = {
        attr_reader: [],
      }.merge(options)

      if block_given?
        yield memory_record_configuration
      end

      if memory_record_configuration[:attr_reader_auto]
        _attr_reader = list.inject([]) { |a, e| a | e.keys.collect(&:to_sym) }
      else
        _attr_reader = memory_record_configuration[:attr_reader]
      end

      include Module.new.tap { |m|
        ([:key, :code] + Array.wrap(_attr_reader)).uniq.each do |key|
          m.class_eval do
            define_method(key) { @attributes[key.to_sym] }
          end
        end

        unless m.method_defined?(:name)
          m.class_eval do
            define_method(:name) do
              if self.class.name
                self.class.human_attribute_name(key)
              end
            end
          end
        end
      }

      memory_record_list_set(list)
    end

    def memory_record_defined?
      ancestors.include?(SingletonMethods)
    end
  end

  concern :SingletonMethods do
    class_methods do
      def memory_record?
        memory_record_defined?
      end

      def lookup(key)
        return key if key.kind_of? self
        case key
        when Symbol, String
          @values_hash[:key][key.to_sym]
        else
          @values_hash[:code][key]
        end
      end
      alias [] lookup

      def fetch(key, default = nil, &block)
        raise ArgumentError if block_given? && default
        v = lookup(key)
        unless v
          case
          when block_given?
            v = yield
          when default
            v = default
          else
            raise KeyError, [
              "#{name}.fetch(#{key.inspect}) では何にもマッチしません",
              "keys: #{keys.inspect}",
              "codes: #{codes.inspect}",
            ].join("\n")
          end
        end
        v
      end

      def fetch_if(key, default = nil, &block)
        if key
          fetch(key, default, &block)
        end
      end

      delegate :each, to: :values

      def keys
        @keys ||= @values_hash[:key].keys
      end

      def codes
        @codes ||= @values_hash[:code].keys
      end

      attr_reader :values

      def memory_record_list_set(list)
        @keys = nil
        @codes = nil
        @values = list.collect.with_index {|e, i| new(_attributes_normalize(e, i)) }.freeze
        @values_hash = {}
        [:code, :key].each do |pk|
          @values_hash[pk] = @values.inject({}) do |a, e|
            a.merge(e.send(pk) => e) do |key, old_val, new_val|
              raise ArgumentError, [
                "#{name}##{pk} の #{key.inspect} が重複しています",
                "  古い値: #{old_val.attributes.inspect}",
                "新しい値: #{new_val.attributes.inspect}",
              ].join("\n")
            end
          end
        end
      end

      private

      def _attributes_normalize(attrs, index)
        key = attrs[:key] || "_key#{index}"
        if key.kind_of? Array
          key = key.join("_")
        end
        attrs.merge(code: attrs[:code] || index, key: key.to_sym)
      end
    end

    attr_reader :attributes

    delegate :[], to: :attributes
    delegate :to_s, to: :name

    def initialize(attributes)
      @attributes = attributes
    end
  end
end
