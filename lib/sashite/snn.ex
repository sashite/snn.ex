defmodule Sashite.Snn do
  @moduledoc """
  Implementation of the **SNN** (Style Name Notation) specification.

  SNN provides a human-readable naming system for game styles in abstract strategy
  board games. It uses PascalCase names with optional numeric suffixes.

  This module implements strict parsing, validation, and protocol support for SNN tokens.
  """

  # Define the struct with enforced keys
  @enforce_keys [:name]
  defstruct [:name]

  @typedoc "A struct representing a valid SNN token."
  @type t :: %__MODULE__{
          name: String.t()
        }

  # Regex: Starts with Uppercase, followed by letters, optionally ending with digits.
  # Based on spec: ^[A-Z][a-zA-Z]*[0-9]*$
  # Note: We use \A and \z for absolute start/end of string security,
  # though the explicit check in valid? handles the line break constraint.
  @snn_regex ~r/\A[A-Z][a-zA-Z]*[0-9]*\z/

  @doc """
  Checks if a string conforms to the SNN format.
  It explicitly rejects any input containing line breaks (\\r or \\n).

  ## Examples

      iex> Sashite.Snn.valid?("Chess")
      true

      iex> Sashite.Snn.valid?("Chess960")
      true

      iex> Sashite.Snn.valid?("Chess\\n")
      false

      iex> Sashite.Snn.valid?("chess")
      false

      iex> Sashite.Snn.valid?("")
      false
  """
  @spec valid?(String.t()) :: boolean()
  def valid?(s) when is_binary(s) do
    # Spec requirement: Implementations MUST reject any input containing line breaks
    if String.contains?(s, ["\r", "\n"]) do
      false
    else
      Regex.match?(@snn_regex, s)
    end
  end

  def valid?(_), do: false

  @doc """
  Returns the compiled regular expression used for SNN validation.
  """
  @spec regex() :: Regex.t()
  def regex, do: @snn_regex

  @doc """
  Parses a string into an SNN struct.

  Returns `{:ok, snn}` if valid, or `{:error, reason}` otherwise.

  ## Examples

      iex> Sashite.Snn.parse("Shogi")
      {:ok, %Sashite.Snn{name: "Shogi"}}

      iex> Sashite.Snn.parse("invalid")
      {:error, :invalid_format}
  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, atom()}
  def parse(s) when is_binary(s) do
    if valid?(s) do
      {:ok, %__MODULE__{name: s}}
    else
      {:error, :invalid_format}
    end
  end

  def parse(_), do: {:error, :invalid_format}

  @doc """
  Parses a string into an SNN struct, raising on error.

  ## Examples

      iex> Sashite.Snn.parse!("Xiangqi")
      %Sashite.Snn{name: "Xiangqi"}

      iex> Sashite.Snn.parse!("invalid")
      ** (ArgumentError) invalid SNN format: "invalid"
  """
  @spec parse!(String.t()) :: t()
  def parse!(s) do
    case parse(s) do
      {:ok, snn} -> snn
      {:error, _} -> raise ArgumentError, "invalid SNN format: #{inspect(s)}"
    end
  end
end

# ------------------------------------------------------------------------------
# Protocol Implementations
# ------------------------------------------------------------------------------

defimpl String.Chars, for: Sashite.Snn do
  def to_string(snn), do: snn.name
end

defimpl Inspect, for: Sashite.Snn do
  import Inspect.Algebra

  def inspect(snn, _opts) do
    # Custom inspection to make logs cleaner: #Sashite.Snn<Name>
    concat(["#Sashite.Snn<", snn.name, ">"])
  end
end
