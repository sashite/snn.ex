defmodule Sashite.SnnTest do
  use ExUnit.Case, async: true

  alias Sashite.Snn
  alias Sashite.Snn.StyleName

  doctest Snn

  # ============================================================================
  # parse/1
  # ============================================================================

  describe "parse/1" do
    test "returns {:ok, style_name} for valid name" do
      assert {:ok, %StyleName{name: "Chess"}} = Snn.parse("Chess")
    end

    test "returns {:ok, style_name} for name with numeric suffix" do
      assert {:ok, %StyleName{name: "Chess960"}} = Snn.parse("Chess960")
    end

    test "returns {:ok, style_name} for single letter" do
      assert {:ok, %StyleName{name: "A"}} = Snn.parse("A")
    end

    test "returns style_name with correct name attribute" do
      {:ok, snn} = Snn.parse("Shogi")
      assert snn.name == "Shogi"
    end

    test "parses various valid names" do
      names = ~w(Chess Shogi Xiangqi Makruk Go Chess960 A Z CHESS)

      for name <- names do
        assert {:ok, %StyleName{name: ^name}} = Snn.parse(name)
      end
    end

    test "returns {:error, :empty_input} for empty string" do
      assert {:error, :empty_input} = Snn.parse("")
    end

    test "returns {:error, :input_too_long} for long input" do
      input = String.duplicate("A", 33)
      assert {:error, :input_too_long} = Snn.parse(input)
    end

    test "returns {:error, :invalid_format} for lowercase start" do
      assert {:error, :invalid_format} = Snn.parse("chess")
    end

    test "returns {:error, :invalid_format} for digit start" do
      assert {:error, :invalid_format} = Snn.parse("1Chess")
    end

    test "returns {:error, :invalid_format} for invalid characters" do
      assert {:error, :invalid_format} = Snn.parse("Chess-960")
    end
  end

  # ============================================================================
  # parse!/1
  # ============================================================================

  describe "parse!/1" do
    test "returns style_name for valid name" do
      snn = Snn.parse!("Chess")
      assert snn.name == "Chess"
    end

    test "returns style_name for name with numeric suffix" do
      snn = Snn.parse!("Chess960")
      assert snn.name == "Chess960"
    end

    test "returns style_name for single letter" do
      snn = Snn.parse!("A")
      assert snn.name == "A"
    end

    test "raises ArgumentError for empty string" do
      assert_raise ArgumentError, "empty input", fn ->
        Snn.parse!("")
      end
    end

    test "raises ArgumentError for input too long" do
      input = String.duplicate("A", 33)

      assert_raise ArgumentError, "input too long", fn ->
        Snn.parse!(input)
      end
    end

    test "raises ArgumentError for lowercase start" do
      assert_raise ArgumentError, "invalid format", fn ->
        Snn.parse!("chess")
      end
    end

    test "raises ArgumentError for digit start" do
      assert_raise ArgumentError, "invalid format", fn ->
        Snn.parse!("1Chess")
      end
    end
  end

  # ============================================================================
  # valid?/1
  # ============================================================================

  describe "valid?/1" do
    test "returns true for valid standard names" do
      assert Snn.valid?("Chess")
      assert Snn.valid?("Shogi")
      assert Snn.valid?("Xiangqi")
    end

    test "returns true for single uppercase letters" do
      assert Snn.valid?("A")
      assert Snn.valid?("Z")
    end

    test "returns true for names with numeric suffix" do
      assert Snn.valid?("Chess960")
      assert Snn.valid?("G5")
    end

    test "returns true for all uppercase" do
      assert Snn.valid?("CHESS")
    end

    test "returns false for empty string" do
      refute Snn.valid?("")
    end

    test "returns false for lowercase start" do
      refute Snn.valid?("chess")
    end

    test "returns false for digit start" do
      refute Snn.valid?("1Chess")
    end

    test "returns false for invalid characters" do
      refute Snn.valid?("Chess-960")
      refute Snn.valid?("Chess_Variant")
    end

    test "returns false for nil" do
      refute Snn.valid?(nil)
    end
  end

  # ============================================================================
  # Integration Tests
  # ============================================================================

  describe "integration" do
    test "parse then to_string" do
      {:ok, snn} = Snn.parse("Chess960")
      assert StyleName.to_string(snn) == "Chess960"
    end

    test "parse! then interpolation" do
      snn = Snn.parse!("Shogi")
      assert "Playing #{snn}" == "Playing Shogi"
    end

    test "round-trip parse and to_string" do
      names = ~w(Chess Shogi Xiangqi Makruk Go Chess960 A Z XY123)

      for name <- names do
        {:ok, snn} = Snn.parse(name)
        assert StyleName.to_string(snn) == name
      end
    end

    test "multiple style names can be collected" do
      names = ~w(Chess Shogi Xiangqi)

      styles =
        names
        |> Enum.map(&Snn.parse!/1)

      assert Enum.map(styles, & &1.name) == names
    end
  end
end
