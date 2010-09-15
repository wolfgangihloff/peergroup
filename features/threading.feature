Feature: threading
  In order to reduce typical to chat discussions chaos
  As a user
  I want to post and see messages organised in threads

  Scenario: Messages grouped in the threads when entering the chat
    Given the group exists with user: "Tom", name: "Funny" and chat message: "Hi Tom"
    And the chat message exists with message "Hi you" within "Hi Tom" thread
    And the user "Tom" is signed in
    And I am on the "Funny" group chat
    Then I should see "Hi Tom"
    And show me the page
    And I should see "Hi you" within "Hi Tom" thread

