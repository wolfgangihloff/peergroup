Feature: Providing feedback on supervision

  Background:
    Given the group "Developers" exists with members "Kacper", "Wolfgang"
      And a supervision: "Current supervision" exists with group: group "Developers", state: "supervision_feedback"
      And a topic: "Current topic" exists with supervision: supervision "Current supervision", user: user "Wolfgang", content: "How to make startup?"
      And the topic: "Current topic" is supervision: "Current supervision" topic
      And a ideas_feedback exists with supervision: supervision "Current supervision", user: user "Wolfgang"
      And a solutions_feedback exists with supervision: supervision "Current supervision", user: user "Wolfgang"

  Scenario: Providing the feedback
    Given I am logged in as "Wolfgang"
      And I am on the supervision feedbacks for "Current supervision" page
     When I fill in "Content" with "I think it was easy, thanks for your time." within "form#new_supervision_feedback"
      And I press "Create Supervision feedback"
     Then I should see "Feedback submitted"
      And the supervision: "Current supervision" state should be "supervision_feedback"
      And I should see "I think it was easy, thanks for your time."

  Scenario: Providing feedback and closing supervision
    Given a supervision_feedback exists with supervision: supervision "Current supervision", user: user "Kacper"
      And I am logged in as "Wolfgang"
      And I am on the supervision feedbacks for "Current supervision" page
     When I fill in "Content" with "I think it was easy, thanks for your time." within "form#new_supervision_feedback"
      And I press "Create Supervision feedback"
     Then I should see "Feedback submitted"
      And the supervision: "Current supervision" state should be "finished"
      And I should see "I think it was easy, thanks for your time."

