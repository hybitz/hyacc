require 'test_helper'

class RentFinderTest < ActiveSupport::TestCase

  def setup
    @finder = RentFinder.new
    @finder.per_page = 10
  end

  def test_list_filters_by_status_use
    @finder.status = RENT_STATUS_TYPE_USE

    rents = @finder.list

    assert rents.any?
    assert rents.all? { |r| r.status == RENT_STATUS_TYPE_USE }
  end

  def test_list_filters_by_status_stop
    @finder.status = RENT_STATUS_TYPE_STOP

    rents = @finder.list

    assert rents.any?
    assert rents.all? { |r| r.status == RENT_STATUS_TYPE_STOP }
  end

end
