# snn.ex

[![Hex.pm](https://img.shields.io/hexpm/v/sashite_snn.svg)](https://hex.pm/packages/sashite_snn)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/sashite_snn)
[![License](https://img.shields.io/hexpm/l/sashite_snn.svg)](https://github.com/sashite/snn.ex/blob/main/LICENSE)

> **SNN** (Style Name Notation) implementation for Elixir.

## Overview

This library implements the [SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/).

### Implementation Constraints

| Constraint | Value | Rationale |
|------------|-------|-----------|
| Max string length | 32 | Sufficient for realistic style names |

These constraints enable bounded memory usage and safe parsing.

## Installation

Add `sashite_snn` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sashite_snn, "~> 2.0"}
  ]
end
```

## Usage

### Parsing (String → StyleName)

Convert an SNN string into a `StyleName` struct.

```elixir
alias Sashite.Snn.StyleName

# Standard parsing (returns {:ok, _} or {:error, _})
{:ok, snn} = Sashite.Snn.parse("Chess")
snn.name  # => "Chess"

# With numeric suffix
{:ok, snn} = Sashite.Snn.parse("Chess960")
snn.name  # => "Chess960"

# Bang version (raises on error)
snn = Sashite.Snn.parse!("Shogi")

# Invalid input returns error tuple
{:error, :empty_input} = Sashite.Snn.parse("")
{:error, :invalid_format} = Sashite.Snn.parse("chess")
```

### Formatting (StyleName → String)

Convert a `StyleName` back to an SNN string.

```elixir
alias Sashite.Snn.StyleName

# From StyleName struct
snn = StyleName.new("Chess")
StyleName.to_string(snn)  # => "Chess"

# String interpolation (via String.Chars protocol)
"Playing #{snn}"  # => "Playing Chess"
```

### Validation

```elixir
# Boolean check
Sashite.Snn.valid?("Chess")     # => true
Sashite.Snn.valid?("Chess960")  # => true
Sashite.Snn.valid?("chess")     # => false (lowercase start)
Sashite.Snn.valid?("")          # => false (empty)
```

### Accessing Data

```elixir
snn = Sashite.Snn.parse!("Chess960")

# Get the name (struct field)
snn.name  # => "Chess960"
```

## API Reference

### Types

```elixir
# StyleName represents a validated SNN style name.
%Sashite.Snn.StyleName{
  name: String.t()  # The validated SNN string
}

# Create a StyleName from a valid name string.
# Raises ArgumentError if the name is invalid.
Sashite.Snn.StyleName.new(name)
```

### Constants

```elixir
Sashite.Snn.Constants.max_string_length()  # => 32
```

### Parsing

```elixir
# Parses an SNN string into a StyleName.
# Returns {:ok, style_name} or {:error, reason}.
@spec Sashite.Snn.parse(String.t()) :: {:ok, StyleName.t()} | {:error, atom()}

# Parses an SNN string into a StyleName.
# Raises ArgumentError if the string is not valid.
@spec Sashite.Snn.parse!(String.t()) :: StyleName.t()
```

### Validation

```elixir
# Reports whether string is a valid SNN style name.
@spec Sashite.Snn.valid?(String.t()) :: boolean()
```

### Errors

Parsing errors are returned as atoms:

| Atom | Cause |
|------|-------|
| `:empty_input` | String length is 0 |
| `:input_too_long` | String exceeds 32 characters |
| `:invalid_format` | Does not match SNN format |

## Design Principles

- **Bounded values**: Maximum string length prevents resource exhaustion
- **Struct-based**: `StyleName` struct enables pattern matching and encapsulation
- **Elixir idioms**: `{:ok, _}` / `{:error, _}` tuples, `parse!` bang variant
- **Immutable data**: Struct fields are read-only after creation
- **No dependencies**: Pure Elixir standard library only

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [SNN Specification](https://sashite.dev/specs/snn/1.0.0/) — Official specification
- [SNN Examples](https://sashite.dev/specs/snn/1.0.0/examples/) — Usage examples

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
