Feature: Questions to the topic
  In order to make the topic more clear
  As a user
  I want to ask and answer the questions to the topic

  Background:
    Given the group "Developers" exists with members "Kacper", "Wolfgang"
    And a supervision: "Current supervision" exists with group: group "Developers", state: "topic_vote"
    And the following topics exist:
      | topic | supervision | user | content |
      | Kacper's topic | supervision: "Current supervision" | user: "Kacper" | How to cook? |
      | Wolfgang's topic | supervision: "Current supervision" | user: "Wolfgang" | How to make startup? |
    And the following votes exist:
      | statement | user |
      | topic: "Wolfgang's topic" | user: "Kacper" |
      | topic: "Wolfgang's topic" | user: "Wolfgang" |

  Scenario: Ask the question
    Given the user "Kacper" is signed in
    When I go to the new topic question for "Current supervision" page
    Then I should see "How to make startup?"
    When I fill in "Content" with "How big should be the startup?" within "form#new_question"
    And I press "Ask" within "form#new_question"
    Then I should see "Question asked"
    And I should see "How big should be the startup?"

  Scenario: Answer the question
    Given the user "Wolfgang" is signed in
    And the question: "Kacper's question" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "How big?"
    When I go to the new topic question for "Current supervision" page
    Then I should see "How big?" within question: "Kacper's question"
    When I fill in "Content" with "Very big!" within question: "Kacper's question"
    When I press "Answer" within question: "Kacper's question"
    Then I should see "Question answered"
    And I should see "Very big!" within question: "Kacper's question"

  Scenario: Asking blank question
    Given the user "Kacper" is signed in
    When I go to the new topic question for "Current supervision" page
    Then I should see "How to make startup?"
    When I fill in "Content" with "" within "form#new_question"
    And I press "Ask" within "form#new_question"
    Then I should see "You must provide your question"

  @javascript
  Scenario: Receive new question update
    Given the user "Wolfgang" is signed in
    When I go to the new topic question for "Current supervision" page
    Then I should see "Wait for some questions"
    And the question: "Kacper's question" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "How big?"
    Then I should not see "Wait for some questions"
    Then I should see "How big?"

  @javascript
  Scenario: Receive new answer update
    Given the user "Kacper" is signed in
    And the question: "Kacper's question" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "How big?"
    When I go to the new topic question for "Current supervision" page
    Then I should see "How big?"
    When the answer exists with question: question "Kacper's question", user: user "Wolfgang", content: "Worldwide"
    Then I should see "Worldwide" within question: "Kacper's question"

  Scenario: Moving forward by providing last answer
    Given the user "Wolfgang" is signed in
    And the question: "Kacper's question" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "How big?"
    And the vote exists with user: user "Kacper", statement: supervision "Current supervision"
    When I go to the new topic question for "Current supervision" page
    Then I should see "How big?"
    When I fill in "Content" with "Not big at all"
    And I press "Answer"
    Then I should see "Question answered"
    And I should see "Wait for some ideas"

  Scenario: Moving forward by clicking "No more questions" button
    Given the user "Kacper" is signed in
    When I go to the new topic question for "Current supervision" page
    And I follow "I have no more questions"
    Then the supervision: "Current supervision" state should be "idea"
    And I should see "Any ideas?"

  @javascript
  Scenario: Moving forward non problem owner after problem owner gave last answer
    Given the user "Kacper" is signed in
    And the question: "Kacper's question" exists with supervision: supervision "Current supervision", user: user "Kacper", content: "How big?"
    When I go to the new topic question for "Current supervision" page
    And I follow "I have no more questions"
    Then the supervision: "Current supervision" state should be "topic_question"
    And I should not see "Any ideas?"
    When the answer exists with question: question "Kacper's question", user: user "Wolfgang", content: "Worldwide"
    Then the supervision: "Current supervision" state should be "idea"
    And I should see "Any ideas?"

