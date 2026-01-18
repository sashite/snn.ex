defmodule Sashite.Snn.Constants do
  @moduledoc """
  Constants for the SNN (Style Name Notation) specification.

  Defines validation constraints for SNN tokens.

  ## Examples

      iex> Sashite.Snn.Constants.max_string_length()
      32

  See: https://sashite.dev/specs/snn/1.0.0/
  """

  @max_string_length 32

  @doc """
  Returns the maximum length of a valid SNN string.

  ## Examples

      iex> Sashite.Snn.Constants.max_string_length()
      32
  """
  @spec max_string_length() :: pos_integer()
  def max_string_length, do: @max_string_length
end
