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
  Scenario: Receiving posted message
    Then I should not see "How are you?"
    When the chat_update exists with message: "How are you?"
    And I wait 1 second
    Then I should see "How are you?"
    And I should see "Hello Chatter"
