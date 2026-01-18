defmodule Sashite.Snn.Parser do
  @moduledoc """
  Secure parser for SNN (Style Name Notation) strings.

  Designed for untrusted input: validates bounds first, parses character
  by character, and enforces strict constraints at every step.

  ## SNN Format

  An SNN token is a PascalCase name with optional numeric suffix:
  - Starts with exactly one uppercase letter (A-Z)
  - Followed by zero or more letters (A-Z, a-z)
  - Ends with zero or more digits (0-9)

  ## Examples

      iex> Sashite.Snn.Parser.parse("Chess")
      {:ok, "Chess"}

      iex> Sashite.Snn.Parser.parse("Chess960")
      {:ok, "Chess960"}

      iex> Sashite.Snn.Parser.parse("chess")
      {:error, :invalid_format}

  See: https://sashite.dev/specs/snn/1.0.0/
  """

  alias Sashite.Snn.Constants

  @max_string_length Constants.max_string_length()

  @doc """
  Parses an SNN string, validating its format.

  Performs validation in order of computational cost:

  1. Type and length check (O(1) - immediate rejection of oversized input)
  2. First character check (O(1))
  3. Character-by-character parsing with state transitions

  ## Examples

      iex> Sashite.Snn.Parser.parse("Chess")
      {:ok, "Chess"}

      iex> Sashite.Snn.Parser.parse("Shogi")
      {:ok, "Shogi"}

      iex> Sashite.Snn.Parser.parse("Chess960")
      {:ok, "Chess960"}

      iex> Sashite.Snn.Parser.parse("A")
      {:ok, "A"}

      iex> Sashite.Snn.Parser.parse("")
      {:error, :empty_input}

      iex> Sashite.Snn.Parser.parse("chess")
      {:error, :invalid_format}

      iex> Sashite.Snn.Parser.parse("123")
      {:error, :invalid_format}
  """
  @spec parse(String.t()) :: {:ok, String.t()} | {:error, atom()}
  def parse(input) when is_binary(input) do
    byte_size = byte_size(input)

    cond do
      byte_size == 0 ->
        {:error, :empty_input}

      byte_size > @max_string_length ->
        {:error, :input_too_long}

      true ->
        parse_first_char(input)
    end
  end

  def parse(_), do: {:error, :invalid_format}

  @doc """
  Reports whether the input is a valid SNN string.

  ## Examples

      iex> Sashite.Snn.Parser.valid?("Chess")
      true

      iex> Sashite.Snn.Parser.valid?("Chess960")
      true

      iex> Sashite.Snn.Parser.valid?("chess")
      false

      iex> Sashite.Snn.Parser.valid?("")
      false

      iex> Sashite.Snn.Parser.valid?(nil)
      false
  """
  @spec valid?(term()) :: boolean()
  def valid?(input) do
    case parse(input) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  # ==========================================================================
  # Private Functions
  # ==========================================================================

  # Entry point: validate first character is uppercase letter
  defp parse_first_char(<<byte, rest::binary>> = input) do
    if uppercase?(byte) do
      parse_letters(rest, input)
    else
      {:error, :invalid_format}
    end
  end

  # --- Letter Parsing (after initial uppercase) ---

  # End of input while parsing letters - valid
  defp parse_letters(<<>>, input) do
    {:ok, input}
  end

  # Continue parsing letters or transition to digits
  defp parse_letters(<<byte, rest::binary>>, input) do
    cond do
      letter?(byte) ->
        parse_letters(rest, input)

      digit?(byte) ->
        parse_digits(rest, input)

      true ->
        {:error, :invalid_format}
    end
  end

  # --- Digit Parsing (after letters) ---

  # End of input while parsing digits - valid
  defp parse_digits(<<>>, input) do
    {:ok, input}
  end

  # Continue parsing digits only (no return to letters)
  defp parse_digits(<<byte, rest::binary>>, input) do
    if digit?(byte) do
      parse_digits(rest, input)
    else
      # Letter or other character after digits is invalid
      {:error, :invalid_format}
    end
  end

  # ==========================================================================
  # Character Class Predicates
  # ==========================================================================

  defp uppercase?(byte), do: byte >= 0x41 and byte <= 0x5A
  defp lowercase?(byte), do: byte >= 0x61 and byte <= 0x7A
  defp letter?(byte), do: uppercase?(byte) or lowercase?(byte)
  defp digit?(byte), do: byte >= 0x30 and byte <= 0x39
end
