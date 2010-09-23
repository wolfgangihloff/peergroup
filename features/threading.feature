Feature: threading
  In order to reduce typical to chat discussions chaos
  As a user
  I want to post and see messages organised in threads

  Background:
    Given the group exists with user: "Tom", name: "Funny" and chat message: "Hi Tom"
    And the user "Tom" is signed in

  Scenario: Messages are grouped in the threads when I enter the chat
    When the chat message exists with message "Hi you" within "Hi Tom" thread
    And I am on the "Funny" group chat
    Then I should see "Hi Tom"
    And I should see "Hi you" within "Hi Tom" thread

  @javascript
  Scenario: I can choose the thread to which I want to post my message
    When I am on the "Funny" group chat
    And I follow "reply"
    And I fill in "Message" with "Hi you"
    And I wait 1 second
    Then I should see "Hi you" within "Hi Tom" thread

  @javascript
  Scenario: When I change my current thread the message I was writing before commits automatically
    When I am on the "Funny" group chat
    And I follow "reply"
    And I fill in "Message" with "Hi you"
    And I follow "new thread"
    And I wait 1 second
    And I fill in "Message" with "Let's talk about something new"
    Then I should see "Hi you" within "Hi Tom" thread
    And I should see "Let's talk about something new"
    And I should not see "Let's talk about something new" within "Hi Tom" thread

