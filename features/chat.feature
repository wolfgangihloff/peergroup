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
    Then I should see "Hi all" within ".chat_update .message"
    And I should see "Tom" within ".chat_update .login"

  @javascript
  Scenario: Receiving posted message and newcomer notification
    Then I should not see "How are you?"
    And I should not see "John"
    When the funny_chat_update exists with message: "How are you?"
    And the user "John" is in the chat room of group "Funny"
    Then I should see "How are you?"
    And I should see "Hi Tom"
    And I should see "John"

