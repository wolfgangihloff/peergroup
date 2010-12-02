Feature: Providing feedback on ideas
  In order to ...
  As a problem owner
  I want to provide feedback on other process members ideas

  Background:
    Given the group "Developers" exists with members "Kacper", "Wolfgang"
    And a supervision: "Current supervision" exists with group: group "Developers", state: "idea_feedback"
    And a topic: "Current topic" exists with supervision: supervision "Current supervision", user: user "Wolfgang", content: "How to make startup?"
    And the topic: "Current topic" is supervision: "Current supervision" topic

  Scenario: Providing the feedback
    Given the user "Wolfgang" is signed in
    When I go to the ideas for "Current supervision" page
    And I fill in "Content" with "Thanks for all ideas!" within "form#new_ideas_feedback"
    And I press "Submit"
    Then I should see "Feedback submitted"
    And the supervision: "Current supervision" state should be "solution"
    And I should see "Wait for some solutions"

  @javascript
  Scenario: Receive feedback update
    Given the user "Kacper" is signed in
    And the ideas feedback exists with supervision: supervision "Current supervision", user: user "Wolfgang", content: "These are nice ideas!"
    When I go to the ideas for "Current supervision" page
    Then the supervision: "Current supervision" state should be "solution"
    And I should see "These are nice ideas!"
    And I should see "Any solutions?"

