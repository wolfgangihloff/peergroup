Feature: Group rules
  In order to describe peer group supervision process
  As a user
  I want to manage group rules

  Background:
    Given the group exists with name: "Funny"
    And the user "Tom" is signed in
    And the user "Tom" is the member of the group "Funny"
    And I am on the homepage
    When I follow "My Groups"
    And I follow "Funny"
    Then I should be on the group page

  Scenario: Browsing default group rules
    Then I should see "Decide on Leader"
    And I should see "Choose the Problem and the Owner"

  Scenario:
    When I follow "Edit" within "li.rule:first-child"
    Then I should see "Edit Rule"
    When I fill in "Name" with "Rule modified"
    And I fill in "Description" with "Modified rules description"
    And I press "Update Rule"
    Then I should be on the group page
    And I should see "Rule modified"
    And I should not see "Decide on Leader"


