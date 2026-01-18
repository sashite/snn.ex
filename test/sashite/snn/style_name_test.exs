defmodule Sashite.Snn.StyleNameTest do
  use ExUnit.Case, async: true

  alias Sashite.Snn.StyleName

  doctest StyleName

  # ============================================================================
  # new/1
  # ============================================================================

  describe "new/1" do
    test "creates style name with valid name" do
      snn = StyleName.new("Chess")
      assert snn.name == "Chess"
    end

    test "creates style name with numeric suffix" do
      snn = StyleName.new("Chess960")
      assert snn.name == "Chess960"
    end

    test "creates style name with single letter" do
      snn = StyleName.new("A")
      assert snn.name == "A"
    end

    test "creates style name with all uppercase" do
      snn = StyleName.new("CHESS")
      assert snn.name == "CHESS"
    end

    test "raises on empty string" do
      assert_raise ArgumentError, "empty input", fn ->
        StyleName.new("")
      end
    end

    test "raises on lowercase start" do
      assert_raise ArgumentError, "invalid format", fn ->
        StyleName.new("chess")
      end
    end

    test "raises on digit start" do
      assert_raise ArgumentError, "invalid format", fn ->
        StyleName.new("1Chess")
      end
    end

    test "raises on input too long" do
      input = String.duplicate("A", 33)

      assert_raise ArgumentError, "input too long", fn ->
        StyleName.new(input)
      end
    end

    test "raises on invalid characters" do
      assert_raise ArgumentError, "invalid format", fn ->
        StyleName.new("Chess-960")
      end
    end
  end

  # ============================================================================
  # to_string/1
  # ============================================================================

  describe "to_string/1" do
    test "returns the name" do
      snn = StyleName.new("Chess")
      assert StyleName.to_string(snn) == "Chess"
    end

    test "returns name with numeric suffix" do
      snn = StyleName.new("Chess960")
      assert StyleName.to_string(snn) == "Chess960"
    end

    test "returns single letter name" do
      snn = StyleName.new("A")
      assert StyleName.to_string(snn) == "A"
    end
  end

  # ============================================================================
  # Struct Fields
  # ============================================================================

  describe "struct fields" do
    test "name field is accessible" do
      snn = StyleName.new("Shogi")
      assert snn.name == "Shogi"
    end

    test "struct has expected shape" do
      snn = StyleName.new("Xiangqi")
      assert %StyleName{name: "Xiangqi"} = snn
    end
  end

  # ============================================================================
  # Struct Equality
  # ============================================================================

  describe "struct equality" do
    test "style names with same name are equal" do
      snn1 = StyleName.new("Chess")
      snn2 = StyleName.new("Chess")
      assert snn1 == snn2
    end

    test "style names with different names are not equal" do
      snn1 = StyleName.new("Chess")
      snn2 = StyleName.new("Shogi")
      refute snn1 == snn2
    end
  end

  # ============================================================================
  # String.Chars Protocol
  # ============================================================================

  describe "String.Chars protocol" do
    test "to_string/1 works via protocol" do
      snn = StyleName.new("Chess")
      assert to_string(snn) == "Chess"
    end

    test "string interpolation works" do
      snn = StyleName.new("Shogi")
      assert "Playing #{snn}" == "Playing Shogi"
    end

    test "Enum.join works" do
      styles = [StyleName.new("Chess"), StyleName.new("Shogi")]
      assert Enum.join(styles, ", ") == "Chess, Shogi"
    end
  end

  # ============================================================================
  # Inspect Protocol
  # ============================================================================

  describe "Inspect protocol" do
    test "inspect returns readable representation" do
      snn = StyleName.new("Chess")
      assert inspect(snn) == "#Sashite.Snn.StyleName<Chess>"
    end

    test "inspect with numeric suffix" do
      snn = StyleName.new("Chess960")
      assert inspect(snn) == "#Sashite.Snn.StyleName<Chess960>"
    end

    test "inspect with single letter" do
      snn = StyleName.new("A")
      assert inspect(snn) == "#Sashite.Snn.StyleName<A>"
    end
  end
end
