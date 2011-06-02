class UserMailer < ActionMailer::Base
  # TODO: set default email address
  default :from => "from@example.com"

  def group_invitation(membership)
    @membership = membership
    mail(:to => membership.email, :subject => "Peergroup invitation")
  end

  def group_request(membership)
    @membership = membership
    @group = membership.group
    @user = membership.user
    mail(:to => @group.founder.email, :subject => "Membership requested for group #{@group.name}")
  end
end
