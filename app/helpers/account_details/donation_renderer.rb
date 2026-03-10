module AccountDetails
  class DonationRenderer < SubAccountDetailRenderer
    def get_template(controller_name)
      "#{controller_name}/account_details/donation"
    end
  end
end
