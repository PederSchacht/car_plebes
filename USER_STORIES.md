# User Stories

## Viewing the Menu

The menu will be displayed upon startup.
Options will be displayed so users can decide how to continue.

Acceptance Criteria:
  * If the user selects 1, they see "Who's account will this be?"
  * If the user selects 2, they see "Who's account do you want to update?"
  * If the user selects 3, they see "What car do you want to buy?"
  * If the user types in anything else, they should see "<input> is an invalid selection" and the menu should be printed again

  Usage:

    > ./car_plebes
    What do you want to do?
    1. Add Account
    2. Update Monthly Income
    3. Can I Get This Car?

## Add Account


Acceptance Criteria:

  * Unique accounts will be added to the database
  * Duplicate accounts can't be added

Usage:

  > ./car_plebes
  What do you want to do?
  1. Add Account
  2. Update Monthly Income
  3. Can I Get This Car?
  - 1
  Who's account will this be?
  - Sam
  Sam's account has been added.
