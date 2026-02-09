require 'test_helper'

module Base
  class ViewAttributeHandlerTest < ActiveSupport::TestCase
    include ViewAttributeHandler
    
    def test_法人の本社の取得
      @user = User.find(1)

      branches = get_branches()
      assert_equal 3, branches.size

      options = {:include=>:deleted}
      branches = get_branches(options)
      assert_equal 4, branches.size
    end
    
    def test_個人事業主の本社の取得
      @user = User.find(4)

      branches = get_branches()
      assert_equal 1, branches.size

      options = {:include=>:deleted}
      branches = get_branches(options)
      assert_equal 1, branches.size
    end
  
    def test_has_option?
      options = {:include=>:deleted}
      assert has_option?(options[:include], :deleted)      
    end

    private

    def current_user
      @user
    end

    def current_company
      @user.employee.company
    end
  end
end
