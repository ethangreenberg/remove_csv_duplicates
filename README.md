# RemoveCSVDuplicates

## Description
Project to remove duplicates from a csv based on 
1. phone number
2. email
3. email or phone number

### Assumptions
1. Empty values should by default be included in the results
2. Phone numbers are US numbers
3. The header row will contain [ “First Name”, “Last Name”, “Email”, “Phone” ] *in that order*.
4. If a row does not have 4 entries, it should not be included in the results.

## Installation

To download, clone this repo. In order to run this project, 
make sure you have erlang and elixir set to the specified versions (I would recommend using `asdf` for this). Then, run

```
mix deps.get
iex -S mix
```

from there, you can run `RemoveCSVDuplicates.remove_duplicates_from_csv("FULL_PATH_TO_INPUT_CSV", "PATH_OF_OUTPUT_CSV", :email, :phone, or :email_or_phone depending on the strategy you want to use)`


## Testing
Check out test_input.csv and RemoveCSVDuplicatesTest. To execute tests, just run `mix test` in the repo