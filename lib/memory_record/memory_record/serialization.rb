# frozen_string_literal: true

require "active_support/core_ext/hash/except"
require "active_support/core_ext/hash/slice"

module MemoryRecord
  # Reference: ActiveModel::Serializers::JSON
  # https://github.com/rails/rails/blob/0605f45ab323331b06dde3ed16838f56f141ca3f/activemodel/lib/active_model/serialization.rb
  # The original code and the implementation are slightly different
  module Serialization
    def serializable_hash(options = nil)
      options ||= {}

      keys = attributes.keys
      if only = options[:only]
        keys &= Array(only)
      elsif except = options[:except]
        keys -= Array(except)
      end
      keys += Array(options[:methods])

      hash = {}
      keys.each { |e| hash[e] = send(e) }
      Array(options[:methods]).each { |e| hash[e] = read_attribute_for_serialization(e) }

      serializable_add_includes(options) do |association, records, opts|
        hash[association] = -> {
          if records.respond_to?(:to_ary)
            records.to_ary.map { |a| a.as_json(opts) }
          else
            records.as_json(opts)
          end
        }.call
      end

      hash
    end

    def as_json(**options)
      serializable_hash(options)
    end

    private

    alias :read_attribute_for_serialization :send # for ActiveModelSerializers

    # Add associations specified via the <tt>:include</tt> option.
    #
    # Expects a block that takes as arguments:
    #   +association+ - name of the association
    #   +records+     - the association record(s) to be serialized
    #   +opts+        - options for the association records
    def serializable_add_includes(options = {}) #:nodoc:
      return unless includes = options[:include]

      unless includes.is_a?(Hash)
        includes = Hash[Array(includes).flat_map { |n| n.is_a?(Hash) ? n.to_a : [[n, {}]] }]
      end

      includes.each do |association, opts|
        if records = send(association)
          yield association, records, opts
        end
      end
    end
  end
end
