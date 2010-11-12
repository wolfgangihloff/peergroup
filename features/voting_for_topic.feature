Feature: Voting for topic on supervision session
  In order to express my will
  As a user
  I want to vote on my favourite topic

  Background: 
    Given the group "Developers" exists with members "Kacper", "Wolfgang"
    And the user "Kacper" is signed in
    When a supervision: "Current supervision" exists with group: group "Developers"
    And the following topics exist:
      | topic | supervision | user | content |
      | Kacper's topic | supervision: "Current supervision" | user: "Kacper" | How to cook? |
      | Wolfgang's topic | supervision: "Current supervision" | user: "Wolfgang" | How to make startup? |

  Scenario: Vote on topic as the first one
    When I am on the new topic vote for "Current supervision" page
    Then I should see "How to cook?" within the topic: "Kacper's topic"
    And I should see "How to make startup?" within the topic: "Wolfgang's topic"
    When I press "Vote" within the topic: "Wolfgang's topic"
    Then I should see "Thank you for voting"
    And I should not see "Vote" within the topic: "Wolfgang's topic"
    And I should see "Waiting for others to vote"
    And the topic: "Wolfgang's topic" should have 1 votes

  Scenario: Vote on topic as the last one
    Given the vote exists with statement: topic "Wolfgang's topic", user: user "Wolfgang"
    When I am on the new topic vote for "Current supervision" page
    When I press "Vote" within the topic: "Wolfgang's topic"
    Then I should see "Thank you for voting"
    And the topic: "Wolfgang's topic" should be supervision: "Current supervision" topic
    And I should see "Do you have any question regarding the topic?"

