defmodule RemoveCSVDuplicatesTest do
  use ExUnit.Case
  doctest RemoveCSVDuplicates

  @valid_list [
    ["Test", "Test", "t@1", "1234567890"],
    ["Test", "Test", "t@1", "123-456-7891"],
    ["Test", "Test", "t@2", "(123) 456-7890"]
  ]

  @list_with_empty_values [
    ["Test", "Test", "t@1", ""],
    ["Test", "Test", "", ""],
    ["Test", "Test", "", "1234567890"]
  ]

  describe "tests for remove_csv_duplicates" do
    test "passing an empty list returns an empty list" do
      assert RemoveCSVDuplicates.remove_duplicates_from_list([], :email) == {:ok, []}
      assert RemoveCSVDuplicates.remove_duplicates_from_list([], :phone) == {:ok, []}
      assert RemoveCSVDuplicates.remove_duplicates_from_list([], :email_or_phone) == {:ok, []}
    end

    test "passing an invalid strategy returns an error" do
      assert RemoveCSVDuplicates.remove_duplicates_from_list([], :bad) == {:error, :invalid_strategy}
    end

    test "works for emails in basic case" do
      assert RemoveCSVDuplicates.remove_duplicates_from_list(@valid_list, :email) == {:ok, [
        ["Test", "Test", "t@1", "1234567890"],
        ["Test", "Test", "t@2", "(123) 456-7890"]
      ]}
    end

    test "works for phones in basic case" do
      assert RemoveCSVDuplicates.remove_duplicates_from_list(@valid_list, :phone) == {:ok, [
        ["Test", "Test", "t@1", "1234567890"],
        ["Test", "Test", "t@1", "123-456-7891"]
      ]}
    end

    test "works for emails or phones in basic case" do
      assert RemoveCSVDuplicates.remove_duplicates_from_list(@valid_list, :email_or_phone) == {:ok, [
        ["Test", "Test", "t@1", "1234567890"],
      ]}
    end

    test "does not remove empty emails" do
      assert RemoveCSVDuplicates.remove_duplicates_from_list(@list_with_empty_values, :email) == {:ok, @list_with_empty_values}
    end

    test "does not remove empty phones" do
      assert RemoveCSVDuplicates.remove_duplicates_from_list(@list_with_empty_values, :phone) == {:ok, @list_with_empty_values}
    end

    test "does not remove empty phones or emails" do
      assert RemoveCSVDuplicates.remove_duplicates_from_list(@list_with_empty_values, :email_or_phone) == {:ok, @list_with_empty_values}
    end
  end

end
