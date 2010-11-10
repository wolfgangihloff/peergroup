Feature: Joining supervision process
  In order exchange my knowledge
  As a user
  I want to join supervision process

  Background:
    Given the group "Developers" exists with members "Kacper", "Wolfgang"
    And the user "Kacper" is signed in

  Scenario: Creating new session
    When I am on the homepage
    And I follow "Session" within "Developers" group brief
    Then I should see "Do you want to create new Supervision Session?"
    When I press "Yes"
    Then I should see "Enter your problem or leave this blank if you do not have any."

  Scenario: Joining existing session
    Given the session for the group "Developers" is started by "Wolfgang"
    When I am on the homepage
    And I follow "Session" within "Developers" group brief
    Then I should see "Enter your problem or leave this blank if you do not have any."

