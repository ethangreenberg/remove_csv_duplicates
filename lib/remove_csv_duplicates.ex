defmodule RemoveCSVDuplicates do
  @moduledoc """
  Module for removing duplicates from a CSV.
  """

  alias NimbleCSV.RFC4180, as: CSV
  require Logger

  @headers ["First Name", "Last Name", "Email", "Phone"]

  @doc """
  Main function for this problem.

  Takes in an input file name, output file name, and strategy.

  Reads from file specified by input_csv_name, and if the input is a csv that is formatted correctly,
  outputs a csv with duplicates removed to output_csv_name

  """
  @spec remove_duplicates_from_csv(String.t, String.t, :email | :phone | :email_or_phone) :: :ok
  def remove_duplicates_from_csv(input_csv_name, output_csv_name, strategy) do
    with {:ok, input_file} <- File.open(input_csv_name, [:read]),
      {:ok, output_file} <- File.open(output_csv_name, [:write])
      do
        output_stream = File.stream!(output_csv_name)
        input_csv_name
        |> File.stream!()
        |> tap(fn _ -> Logger.debug("Parsing Stream") end)
        |> CSV.parse_stream()
        |> tap(fn _ -> Logger.debug("Removing duplicates") end)
        |> remove_duplicates_from_list(strategy)
        |> case do
          {:ok, res} ->
            # Add headers back in
            [@headers | res]
            |> tap(fn _ -> Logger.debug("Dumping to stream") end)
            |> CSV.dump_to_stream()
            |> Stream.into(output_stream)
            |> tap(fn _ -> Logger.debug("Writing to output file") end)
            |> Stream.run()
          {:error, message} ->
            Logger.error("Failed to remove duplicates: #{message}")
        end
        File.close(input_file)
        File.close(output_file)
      else
        {:error, error} -> Logger.error("Unable to open file: #{inspect(error)}")
    end
    :ok
  end

  @doc """
  Helper function for remove_duplicates_from_csv/2.

  Removes duplicate rows from the list of entries based on the given strategy.

  Assumes that the elements of the list are in the order (First Name, Last Name, Email, Phone).
  """
  @spec remove_duplicates_from_list([[String.t]] | Stream.t, :email | :phone | :email_or_phone) :: {:ok, [[String.t]]} | {:error, any}
  def remove_duplicates_from_list(list, :email) do
    res = Enum.reduce(list, %{new_list: [], used_emails: %{}}, fn row, acc ->
      if length(row) != 4 do
        Logger.warn("Skipping row with wrong number of columns")
        acc
      else
        [_, _, email_str, _] = row
        email = String.downcase(email_str)
        cond do
          email == "" ->
            %{new_list: [row | acc.new_list], used_emails: acc.used_emails}
          not Map.has_key?(acc.used_emails, email) ->
            # add to the new list in reverse order
            %{new_list: [row | acc.new_list], used_emails: Map.put(acc.used_emails, email, "")}
          true ->
            acc
        end
      end
    end)

    {:ok, Enum.reverse(res.new_list)}
  end

  def remove_duplicates_from_list(list, :phone) do
    res = Enum.reduce(list, %{new_list: [], used_phones: %{}}, fn row, acc ->
      if length(row) != 4 do
        Logger.warn("Skipping row with wrong number of columns")
        acc
      else
        [_, _, _, phone_str] = row
        phone = parse_phone(phone_str)
        cond do
          phone == "" ->
            %{new_list: [row | acc.new_list], used_phones: acc.used_phones}
          not Map.has_key?(acc.used_phones, phone) ->
            # add to the new list in reverse order
            %{new_list: [row | acc.new_list], used_phones: Map.put(acc.used_phones, phone, "")}
          true ->
            acc
        end
      end
    end)

    {:ok, Enum.reverse(res.new_list)}
  end

  def remove_duplicates_from_list(list, :email_or_phone) do
    res = Enum.reduce(list, %{new_list: [], used_emails: %{}, used_phones: %{}}, fn row, acc ->
      if length(row) != 4 do
        Logger.warn("Skipping row with wrong number of columns")
        acc
      else
        [_, _, email, phone_str] = row
        phone = parse_phone(phone_str)
        cond do
          email == "" and phone == "" ->
            %{
              new_list: [row | acc.new_list],
              used_emails: acc.used_emails,
              used_phones: acc.used_phones
            }
          not Map.has_key?(acc.used_emails, email) and phone == "" ->
            %{
              new_list: [row | acc.new_list],
              used_emails: Map.put(acc.used_emails, email, ""),
              used_phones: acc.used_phones
            }
          email == "" and not Map.has_key?(acc.used_phones, phone) ->
            %{
              new_list: [row | acc.new_list],
              used_emails: acc.used_emails,
              used_phones: Map.put(acc.used_phones, phone, "")
            }
          not Map.has_key?(acc.used_emails, email) and not Map.has_key?(acc.used_phones, phone) ->
            %{
              new_list: [row | acc.new_list],
              used_emails: Map.put(acc.used_emails, email, ""),
              used_phones: Map.put(acc.used_phones, phone, "")
            }
          true ->
            acc
        end
      end
    end)

    {:ok, Enum.reverse(res.new_list)}
  end

  def remove_duplicates_from_list(_list, _invalid_strategy) do
    {:error, :invalid_strategy}
  end

  # public for testing
  # uses ExPhoneNumber to parse the phone number if it is a us number
  # TODO: Handle phone numbers from other countries
  @doc false
  def parse_phone(phone) do
    ExPhoneNumber.parse(phone, "US")
    |> case do
      {:ok, phone_number} -> ExPhoneNumber.format(phone_number, :e164)
      {:error, _any} -> phone
    end
  end
end
