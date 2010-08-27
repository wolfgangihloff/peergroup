Feature: Manage groups
  In order to allow me to collaborate with other users
  As a user
  I want to create new group

  Scenario: Create new account
    Given the user exists with name: "Social Guy"
    And the user "Social Guy" is signed in
    And I am on the homepage
    When I follow "Create Group"
    Then I should see "New Group"
    When I fill in "Name" with "Newcomers"
    And I press "Submit"
    Then I should see "User Groups List"
    And I should see "Newcomers"

