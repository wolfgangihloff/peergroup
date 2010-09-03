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
    When I fill in "Description" with "New group description"
    And I press "Create Group"
    Then I should see "User Groups List"
    And I should see "Newcomers*"

#  Scenario: Accessing created group
#    Given the freds_group exists with name: "Newcomers"
#    And the user "Fred" is signed in
#    And I am on Fred's profile page
#    And show me the page
#    When I follow "Newcomers*"
#    Then I should see "Fred" within ".members"

