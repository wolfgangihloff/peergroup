Feature: Group rules
  In order to describe peer group supervision process
  As a user
  I want to manage group rules

  Background:
    Given the group exists with name: "Funny"
    And the user "Tom" is signed in
    And the user "Tom" is the member of the group "Funny"
    And I am on the homepage

  Scenario: Browsing default group rules
    When I follow "My Groups"
    And I follow "Funny"
    Then I should see "Decide on Leader"
    And I should see "Choose the Problem and the Owner"

