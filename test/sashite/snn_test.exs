defmodule Sashite.SnnTest do
  use ExUnit.Case
  doctest Sashite.Snn

  alias Sashite.Snn

  describe "validation" do
    test "accepts valid SNN formats" do
      valid_inputs = ["Chess", "Shogi", "Xiangqi", "Chess960", "G5", "A", "Abc"]

      for input <- valid_inputs do
        assert Snn.valid?(input), "Expected '#{input}' to be valid"
      end
    end

    test "rejects invalid SNN formats" do
      invalid_inputs = [
        # Starts with lowercase
        "chess",
        # Starts with digit
        "1Chess",
        # Invalid character (_)
        "Chess_960",
        # Invalid character (-)
        "Chess-960",
        # Trailing space
        "Chess ",
        # Leading space
        " Chess",
        # Empty string
        ""
      ]

      for input <- invalid_inputs do
        refute Snn.valid?(input), "Expected '#{input}' to be invalid"
      end
    end

    test "strictly rejects line breaks (Spec requirement)" do
      # These must be rejected even if the regex matches the content before \n
      refute Snn.valid?("Chess\n")
      refute Snn.valid?("Chess\r")
      refute Snn.valid?("Chess\r\n")
      refute Snn.valid?("\nChess")
    end
  end

  describe "parsing" do
    test "parse/1 returns structured data" do
      assert {:ok, %Snn{name: "Go"}} = Snn.parse("Go")
    end

    test "parse!/1 returns struct or raises" do
      assert %Snn{name: "Go"} = Snn.parse!("Go")

      assert_raise ArgumentError, ~r/invalid SNN format/, fn ->
        Snn.parse!("invalid")
      end
    end
  end

  describe "protocols" do
    test "String.Chars (to_string)" do
      snn = Snn.parse!("Makruk")
      assert to_string(snn) == "Makruk"
      assert "Playing #{snn}" == "Playing Makruk"
    end

    test "Inspect" do
      snn = Snn.parse!("Janggi")
      assert inspect(snn) == "#Sashite.Snn<Janggi>"
    end
  end
end
