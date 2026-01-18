defmodule Sashite.Snn do
  @moduledoc """
  SNN (Style Name Notation) implementation for Elixir.

  SNN provides a human-readable naming system for game styles (Piece Styles)
  in abstract strategy board games. It uses PascalCase names with optional
  numeric suffixes to identify movement traditions or game variants.

  ## Examples

      iex> {:ok, snn} = Sashite.Snn.parse("Chess")
      iex> snn.name
      "Chess"

      iex> snn = Sashite.Snn.parse!("Chess960")
      iex> snn.name
      "Chess960"

      iex> Sashite.Snn.valid?("Shogi")
      true

      iex> Sashite.Snn.valid?("shogi")
      false

  See: https://sashite.dev/specs/snn/1.0.0/
  """

  alias Sashite.Snn.Parser
  alias Sashite.Snn.StyleName

  @doc """
  Parses an SNN string into a StyleName.

  ## Parameters

  - `input` - The SNN string to parse

  ## Returns

  - `{:ok, %StyleName{}}` on success
  - `{:error, reason}` on failure

  ## Error Reasons

  - `:empty_input` - String length is 0
  - `:input_too_long` - String exceeds 32 characters
  - `:invalid_format` - Does not match SNN format

  ## Examples

      iex> {:ok, snn} = Sashite.Snn.parse("Chess")
      iex> snn.name
      "Chess"

      iex> {:ok, snn} = Sashite.Snn.parse("Chess960")
      iex> snn.name
      "Chess960"

      iex> Sashite.Snn.parse("")
      {:error, :empty_input}

      iex> Sashite.Snn.parse("chess")
      {:error, :invalid_format}

      iex> Sashite.Snn.parse("123")
      {:error, :invalid_format}
  """
  @spec parse(String.t()) :: {:ok, StyleName.t()} | {:error, atom()}
  def parse(input) do
    case Parser.parse(input) do
      {:ok, name} ->
        {:ok, %StyleName{name: name}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Parses an SNN string into a StyleName, raising on error.

  ## Parameters

  - `input` - The SNN string to parse

  ## Returns

  A `%StyleName{}` struct.

  ## Raises

  - `ArgumentError` if the input is invalid

  ## Examples

      iex> snn = Sashite.Snn.parse!("Chess")
      iex> snn.name
      "Chess"

      iex> snn = Sashite.Snn.parse!("Shogi")
      iex> snn.name
      "Shogi"

      iex> Sashite.Snn.parse!("")
      ** (ArgumentError) empty input

      iex> Sashite.Snn.parse!("chess")
      ** (ArgumentError) invalid format
  """
  @spec parse!(String.t()) :: StyleName.t()
  def parse!(input) do
    case parse(input) do
      {:ok, style_name} ->
        style_name

      {:error, reason} ->
        raise ArgumentError, error_message(reason)
    end
  end

  @doc """
  Reports whether the input is a valid SNN string.

  ## Examples

      iex> Sashite.Snn.valid?("Chess")
      true

      iex> Sashite.Snn.valid?("Chess960")
      true

      iex> Sashite.Snn.valid?("A")
      true

      iex> Sashite.Snn.valid?("")
      false

      iex> Sashite.Snn.valid?("chess")
      false

      iex> Sashite.Snn.valid?(nil)
      false
  """
  @spec valid?(term()) :: boolean()
  def valid?(input) do
    Parser.valid?(input)
  end

  # ==========================================================================
  # Private Helpers
  # ==========================================================================

  defp error_message(:empty_input), do: "empty input"
  defp error_message(:input_too_long), do: "input too long"
  defp error_message(:invalid_format), do: "invalid format"
end
