Feature: Chat room roles
  In order to keep user focused on the topic
  As a user
  I want to choose Leader and Problem owner

  Background:
    Given the group exists with name: "Funny"
    And the user "A" is the member of the group "Funny"

  Scenario: Selecting the leader and problem owner
    When the user "A" is signed in
    And I am on the homepage
    And I follow "All Groups"
    And I follow "Chat"
    And I follow "Leader"
    Then user "A" should be the leader of the chat room of the group "Funny"
    When I follow "Problem owner"
    Then user "A" should be the problem owner of the chat room of the group "Funny"


