class UserNameChangeRequest < ApplicationRecord
  belongs_to :user
  belongs_to :approver, class_name: "User", optional: true

  validate :not_limited, on: :create
  validates :desired_name, user_name: true
  validates_presence_of :original_name, :desired_name

  after_create :update_name!

  def self.visible(viewer = CurrentUser.user)
    if viewer.is_admin?
      all
    elsif viewer.is_member?
      joins(:user).merge(User.undeleted).where("user_name_change_requests.user_id = ?", viewer.id)
    else
      none
    end
  end

  def update_name!
    user.update!(name: desired_name)
  end

  def not_limited
    if UserNameChangeRequest.unscoped.where(user: user).where("created_at >= ?", 1.week.ago).exists?
      errors[:base] << "You can only submit one name change request per week"
    end
  end
end
