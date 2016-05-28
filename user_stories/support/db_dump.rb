class DbDump
  include Singleton

  attr_accessor :current_feature

  def load
    db = Dir.glob(File.join(dump_dir, '*.dump.gz')).first

    if db
      command = "bundle exec rake dad:db:load DUMP_FILE=#{db} --quiet"
      puts command
      raise 'DBロードに失敗しました。' unless system(command)
    end
  end

  def dump(dir = nil)
    raise 'DBダンプの削除に失敗しました。' unless system("rm -f #{dump_dir(dir)}/*.gz")

    command = "bundle exec rake dad:db:dump DUMP_DIR=#{dump_dir(dir)} --quiet"
    puts command
    raise 'DBダンプに失敗しました。' unless system(command)
  end

  private

  def dump_dir(dir = nil)
    if dir.to_s.empty?
      dir = File.join('tmp', File.dirname(current_feature), File.basename(current_feature, '.feature'))
    end

    dir
  end

end