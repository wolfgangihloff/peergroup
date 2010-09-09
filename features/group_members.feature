Feature: Invitations
  In order to allow users to form groups
  As a group founder
  I want to invite more users

  Background:
    Given the group exists with name: "Funny"
    And the user "Tom" is signed in

  Scenario: Joining the group
    When I am on the all groups page
    And I follow "join"
    Then I should see "You are now the member of the group Funny"
    And the user "Tom" should be the member of the group "Funny"

  Scenario: Leaving the group
    Given the user "Tom" is the member of the group "Funny"
    When I am on the groups page
    And I follow "leave"
    Then I should see "You are no longer the member of the group Funny"
    And the user "Tom" should not be the member of the group "Funny"

