Feature: Static pages
  In order to see some background information
  As a Guest
  I want to view static pages

  Scenario: Access homepage
     When I go to the homepage
     Then I should see "Peer Supervision Groups project for Patongo"

  Scenario: Access contact page
     When I go to the contact page
     Then I should see "wolfgang.ihloff@gmail.com"

  Scenario: Access about page
     When I go to the about page
     Then I should see "About Peer Supervision Groups"

  Scenario: Access help page
     When I go to the help page
     Then I should see "This software will be released as part of Patongo!"
