require 'test_helper'

class InhabitantCsvTest < ActiveSupport::TestCase

  def test_load
    file = File.open(Rails.root.join('test/upload_files/inhabitant_tax.csv'))
    list, linked = InhabitantCsv.load(file, Company.find(1))
    file.close

    assert linked
    assert_equal 2, list.size

    first = list.first
    assert_equal '札幌市中央区南１条東１丁目１－１', first.address
    assert_equal '本店', first.kanji_last_name
    assert_equal '一郎', first.kanji_first_name
    assert_equal '19000,18200,18200,18200,18200,18200,18200,18200,18200,18200,18200,18200', first.amounts
    assert_equal 1, first.employee_id

    second = list.second
    assert_equal '札幌市豊平区平岸１条１丁目１－１－１１１', second.address
    assert_equal '経理', second.kanji_last_name
    assert_equal '次郎', second.kanji_first_name
    assert_equal 2, second.employee_id
  end

end
