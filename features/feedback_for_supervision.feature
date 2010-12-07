@wip
Feature: Providing feedback on supervision

  Background:
    Given the group "Developers" exists with members "Kacper", "Wolfgang"
      And a supervision: "Current supervision" exists with group: group "Developers", state: "supervision_feedback"
      And a topic: "Current topic" exists with supervision: supervision "Current supervision", user: user "Wolfgang", content: "How to make startup?"
      And the topic: "Current topic" is supervision: "Current supervision" topic
      And a supervision_feedback exists with supervision: supervision "Current supervision"

  Scenario: Providing the feedback
    Given the user "Wolfgang" is signed in
     When I go to the supervision feedback for "Current supervision" page
      And I fill in "Content" with "I think it was easy, thanks for your time." within "form#new_supervision_feedback"
      And I press "Submit"
     Then I should see "Feedback submited"
      And the supervision: "Current supervision" state should be "supervision_feedback"
      And I should see "I think it was easy, thanks for your time."

  Scenario: Providing feedback and closing supervision
    Given a supervision_feedback exists with supervision: supervision "Current supervision", user: user "Wolfgang"
      And the user "Wolfgang" is signed in
     When I go to the solutions for "Current supervision" page
      And I fill in "Content" with "I think it was easy, thanks for your time." within "form#new_supervision_feedback"
      And I press "Submit"
     Then I should see "Feedback submited"
      And the supervision: "Current supervision" state should be "finished"
      And I should see "I think it was easy, thanks for your time."
