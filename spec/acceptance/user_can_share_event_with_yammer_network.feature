Feature: User can share a sched.do event with her Yammer network

  Scenario: User creates an event and votes
    Given I am signed in as "Bruce Lee"
    And I create an event named "Clown party" with a suggestion of "lunch"
    When I vote for "lunch"
    Then I should see "Share sched.do with your coworkers"
    And I should see "I voted on a poll in sched.do"
