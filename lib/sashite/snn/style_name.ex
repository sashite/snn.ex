defmodule Sashite.Snn.StyleName do
  @moduledoc """
  Represents a validated SNN (Style Name Notation) style name.

  A StyleName encodes a single attribute:
  - `name`: the validated SNN string (PascalCase with optional numeric suffix)

  StyleName structs are immutable. The name is validated upon creation.

  ## Examples

      iex> snn = Sashite.Snn.StyleName.new("Chess")
      iex> snn.name
      "Chess"

      iex> snn = Sashite.Snn.StyleName.new("Chess960")
      iex> Sashite.Snn.StyleName.to_string(snn)
      "Chess960"

  See: https://sashite.dev/specs/snn/1.0.0/
  """

  alias Sashite.Snn.Parser

  @enforce_keys [:name]
  defstruct [:name]

  @typedoc "An SNN style name struct"
  @type t :: %__MODULE__{
          name: String.t()
        }

  # ==========================================================================
  # Constructor
  # ==========================================================================

  @doc """
  Creates a new StyleName with the given name.

  ## Parameters

  - `name` - The SNN string (must be valid PascalCase format)

  ## Returns

  A new `%StyleName{}` struct.

  ## Raises

  - `ArgumentError` if name is invalid

  ## Examples

      iex> snn = Sashite.Snn.StyleName.new("Chess")
      iex> snn.name
      "Chess"

      iex> snn = Sashite.Snn.StyleName.new("Chess960")
      iex> snn.name
      "Chess960"

      iex> Sashite.Snn.StyleName.new("chess")
      ** (ArgumentError) invalid format

      iex> Sashite.Snn.StyleName.new("")
      ** (ArgumentError) empty input
  """
  @spec new(String.t()) :: t()
  def new(name) do
    case Parser.parse(name) do
      {:ok, validated_name} ->
        %__MODULE__{name: validated_name}

      {:error, reason} ->
        raise ArgumentError, error_message(reason)
    end
  end

  # ==========================================================================
  # String Conversion
  # ==========================================================================

  @doc """
  Returns the SNN string representation.

  ## Examples

      iex> snn = Sashite.Snn.StyleName.new("Chess")
      iex> Sashite.Snn.StyleName.to_string(snn)
      "Chess"

      iex> snn = Sashite.Snn.StyleName.new("Xiangqi")
      iex> Sashite.Snn.StyleName.to_string(snn)
      "Xiangqi"
  """
  @spec to_string(t()) :: String.t()
  def to_string(%__MODULE__{name: name}) do
    name
  end

  # ==========================================================================
  # Private Helpers
  # ==========================================================================

  defp error_message(:empty_input), do: "empty input"
  defp error_message(:input_too_long), do: "input too long"
  defp error_message(:invalid_format), do: "invalid format"
end

defimpl String.Chars, for: Sashite.Snn.StyleName do
  def to_string(style_name) do
    Sashite.Snn.StyleName.to_string(style_name)
  end
end

defimpl Inspect, for: Sashite.Snn.StyleName do
  def inspect(style_name, _opts) do
    "#Sashite.Snn.StyleName<#{Sashite.Snn.StyleName.to_string(style_name)}>"
  end
end
