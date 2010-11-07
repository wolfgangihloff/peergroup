Feature: Signin
  In order to access my account
  As a Guest
  I want to signin

  Background:
    Given the user exists with name: "Tom", email: "tom@example.com"

  Scenario: Providing invalid credentials
    When I go to the signin page
    And I press "Sign in"
    Then I should see "Invalid email/password combination"

  Scenario: Successful signin
    When I go to the signin page
    And I fill in the following:
      | Email                 | tom@example.com |
      | Password              | foobar |
    And I press "Sign in"
    Then I should see "Tom's Group List"

