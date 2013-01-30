Feature: User can share a sched.do event with her Yammer network

  Scenario: User creates an event and votes
    Given I am signed in as "Bruce Lee"
    And I create an event named "Clown party" with a suggestion of "lunch"
    When I vote for "lunch"
    Then I should see "Share this event with your coworkers"
    And I should see "I created an event in sched.do"

  Scenario: User votes on an event she didn't create
    Given someone created an event named "Clown party" with a suggestion of "lunch"
    And I am signed in as "Bruce Lee"
    When I view the "Clown party" event
    And I vote for "lunch"
    Then I should see "Share this event with your coworkers"
    And I should see "I voted on an event in sched.do"
