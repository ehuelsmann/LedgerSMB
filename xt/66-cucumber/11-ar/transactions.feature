@weasel
Feature: AR transaction document handling
  As a LedgerSMB user, I want to be able to create transactions,
  save them and post them, with or without separation of duties
  and search for them.


Background:
   Given a standard test company
     And a customer "Customer 1"
     And a logged in admin


Scenario: Creation of a new AR transaction, no taxes
    When I open the AR transaction entry screen
     And I select customer "Customer 1"
    Then I expect to see these transaction header fields and values
       | name            | value    |
       | Invoice Created | $$today  |
       | Invoice Date    | $$today  |
       | Due Date        | $$today  |
       | Currency        | USD      |
       | Description     |          |
       | Invoice Number  |          |
       | Order Number    |          |
       | PO Number       |          |
     And I expect to see a transaction with 2 lines
    When I add a transaction line with these values:
       | name            | value    |
       | Amount          | 20.00    |
       | Account         | 4010     |
       | Description     | Test 1   |
    Then I expect to see the transaction total of 20.00

Scenario: Creation of a new AR transaction, with taxes
   Given customer "Customer 1" with this tax:
       | Tax account          |
       | 2150--Sales Tax      |
    When I open the AR transaction entry screen
     And I select customer "Customer 1"
    When I add a transaction line with these values:
       | name            | value    |
       | Amount          | 20.00    |
       | Account         | 4010     |
       | Description     | Test 1   |
    Then I expect to see the transaction total of 21.00
