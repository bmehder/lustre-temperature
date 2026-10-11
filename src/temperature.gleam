/// A single source value, tagged with the unit it was entered in.
/// Editing either input replaces this value; the other unit is derived.
pub type Temperature {
  Celsius(Float)
  Fahrenheit(Float)
}

/// Return the temperature in degrees Celsius.
pub fn in_celsius(temperature: Temperature) -> Float {
  case temperature {
    Celsius(value) -> value
    Fahrenheit(value) -> { value -. 32.0 } *. 5.0 /. 9.0
  }
}

/// Return the temperature in degrees Fahrenheit.
pub fn in_fahrenheit(temperature: Temperature) -> Float {
  case temperature {
    Celsius(value) -> value *. 9.0 /. 5.0 +. 32.0
    Fahrenheit(value) -> value
  }
}
