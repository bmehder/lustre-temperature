# Temperature experiment

A small Celsius ↔ Fahrenheit converter, eventually using Lustre, Tailwind,
and dark mode. For now, this project contains only the domain model.

## One source of truth

`Temperature` holds either `Celsius(Float)` or `Fahrenheit(Float)`, preserving
the unit of the latest edit. It never stores two independently mutable values.

- A Celsius edit replaces the temperature with `Celsius(value)`.
- A Fahrenheit edit replaces it with `Fahrenheit(value)`.
- Rendering reads `in_celsius` and `in_fahrenheit` from that same temperature.

Conversion is a pure calculation, not another edit event, so it cannot trigger
a feedback loop. The source value also avoids repeated round-trip conversion
and the resulting floating-point drift.

The formulas are `F = C × 9 / 5 + 32` and `C = (F − 32) × 5 / 9`.
For example, `Celsius(0.0)` displays as 0 °C and 32 °F;
`Fahrenheit(212.0)` displays as 100 °C and 212 °F.

## UI concerns for later

The UI will retain raw text for empty, invalid, or unfinished input such as `-`
or `12.`. Parsing, display rounding, edit messages, and input validation belong
there. Domain conversions use floats without rounding or enforcing a physical
temperature range.

Lustre, Tailwind, and dark mode are intentionally deferred to the UI step.
# lustre-temperature
