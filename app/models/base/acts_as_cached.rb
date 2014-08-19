module Base
  module ActsAsCached
    extend ActiveSupport::Concern

    def expire_caches
      Rails.cache.delete("#{self.class.name}.get(#{self.id})")
      if self.respond_to?(:code)
        Rails.cache.delete("#{self.class.name}.get_by_code(#{self.code})")
      end
    end

    module ClassMethods
      LOCAL_LATENCY = 5
      @@_local_cache = {}

      def acts_as_cached(options = {})
        after_save :expire_caches
        before_destroy :expire_caches

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

        if options[:includes].present?
          modules = []
          if options[:includes].is_a?(Array)
            modules += options[:includes]
          else
            modules << options[:includes]
          end

          modules.each do |include_module|
            module_name = include_module.classify
            extend "#{module_name}::ClassMethods".constantize
            include "#{module_name}::InstanceMethods".constantize
          end
        end

      end
    
      def with_latency(key)
        now = Time.now.to_i
        
        cache = @@_local_cache[key]
        if cache
          elapsed = now - cache[:cached_time]
          if elapsed < LOCAL_LATENCY
            if ::HyaccLogger.debug?
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

    end
  end
end
