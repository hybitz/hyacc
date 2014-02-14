# coding: UTF-8
#
# $Id: acts_as_cached.rb 3308 2014-01-26 14:22:48Z ichy $
# Product: hyacc
# Copyright 2012-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Base

  module ActsAsCached
    LOCAL_LATENCY = 5

    module Mixin
      @@_local_cache = {}
      
      def with_latency(key)
        now = Time.now.to_i
        
        cache = @@_local_cache[key]
        if cache
          elapsed = now - cache[:cached_time]
          if elapsed < LOCAL_LATENCY
            if HyaccLogger.debug?
              #HyaccLogger.debug(key)
            end

            return cache[:cached_object]
          end
        end

        ret = Rails.cache.fetch(key) do
          yield
        end
        
        @@_local_cache[key] = {:cached_time => now, :cached_object => ret}
        ret
      end

      def acts_as_cached(options = {})
        after_save :expire_caches
        before_destroy :expire_caches

        # インスタンスメソッドはオーバーライドできるように先に宣言
        def expire_caches
          Rails.cache.delete("#{self.class.name}.get(#{self.id})")
          if self.respond_to?(:code)
            Rails.cache.delete("#{self.class.name}.get_by_code(#{self.code})")
          end
        end

        if options[:includes].present?
          if options[:includes].is_a?(Array)
            options[:includes].each do |include_module|
              module_name = include_module.classify
              extend "#{module_name}::ClassMethods".constantize
              include "#{module_name}::InstanceMethods".constantize
            end
          else
            module_name = options[:includes].classify
            extend "#{module_name}::ClassMethods".constantize
            include "#{module_name}::InstanceMethods".constantize
          end
        end

        unless respond_to?(:get)
          def self.get(id)
            return nil unless id
            return with_latency("#{self.name}.get(#{id})") do
              find(id)
            end
          end
        end
        
        unless respond_to?(:get_by_code)
          def self.get_by_code(code)
            return nil unless code
            return with_latency("#{self.name}.get_by_code(#{code})") do
              find_by_code(code)
            end
          end
        end
      end
    
    end
  end
end
