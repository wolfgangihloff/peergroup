Feature: Chat
  In order to exchange knowledge in real time
  As a user
  I want to communicate using chat

  Background:
    Given the user exists with name: "Tom"
    And the chat_update exists with message: "Hello Chatter"
    And the user "Tom" is signed in
    And I am on the homepage
    When I follow "Chat"
    Then I should see "Hello Chatter"

  Scenario: Posting message
    When I fill in "Message" with "Hi all"
    And I press "Send"
    And show me the page
    Then I should see "Hi all" within ".chat_update .message"
    And I should see "Tom" within ".chat_update .login"

  @javascript
  Scenario: Receiving posted message and newcomer notification
    Then I should not see "How are you?"
    And I should not see "John"
    When the chat_update exists with message: "How are you?"
    And the chatting_user exists with name: "John"
    Then I should see "How are you?"
    And I should see "Hello Chatter"
    And I should see "John"

