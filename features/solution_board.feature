Feature: Solution Board
  In order to track current solutions
  As a peer group supervision process member
  I want to have the board which would present all ongoing solutions

  Background:
    Given the group exists with name: "Funny"
    And the user "A" is the member of the group "Funny"
    And the user "A" is signed in

  Scenario: Accessing the board
    When I am on the "Funny" group chat
    And I follow "Solution"
    Then I should see "Solution board presents current solutions"

