defmodule Sashite.Snn.ConstantsTest do
  use ExUnit.Case, async: true

  alias Sashite.Snn.Constants

  doctest Constants

  # ============================================================================
  # max_string_length/0
  # ============================================================================

  describe "max_string_length/0" do
    test "returns 32" do
      assert Constants.max_string_length() == 32
    end

    test "is a positive integer" do
      assert is_integer(Constants.max_string_length())
      assert Constants.max_string_length() > 0
    end
  end
end
