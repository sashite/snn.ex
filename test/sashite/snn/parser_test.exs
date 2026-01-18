defmodule Sashite.Snn.ParserTest do
  use ExUnit.Case, async: true

  alias Sashite.Snn.Parser

  doctest Parser

  # ============================================================================
  # Valid Inputs - Standard Names
  # ============================================================================

  describe "parse/1 with standard names" do
    test "parses 'Chess'" do
      assert {:ok, "Chess"} = Parser.parse("Chess")
    end

    test "parses 'Shogi'" do
      assert {:ok, "Shogi"} = Parser.parse("Shogi")
    end

    test "parses 'Xiangqi'" do
      assert {:ok, "Xiangqi"} = Parser.parse("Xiangqi")
    end

    test "parses 'Makruk'" do
      assert {:ok, "Makruk"} = Parser.parse("Makruk")
    end

    test "parses 'Go'" do
      assert {:ok, "Go"} = Parser.parse("Go")
    end
  end

  # ============================================================================
  # Valid Inputs - Single Letter
  # ============================================================================

  describe "parse/1 with single letter" do
    test "parses single uppercase letter 'A'" do
      assert {:ok, "A"} = Parser.parse("A")
    end

    test "parses single uppercase letter 'Z'" do
      assert {:ok, "Z"} = Parser.parse("Z")
    end

    test "parses all single uppercase letters A-Z" do
      for letter <- ?A..?Z do
        input = <<letter>>
        assert {:ok, ^input} = Parser.parse(input)
      end
    end
  end

  # ============================================================================
  # Valid Inputs - With Numeric Suffix
  # ============================================================================

  describe "parse/1 with numeric suffix" do
    test "parses 'Chess960'" do
      assert {:ok, "Chess960"} = Parser.parse("Chess960")
    end

    test "parses 'Shogi2'" do
      assert {:ok, "Shogi2"} = Parser.parse("Shogi2")
    end

    test "parses 'G5'" do
      assert {:ok, "G5"} = Parser.parse("G5")
    end

    test "parses 'XY123'" do
      assert {:ok, "XY123"} = Parser.parse("XY123")
    end

    test "parses 'A1'" do
      assert {:ok, "A1"} = Parser.parse("A1")
    end

    test "parses name with leading zero in suffix" do
      assert {:ok, "Chess01"} = Parser.parse("Chess01")
    end
  end

  # ============================================================================
  # Valid Inputs - All Uppercase
  # ============================================================================

  describe "parse/1 with all uppercase" do
    test "parses 'CHESS'" do
      assert {:ok, "CHESS"} = Parser.parse("CHESS")
    end

    test "parses 'ABC'" do
      assert {:ok, "ABC"} = Parser.parse("ABC")
    end
  end

  # ============================================================================
  # Valid Inputs - Maximum Length
  # ============================================================================

  describe "parse/1 with maximum length" do
    test "parses string at exactly max length (32 chars)" do
      input = "Abcdefghijklmnopqrstuvwxyz123456"
      assert byte_size(input) == 32
      assert {:ok, ^input} = Parser.parse(input)
    end
  end

  # ============================================================================
  # valid?/1
  # ============================================================================

  describe "valid?/1" do
    test "returns true for valid standard names" do
      assert Parser.valid?("Chess")
      assert Parser.valid?("Shogi")
      assert Parser.valid?("Xiangqi")
    end

    test "returns true for single uppercase letters" do
      assert Parser.valid?("A")
      assert Parser.valid?("Z")
    end

    test "returns true for names with numeric suffix" do
      assert Parser.valid?("Chess960")
      assert Parser.valid?("G5")
    end

    test "returns false for empty string" do
      refute Parser.valid?("")
    end

    test "returns false for lowercase start" do
      refute Parser.valid?("chess")
    end

    test "returns false for digit start" do
      refute Parser.valid?("1Chess")
    end

    test "returns false for nil" do
      refute Parser.valid?(nil)
    end
  end

  # ============================================================================
  # Error Cases - Empty Input
  # ============================================================================

  describe "parse/1 with empty input" do
    test "returns error for empty string" do
      assert {:error, :empty_input} = Parser.parse("")
    end
  end

  # ============================================================================
  # Error Cases - Input Too Long
  # ============================================================================

  describe "parse/1 with input too long" do
    test "returns error for 33 characters" do
      input = "Abcdefghijklmnopqrstuvwxyz1234567"
      assert byte_size(input) == 33
      assert {:error, :input_too_long} = Parser.parse(input)
    end

    test "returns error for very long input" do
      input = String.duplicate("Chess", 100)
      assert {:error, :input_too_long} = Parser.parse(input)
    end
  end

  # ============================================================================
  # Error Cases - Invalid Format
  # ============================================================================

  describe "parse/1 with invalid format" do
    test "returns error for lowercase start" do
      assert {:error, :invalid_format} = Parser.parse("chess")
    end

    test "returns error for digit start" do
      assert {:error, :invalid_format} = Parser.parse("1Chess")
      assert {:error, :invalid_format} = Parser.parse("123")
    end

    test "returns error for letters after digits" do
      assert {:error, :invalid_format} = Parser.parse("Chess960A")
      assert {:error, :invalid_format} = Parser.parse("A1B")
    end

    test "returns error for hyphen" do
      assert {:error, :invalid_format} = Parser.parse("Chess-960")
    end

    test "returns error for underscore" do
      assert {:error, :invalid_format} = Parser.parse("Chess_Variant")
    end

    test "returns error for space" do
      assert {:error, :invalid_format} = Parser.parse("Chess 960")
      assert {:error, :invalid_format} = Parser.parse(" Chess")
      assert {:error, :invalid_format} = Parser.parse("Chess ")
    end

    test "returns error for special characters" do
      assert {:error, :invalid_format} = Parser.parse("Chess!")
      assert {:error, :invalid_format} = Parser.parse("Chess@960")
      assert {:error, :invalid_format} = Parser.parse("Chess#")
    end
  end

  # ============================================================================
  # Security - Null Byte Injection
  # ============================================================================

  describe "security: null byte injection" do
    test "rejects null byte alone" do
      refute Parser.valid?(<<0>>)
    end

    test "rejects name with embedded null byte" do
      refute Parser.valid?("Chess" <> <<0>> <> "960")
    end

    test "rejects name followed by null byte" do
      refute Parser.valid?("Chess" <> <<0>>)
    end

    test "rejects null byte followed by name" do
      refute Parser.valid?(<<0>> <> "Chess")
    end
  end

  # ============================================================================
  # Security - Control Characters
  # ============================================================================

  describe "security: control characters" do
    test "rejects newline" do
      refute Parser.valid?("Chess\n")
      refute Parser.valid?("\nChess")
      refute Parser.valid?("Chess\nShogi")
    end

    test "rejects carriage return" do
      refute Parser.valid?("Chess\r")
      refute Parser.valid?("\rChess")
    end

    test "rejects tab" do
      refute Parser.valid?("Chess\t")
      refute Parser.valid?("\tChess")
    end

    test "rejects other control characters" do
      refute Parser.valid?(<<0x01>>)  # SOH
      refute Parser.valid?(<<0x1B>>)  # ESC
      refute Parser.valid?(<<0x7F>>)  # DEL
    end
  end

  # ============================================================================
  # Security - Unicode Lookalikes
  # ============================================================================

  describe "security: Unicode lookalikes" do
    test "rejects Cyrillic lookalikes" do
      # Cyrillic 'С' (U+0421) looks like Latin 'C'
      refute Parser.valid?(<<0xD0, 0xA1>> <> "hess")
    end

    test "rejects Greek lookalikes" do
      # Greek 'Α' (U+0391) looks like Latin 'A'
      refute Parser.valid?(<<0xCE, 0x91>>)
    end

    test "rejects full-width characters" do
      # Full-width 'C' (U+FF23)
      refute Parser.valid?(<<0xEF, 0xBC, 0xA3>> <> "hess")
    end
  end

  # ============================================================================
  # Security - Combining Characters
  # ============================================================================

  describe "security: combining characters" do
    test "rejects combining acute accent" do
      # 'C' + combining acute accent (U+0301)
      refute Parser.valid?("C" <> <<0xCC, 0x81>> <> "hess")
    end

    test "rejects combining diaeresis" do
      # 'C' + combining diaeresis (U+0308)
      refute Parser.valid?("C" <> <<0xCC, 0x88>>)
    end
  end

  # ============================================================================
  # Security - Zero-Width Characters
  # ============================================================================

  describe "security: zero-width characters" do
    test "rejects zero-width space" do
      # Zero-width space (U+200B)
      refute Parser.valid?(<<0xE2, 0x80, 0x8B>>)
      refute Parser.valid?("Chess" <> <<0xE2, 0x80, 0x8B>>)
    end

    test "rejects zero-width non-joiner" do
      # Zero-width non-joiner (U+200C)
      refute Parser.valid?(<<0xE2, 0x80, 0x8C>>)
    end

    test "rejects BOM" do
      # Byte order mark (U+FEFF)
      refute Parser.valid?(<<0xEF, 0xBB, 0xBF>>)
      refute Parser.valid?(<<0xEF, 0xBB, 0xBF>> <> "Chess")
    end
  end

  # ============================================================================
  # Security - Non-ASCII Letters
  # ============================================================================

  describe "security: non-ASCII letters" do
    test "rejects accented characters" do
      refute Parser.valid?("Échecs")  # French for Chess
      refute Parser.valid?("Schäch")
    end

    test "rejects non-Latin scripts" do
      refute Parser.valid?("将棋")    # Japanese for Shogi
      refute Parser.valid?("象棋")    # Chinese for Xiangqi
    end
  end

  # ============================================================================
  # Security - Non-String Input
  # ============================================================================

  describe "security: non-string input" do
    test "rejects nil" do
      refute Parser.valid?(nil)
    end

    test "rejects integer" do
      refute Parser.valid?(123)
    end

    test "rejects list" do
      refute Parser.valid?([?C, ?h, ?e, ?s, ?s])
    end

    test "rejects atom" do
      refute Parser.valid?(:Chess)
    end

    test "rejects map" do
      refute Parser.valid?(%{name: "Chess"})
    end
  end

  # ============================================================================
  # Round-Trip Tests
  # ============================================================================

  describe "round-trip" do
    test "valid names round-trip correctly" do
      names = ~w(Chess Shogi Xiangqi Makruk Go Chess960 A Z XY123)

      for name <- names do
        assert {:ok, ^name} = Parser.parse(name)
      end
    end
  end
end
