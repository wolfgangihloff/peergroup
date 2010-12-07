Feature: Manage groups
  In order to allow me to collaborate with other users
  As a user
  I want to create new group

  Scenario: Create new group
    Given I am logged in as "Social Guy"
      And I am on the homepage
     When I follow "Create Group"
     Then I should see "New Group"
     When I fill in "Name" with "Newcomers"
      And I fill in "Description" with "New group description"
      And I press "Create Group"
     Then I should see "Your Groups"
      And I should see "Newcomers*"

  Scenario: Browsing my groups
    Given the freds_group exists with name: "Newcomers"
      And the group exists with name: "Outlanders"
      And I am logged in as "Fred"
     When I am on the homepage
      And I follow "My Groups"
     Then I should see "Newcomers"
      And I should not see "Outlanders"

  Scenario: Browsing all groups
    Given the freds_group exists with name: "Newcomers"
      And the group exists with name: "Outlanders"
      And I am logged in as "Fred"
     When I am on the homepage
      And I follow "All Groups"
     Then I should see "Newcomers"
      And I should see "Outlanders"

  Scenario: Accessing created group
    Given the freds_group exists with name: "Newcomers"
      And I am logged in as "Fred"
      And I am on the groups page
     When I follow "Newcomers*"
     Then I should see "Fred" within ".users"

