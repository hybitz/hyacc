module CaptureSupport

  def with_capture
    begin
      yield
    ensure
      capture
    end
  end

end

World(CaptureSupport)
