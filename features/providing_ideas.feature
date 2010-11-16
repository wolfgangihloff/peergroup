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

