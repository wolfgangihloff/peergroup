Feature: threading
  In order to reduce typical to chat discussions chaos
  As a user
  I want to post and see messages organised in threads

  Background:
    Given the group exists with user: "Tom", name: "Funny" and chat message: "Hi Tom"
    And the user "Tom" is signed in

  Scenario: Messages are grouped in the threads when entering the chat
    When the chat message exists with message "Hi you" within "Hi Tom" thread
    And I am on the "Funny" group chat
    Then I should see "Hi Tom"
    And I should see "Hi you" within "Hi Tom" thread

  @javascript
  Scenario: The thread to which the message is posted can be chosen
    When I am on the "Funny" group chat
    And I follow "reply"
    And I fill in "Message" with "Hi you"
    Then I should see "Hi you" within "Hi Tom" thread


