import app
import gleeunit
import gleeunit/should
import temperature

pub fn main() {
  gleeunit.main()
}

pub fn reference_temperatures_test() {
  temperature.in_fahrenheit(temperature.Celsius(0.0)) |> should.equal(32.0)
  temperature.in_celsius(temperature.Fahrenheit(212.0)) |> should.equal(100.0)
  temperature.in_fahrenheit(temperature.Celsius(-40.0)) |> should.equal(-40.0)
}

pub fn switching_source_test() {
  app.init(Nil)
  |> app.update(app.UserChangedCelsiusInput("100"))
  |> app.temperature_values
  |> should.equal(#("100.0", "212.0"))

  app.init(Nil)
  |> app.update(app.UserChangedCelsiusInput("100"))
  |> app.update(app.UserChangedFahrenheitInput("-40"))
  |> app.temperature_values
  |> should.equal(#("-40.0", "-40.0"))
}

pub fn decimal_input_test() {
  let model =
    app.init(Nil)
    |> app.update(app.UserChangedCelsiusInput("-30.5"))
  model.temperature |> should.equal(temperature.Celsius(-30.5))
  let model = app.update(model, app.UserChangedFahrenheitInput("98.6"))
  model.temperature |> should.equal(temperature.Fahrenheit(98.6))
}

pub fn preset_restores_temperature_test() {
  app.init(Nil)
  |> app.update(app.UserSelectedPreset(20.0))
  |> app.temperature_values
  |> should.equal(#("20.0", "68.0"))
}

pub fn temperature_display_test() {
  app.format_temperature(-0.244) |> should.equal("-0.2")
  app.format_temperature(31.56) |> should.equal("31.6")
  app.format_temperature(20.0) |> should.equal("20.0")

  let model =
    app.init(Nil)
    |> app.update(app.UserChangedCelsiusInput("-0.244"))
  app.temperature_values(model) |> should.equal(#("-0.2", "31.6"))
  model.temperature |> should.equal(temperature.Celsius(-0.244))
}
