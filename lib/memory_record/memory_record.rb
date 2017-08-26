# frozen_string_literal: true
require 'active_support/concern'
require 'active_support/core_ext/module/concerning'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/array/wrap'
require 'active_model'

module MemoryRecord
  extend ActiveSupport::Concern

  class_methods do
    # Example
    #
    #   memory_record [
    #     {id: 1, name: "alice"},
    #     {id: 2, name: "bob"  },
    #   ], attr_reader_auto: true
    #
    # or
    #
    #   memory_record(attr_reader_auto: true) do
    #     [
    #       {id: 1, name: "alice"},
    #       {id: 2, name: "bob"  },
    #     ]
    #   end
    #
    def memory_record(records = nil, **options, &block)
      return if memory_record_defined?

      if block
        options = records || {}
        records = block.call
      end

      extend ActiveModel::Translation
      extend Enumerable
      include ::MemoryRecord::SingletonMethods

      class_attribute :memory_record_options
      self.memory_record_options = {
        attr_reader: [],
      }.merge(options)

      if block_given?
        yield memory_record_options
      end

      if memory_record_options[:attr_reader_auto]
        _attr_reader = records.inject([]) { |a, e| a | e.keys.collect(&:to_sym) }
      else
        _attr_reader = memory_record_options[:attr_reader]
      end

      # Define it to an ancestor so that super method can be used.
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

      memory_record_reset(records)
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
        if key.kind_of? self
          return key
        end

        case key
        when Symbol, String
          @values_hash[:key][key.to_sym]
        else
          @values_hash[:code][key]
        end
      end
      alias [] lookup

      def fetch(key, default = nil, &block)
        if block_given? && default
          raise ArgumentError
        end

        v = lookup(key)
        unless v
          case
          when block_given?
            v = yield
          when default
            v = default
          else
            raise KeyError, [
              "#{name}.fetch(#{key.inspect}) does not match anything",
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

      def memory_record_reset(records)
        @keys = nil
        @codes = nil
        @values = records.collect.with_index { |e, i|
          new(_attributes_normalize(e, i))
        }.freeze
        @values_hash = {}
        [:code, :key].each do |pk|
          @values_hash[pk] = @values.inject({}) do |a, e|
            a.merge(e.send(pk) => e) do |key, a, b|
              raise ArgumentError, [
                "#{name}##{pk} #{key.inspect} is duplicate",
                "Existing: #{a.attributes.inspect}",
                "Conflict: #{b.attributes.inspect}",
              ].join("\n")
            end
          end
        end
      end

      private

      def _attributes_normalize(attrs, index)
        key = attrs[:key] || "_key#{index}"
        if key.kind_of? Array
          key = key.join('_')
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
