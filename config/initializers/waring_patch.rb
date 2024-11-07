rb_version = Gem::Version.new(RUBY_VERSION)
if rb_version >= Gem::Version.new('2.7') && Gem::Version.new(Rails.version) < Gem::Version.new('6')
  module Warning
    def warn(str)
      return if str.match?('/gems/')
      super
    end
  end
end