Feature: Providing the topic on supervision session
  In order discuss my problem
  As a user
  I want to provide my supervision session topic proposal

  Background:
    Given the group "Developers" exists with members "Kacper", "Wolfgang"
    And the user "Kacper" is signed in

  Scenario: Providing the topic as the first one
    When I am on the homepage
    And I follow "Session" within "Developers" group brief
    Then I should see "Do you want to create new Supervision Session?"
    When I press "Yes"
    Then I should see "Enter your problem or leave this blank if you do not have any."
    When I fill in "Content" with "How to look good at job interview?"
    And I press "Submit Topic"
    Then I should see "Topic was submitted successfully"
    And I should see "How to look good at job interview?"

  Scenario: Leaving the topic blank
    When I am on the homepage
    And I follow "Session" within "Developers" group brief
    Then I should see "Do you want to create new Supervision Session?"
    When I press "Yes"
    Then I should see "Enter your problem or leave this blank if you do not have any."
    And I press "Submit Topic"
    Then I should see "Kacper did not submitted his topic."

  Scenario: Providing the topic as the last one
    When a supervision: "Current supervision" exists with group: group "Developers"
    And a topic exists with supervision: supervision "Current supervision", author: user "Wolfgang", content: "How to cook dinner?"
    And I am on the homepage
    And I follow "Session" within "Developers" group brief
    Then I should see "Enter your problem or leave this blank if you do not have any."
    When I fill in "Content" with "How to look good at job interview?"
    And I press "Submit Topic"
    Then I should see "Topic was submitted successfully"
    And I should see "How to cook dinner?"
    And I should see "How to look good at job interview?"
    And I should see "Vote on the topic you want to discuss."

