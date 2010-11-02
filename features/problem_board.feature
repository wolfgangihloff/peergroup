Feature: Problem Board
  In order to keep focus on the problem
  As a peer group supervision process member
  I want to have the current problem brief description visible on Problem Board

  Background:
    Given the group exists with name: "Funny"
    And the user "A" is the member of the group "Funny"
    And the user "A" is signed in

  Scenario: Accessing the board
    When I am on the "Funny" group chat
    And I follow "Problem"
    Then I should see "Problem board presents current problems"

