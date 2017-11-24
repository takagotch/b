Feature: Checkout items

  Scenario: Checkout a single item
    Given a "tin of tomatoes" costs 50c
    When I scan a "tin of tomatoes"
    Then the total is 50c
    
  Scenario: Checkout several different items
    Given a "tin of tomatoes" costs 50c
    And a "plastic bag" costs 5c
    When I scan a "tin of tomatoes"
    And I scan a "plastic bag"
    Then the total is 55c

  Scenario: Checkout the same item several times
    Given a "tin of tomatoes" costs 50c
    And a "plastic bag" costs 5c
    When I scan a "tin of tomatoes"
    And I scan a "plastic bag"
    And I scan a "tin of tomatoes"
    Then the total is 105c

