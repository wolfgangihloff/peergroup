Feature: Chat
  In order to exchange knowledge in real time
  As a user
  I want to communicate using chat

  Background:
    Given the group exists with user: "Tom", name: "Funny" and chat message: "Hi Tom"
    And the user "Tom" is signed in
    And I am on the groups page
    When I follow "Chat"
    Then I should see "Hi Tom"
    And I should see "Funny Group Chat"

  Scenario: Posting message
    When I fill in "Message" with "Hi all"
    And I press "Send"
    When I am on the "Funny" group chat
    Then I should see "Hi all" within ".chat_update .message"
    And I should see "Tom" within ".chat_update .login"

  @javascript
  Scenario: Receiving posted message, newcomer notifications and active rule changed updates
    Then I should not see "How are you?"
    And I should not see "John"
    When the funny_chat_update exists with message: "How are you?"
    And the user "John" enters the chat room of group "Funny"
    Then I should see "How are you?"
    And I should see "Hi Tom"
    And I should see "John"

  @javascript
  Scenario: Receiving active user notification
    When I fill in "Message" with "I am currently writing"
    Then I should see "Tom" within ".chat_user.active"

  @javascript
  Scenario: Creating new thread
    When I follow "reply"
    Then I should see "Tom" within ".chat_update.active"
    When I follow "new thread"
    Then I should not see any active chat update

