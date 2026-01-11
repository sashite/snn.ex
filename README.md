# Sashite.Snn

[![Hex.pm](https://img.shields.io/hexpm/v/sashite_snn.svg)](https://hex.pm/packages/sashite_snn)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/sashite_snn)
[![License](https://img.shields.io/hexpm/l/sashite_snn.svg)](https://github.com/sashite/snn.ex/blob/main/LICENSE.md)

> **SNN** (Style Name Notation) implementation for Elixir.

## What is SNN?

SNN (Style Name Notation) provides a human-readable naming system for game styles (Piece Styles) in abstract strategy board games. It uses PascalCase names with optional numeric suffixes to identify movement traditions or game variants.

This library implements the [SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/).

## Installation

Add `sashite_snn` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sashite_snn, "~> 1.0"}
  ]
end

```

## SNN Format

SNN tokens follow a strict structure: `[PascalCaseName][OptionalSuffix]`

| Component | Rule | Examples |
| --- | --- | --- |
| **Start** | Must start with an Uppercase letter (`A`-`Z`) | `C`, `S`, `X` |
| **Body** | Followed by optional letters (`A`-`Z`, `a`-`z`) | `Chess`, `Shogi` |
| **Suffix** | Ends with optional digits (`0`-`9`) | `Chess960`, `G5` |

## Usage

The API is designed to be idiomatic, leveraging pattern matching and protocols.

### Parsing

The `parse/1` function validates the format and returns a tagged tuple with a struct.

```elixir
iex> Sashite.Snn.parse("Chess")
{:ok, %Sashite.Snn{name: "Chess"}}

iex> Sashite.Snn.parse("Chess960")
{:ok, %Sashite.Snn{name: "Chess960"}}

# Invalid inputs
iex> Sashite.Snn.parse("chess") # Lowercase start
{:error, :invalid_format}

iex> Sashite.Snn.parse("Chess_960") # Invalid char
{:error, :invalid_format}

```

### Bang functions (Direct access)

Use `parse!/1` when you expect the input to be valid (e.g., constants).

```elixir
iex> snn = Sashite.Snn.parse!("Shogi")
%Sashite.Snn{name: "Shogi"}

```

### Protocol Implementation

The struct implements `String.Chars`, allowing seamless interpolation.

```elixir
iex> snn = Sashite.Snn.parse!("Xiangqi")
iex> "Playing #{snn}"
"Playing Xiangqi"

```

### Validation Only

If you only need a boolean check without creating a struct:

```elixir
iex> Sashite.Snn.valid?("Makruk")
true

iex> Sashite.Snn.valid?("")
false

```

## Regular Expression

The library exposes the compiled regex used for validation, useful for embedding in other validation logic.

```elixir
iex> Regex.match?(Sashite.Snn.regex(), "Go")
true

```

**Regex pattern:** `^[A-Z][a-zA-Z]*[0-9]*$`

## Use Cases

SNN is designed for identifying game styles in various contexts:

* **Game variant identification** (`Chess960`, `CapablancaChess`)
* **Multi-variant game engines**
* **Hybrid game configurations** (e.g., "Player 1 uses `Chess` style, Player 2 uses `Shogi` style")

## API Reference

### Types

```elixir
%Sashite.Snn{
  name: String.t() # The validated SNN string
}

```

### Functions

* `valid?/1` - Checks if a string conforms to the SNN format.
* `parse/1` - Converts a string to an SNN struct (returns `{:ok, snn}` or `{:error, reason}`).
* `parse!/1` - Same as parse but raises `ArgumentError` on failure.
* `regex/0` - Returns the `Regex` used for validation.

## Related Specifications

* [Game Protocol](https://sashite.dev/game-protocol/) – Conceptual foundation
* [SNN Specification](https://sashite.dev/specs/snn/1.0.0/) – Official specification
* [SIN](https://sashite.dev/specs/sin/) – Style Identifier Notation (compact single-character format)

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
