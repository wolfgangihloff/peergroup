Feature: Chat room rule change
  In order to keep users focused on the task
  As a peer group supervision process member
  I want to change current rule

  Scenario: Change rule
    Given the group exists with name: "Funny"
    And the user "Tom" is signed in
    And the user "Tom" is the member of the group "Funny"
    When I am on the "Funny" group chat
    Then I should see "Decide on Leader" within "ul.rules li:first-child"
    When I follow "Activate" within "ul.rules li:first-child"
    Then I should be on the "Funny" group chat
    And I should see "Decide on Leader" within "ul.rules li.current:first-child"
    And I should see "Decide on Leader phase starts"

