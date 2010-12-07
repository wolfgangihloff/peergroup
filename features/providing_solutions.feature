Feature: Providing solutions
  In order to collectively solve the problem
  As a user
  I want to provide my solution proposal

  Background:
    Given the group "Developers" exists with members "Kacper", "Wolfgang"
      And a supervision: "Current supervision" exists with group: group "Developers", state: "solution"
      And a topic: "Current topic" exists with supervision: supervision "Current supervision", user: user "Wolfgang", content: "How to make startup?"
      And a ideas_feedback exists with supervision: supervision "Current supervision"
      And the topic: "Current topic" is supervision: "Current supervision" topic

  Scenario: Providing the solution
    Given I am logged in as "Kacper"
     When I go to the solutions for "Current supervision" page
     Then I should see "Any solutions?"
     When I fill in "Content" with "Look for an investor"
      And I press "Submit"
     Then I should see "Solution submited"
      And I should see "Look for an investor"

  Scenario: Rating the solution
    Given I am logged in as "Wolfgang"
      And the solution: "Kacper's solution" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "Look for an investor"
     When I go to the solutions for "Current supervision" page
     Then I should see "Look for an investor"
     When I choose "4" within solution: "Kacper's solution"
      And I press "Rate" within solution: "Kacper's solution"
     Then I should see "Solution rated"
      And the solution: "Kacper's solution" rating should be "4"

  @javascript
  Scenario: Receive new solution update
    Given I am logged in as "Wolfgang"
     When I go to the solutions for "Current supervision" page
      And the solution: "Kacper's solution" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "Look for an investor"
     Then I should see "Look for an investor"

  @javascript
  Scenario: Receive new rating update
    Given I am logged in as "Kacper"
      And the solution: "Kacper's solution" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "Look for an investor"
     When I go to the solutions for "Current supervision" page
     Then I should not see "Rating" within solution "Kacper's solution"
     When the solution: "Kacper's solution" rating is "3"
     Then I should see "Rating" within solution "Kacper's solution"

  Scenario: Moving forward by providing last rating
    Given I am logged in as "Wolfgang"
      And the solution: "Kacper's solution" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "Look for an investor"
      And the vote exists with user: user "Kacper", statement: supervision "Current supervision"
     When I go to the solutions for "Current supervision" page
     Then I should see "Look for an investor"
     When I choose "4" within solution: "Kacper's solution"
      And I press "Rate" within solution: "Kacper's solution"
     Then I should see "Solution rated"
      And I should see "Provide the feedback on solutions"

  Scenario: Moving forward by clicking "No more solutions" button
    Given I am logged in as "Kacper"
     When I go to the solutions for "Current supervision" page
      And I follow "I have no more solutions"
     Then the supervision: "Current supervision" state should be "solution_feedback"
      And I should see "Wait for Wolfgang's feedback"

