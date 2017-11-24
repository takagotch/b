Feature:
  Scenario: Buy Two Bottles of Shampoo
    Given the price of a bottle of shampoo is $2
    When I scan 2 bottles of shampoo
    Then the price should be $0