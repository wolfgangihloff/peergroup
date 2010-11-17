Feature: Providing ideas
  In order to collectively find the solution
  As a user
  I want to provide my solution idea

  Background:
    Given the group "Developers" exists with members "Kacper", "Wolfgang"
    And a supervision: "Current supervision" exists with group: group "Developers", state: "idea"
    And a topic: "Current topic" exists with supervision: supervision "Current supervision", user: user "Wolfgang", content: "How to make startup?"
    And the topic: "Current topic" is supervision: "Current supervision" topic

  Scenario: Providing the idea
    Given the user "Kacper" is signed in
    When I go to the ideas for "Current supervision" page
    Then I should see "Any ideas?"
    When I fill in "Content" with "Use the newest technologies."
    And I press "Submit"
    Then I should see "Idea successfully submited"
    And I should see "Use the newest technologies."

  Scenario: Rating the idea
    Given the user "Wolfgang" is signed in
    And the idea: "Kacper's idea" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "Use the newest technologies."
    When I go to the ideas for "Current supervision" page
    Then I should see "Use the newest technologies."
    When I choose "4" within idea: "Kacper's idea"
    And I press "Rate" within idea: "Kacper's idea"
    Then I should see "Idea rated"
    And the idea: "Kacper's idea" rating should be "4"

  @javascript
  Scenario: Receive new idea update
    Given the user "Wolfgang" is signed in
    When I go to the ideas for "Current supervision" page
    And the idea: "Kacper's idea" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "Use the newest technologies."
    Then I should see "Use the newest technologies."

  @javascript
  Scenario: Receive new rating update
    Given the user "Kacper" is signed in
    And the idea: "Kacper's idea" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "Use the newest technologies."
    When I go to the ideas for "Current supervision" page
    Then I should not see "Rating" within idea "Kacper's idea"
    When the idea: "Kacper's idea" rating is "3"
    Then I should see "Rating" within idea "Kacper's idea"

