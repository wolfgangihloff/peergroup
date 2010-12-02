Feature: Browsing
  In order to find my friend in the website users list
  As a user
  I want to browse all users

  Scenario: Accessing users list
    Given the user exists with name: "Kacper"
    And the user exists with name: "Wolfgang"
    And the user "Kacper" is signed in
    When I am on the homepage
    And I follow "Users"
    Then I should see "Kacper"
    And I should see "Wolfgang"

