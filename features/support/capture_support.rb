module CaptureSupport

  def with_capture(title = nil)
    begin
      yield
    ensure
      capture(:title => title)
    end
  end

end

World(CaptureSupport)
