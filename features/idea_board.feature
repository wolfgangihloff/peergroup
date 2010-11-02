Feature: Idea Board
  In order to group the ideas in one place
  As a peer group supervision process member
  I want to have the board which would present all current ideas

  Background:
    Given the group exists with name: "Funny"
    And the user "A" is the member of the group "Funny"
    And the user "A" is signed in

  Scenario: Accessing the board
    When I am on the "Funny" group chat
    And I follow "Idea"
    Then I should see "Idea board presents current ideas"

