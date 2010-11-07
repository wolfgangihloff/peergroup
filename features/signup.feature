Feature: Signup
  In order to use personalized app features
  As a Guest
  I want to signup

  Scenario: Providing invalid data
    When I go to the signup page
    And I fill in "Passcode" with "Pat0ng0"
    And I press "Sign up"
    Then I should see "can't be blank"

  Scenario: Successful signup
    When I go to the signup page
    And I fill in the following:
      | Name                  | Example User |
      | Email                 | user@example.com |
      | Passcode              | Pat0ng0 |
      | Password              | foobar |
      | Password confirmation | foobar |
    And I press "Sign up"
    Then I should see "Example User's Group List"
    And I should see "Welcome to the Peer Supervision Groups"

