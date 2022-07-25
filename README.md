# RemoveCSVDuplicates

## Installation

To download, clone this repo. In order to run this project, 
make sure you have erlang and elixir set to the specified versions (I used asdf to do this). Then, run

```
mix deps.get
iex -S mix
```

from there, you can run `RemoveCSVDuplicates.remove_duplicates_from_csv(FULL_PATH_TO_INPUT_CSV, PATH_OF_OUTPUT_CSV, :email, :phone, or :email_or_phone depending on the strategy you want to use)`


## Testing
Check out test_input.csv and RemoveCSVDuplicatesTest. To execute tests, execute `mix test` in console