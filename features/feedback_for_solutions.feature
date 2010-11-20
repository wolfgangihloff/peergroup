Feature: Providing feedback on solutions
  In order to ...
  As a problem owner
  I want to provide feedback on other supervision members solutions

  Background:
    Given the group "Developers" exists with members "Kacper", "Wolfgang"
    And a supervision: "Current supervision" exists with group: group "Developers", state: "solution_feedback"
    And a topic: "Current topic" exists with supervision: supervision "Current supervision", user: user "Wolfgang", content: "How to make startup?"
    And the topic: "Current topic" is supervision: "Current supervision" topic
    And a ideas_feedback exists with supervision: supervision "Current supervision"

  Scenario: Providing the feedback
    Given the user "Wolfgang" is signed in
    When I go to the solutions for "Current supervision" page
    And I fill in "Content" with "Thanks for all solutions!" within "form#new_solutions_feedback"
    And I press "Submit"
    Then I should see "Feedback submitted"
    And the supervision: "Current supervision" state should be "finished"
    And I should see "Thanks for all solutions!"

  @javascript
  Scenario: Receive feedback update
    Given the user "Kacper" is signed in
    When I go to the solutions for "Current supervision" page
    And the solutions feedback exists with supervision: supervision "Current supervision", user: user "Wolfgang", content: "These are nice solutions!"
    Then the supervision: "Current supervision" state should be "finished"
    And I should see "These are nice solutions!"

