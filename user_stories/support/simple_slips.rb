module SimpleSlips

  def visit_simple_slip(options = {})
    assert current_user || sign_in(User.first)

    visit '/'
    click_on options[:account].name
    assert has_title?(options[:account].name)

    if options[:branch]
      select options[:branch].name, :from => 'finder_branch_id'
      click_on '表示'
    end

    assert has_no_selector?('.notice')
    assert has_selector?('.account_ready')
  end

  def create_simple_slip(simple_slip)
    with_capture do
      visit_simple_slip(:account => simple_slip.my_account, :branch => simple_slip.branch)

      within '#new_simple_slip' do
        fill_in 'simple_slip_ym', :with => simple_slip.ym
        fill_in 'simple_slip_day', :with => simple_slip.day
        fill_in 'simple_slip_remarks', :with => simple_slip.remarks
        select simple_slip.account.code_and_name, :from => 'simple_slip_account_id', :match => :first
      end

      assert has_selector?('.account_ready')
      if simple_slip.account.has_sub_accounts
        assert has_selector?('#simple_slip_sub_account_id')
      end

      within '#new_simple_slip' do
        if simple_slip.sub_account.present?
          select simple_slip.sub_account.name, :from => 'simple_slip_sub_account_id'
        end

        select simple_slip.branch.name, :from => 'simple_slip_branch_id' if simple_slip.branch

        if simple_slip.amount_increase.present?
          fill_in 'simple_slip_amount_increase', :with => simple_slip.amount_increase
        else
          fill_in 'simple_slip_amount_decrease', :with => simple_slip.amount_decrease
        end

        click_on '登録'
      end

      assert has_selector?('.notice')
    end
  end
end

World(SimpleSlips)
