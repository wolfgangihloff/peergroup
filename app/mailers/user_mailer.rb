class UserMailer < ActionMailer::Base
  # TODO: set default email address
  default :from => "from@example.com"

  def group_invitation(membership)
    @membership = membership
    mail(:to => membership.email, :subject => "Peergroup invitation")
  end
end
