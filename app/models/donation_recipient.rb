class DonationRecipient < ApplicationRecord
  include HyaccErrors

  belongs_to :company
  has_many :journal_detail_donation_recipients
  has_many :journal_details, through: :journal_detail_donation_recipients

  validates :kind, presence: true, inclusion: { in: DONATION_RECIPIENT_SUB_ACCOUNT_CODES }
  validates :name, presence: true

  before_save :clear_irrelevant_fields_by_kind

  # セレクト用ラベル。識別情報（使途等）があれば「名称（値）」、なければ名称のみ
  def label_for_select
    v = identification_value_for_select
    v.present? ? "#{name}（#{v}）" : name
  end

  private

  def identification_value_for_select
    case kind
    when SUB_ACCOUNT_CODE_DONATION_DESIGNATED then announcement_number.presence || purpose
    when SUB_ACCOUNT_CODE_DONATION_PUBLIC_INTEREST then purpose_or_name
    when SUB_ACCOUNT_CODE_DONATION_NON_CERTIFIED_TRUST then trust_name
    else nil
    end
  end

  # 種別変更後、その種別で使わない項目のデータはクリアする
  def clear_irrelevant_fields_by_kind
    case kind
    when SUB_ACCOUNT_CODE_DONATION_DESIGNATED
      self.address = nil
      self.purpose_or_name = nil
      self.trust_name = nil
    when SUB_ACCOUNT_CODE_DONATION_PUBLIC_INTEREST
      self.announcement_number = nil
      self.purpose = nil
      self.trust_name = nil
    when SUB_ACCOUNT_CODE_DONATION_NON_CERTIFIED_TRUST
      self.announcement_number = nil
      self.purpose = nil
      self.purpose_or_name = nil
    end
  end
end

