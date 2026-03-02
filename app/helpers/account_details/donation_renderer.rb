module AccountDetails
  class DonationRenderer < AccountDetailRenderer
    def get_template(controller_name)
      "#{controller_name}/account_details/donation"
    end
  end
end
