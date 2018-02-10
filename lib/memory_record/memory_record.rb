# frozen_string_literal: true
require 'active_support/concern'
require 'active_support/core_ext/module/concerning'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/module/delegation'

module MemoryRecord
  extend ActiveSupport::Concern

  class_methods do
    # Example
    #
    #   memory_record [
    #     {id: 1, name: "alice"},
    #     {id: 2, name: "bob"  },
    #   ], attr_reader: false
    #
    # or
    #
    #   memory_record(attr_reader: false) do
    #     [
    #       {id: 1, name: "alice"},
    #       {id: 2, name: "bob"  },
    #     ]
    #   end
    #
    def memory_record(records = nil, **options, &block)
      return if memory_record_defined?

      if block
        records = block.call
      end

      extend Enumerable
      include ::MemoryRecord::SingletonMethods

      class_attribute :memory_record_options
      self.memory_record_options = {
        attr_reader: true,
      }.merge(options)

      if block_given?
        yield memory_record_options
      end

      attr_reader_args = []
      all_keys = records.inject([]) { |a, e| a | e.keys.collect(&:to_sym) }
      case v = memory_record_options[:attr_reader]
      when true
        attr_reader_args = all_keys
      when Hash
        if v[:only]
          all_keys &= Array(v[:only])
        elsif v[:except]
          all_keys -= Array(v[:except])
        end
        attr_reader_args = all_keys
      when Array
        attr_reader_args = v
      when Symbol, String
        attr_reader_args = [v]
      end

      # Define it to an ancestor so that super method can be used.
      include Module.new.tap { |m|
        ([:key, :code] + attr_reader_args).uniq.each do |key|
          m.module_eval do
            define_method(key) { @attributes[key.to_sym] }
          end
        end

        unless m.method_defined?(:name)
          m.module_eval do
            define_method(:name) { key.to_s }
          end
        end

        m.module_eval do
          # sort matches definition order
          def <=>(other)
            [self.class, code] <=> [other.class, other.code]
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

      def [](*v)
        lookup(*v)
      end

      def fetch(key, default = nil, &block)
        if block_given? && default
          raise ArgumentError, "Can't use default and block together"
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
