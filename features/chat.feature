Feature: Chat
  In order to exchange knowledge in real time
  As a user
  I want to communicate using chat

  Scenario: Accessing the chat
    Given the user exists with name: "Tom"
    And the chat_update exists with text: "Hello Chatter"
    And the user "Tom" is signed in
    And I am on the homepage
    When I follow "Chat"
    Then I should see "Hello Chatter"

