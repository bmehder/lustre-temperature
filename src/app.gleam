import gleam/float
import gleam/int
import gleam/result
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import temperature.{type Temperature, Celsius, Fahrenheit}

pub type Model {
  Model(temperature: Temperature)
}

pub type Message {
  UserChangedCelsiusInput(String)
  UserChangedFahrenheitInput(String)
  UserSelectedPreset(Float)
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

pub fn init(_args: Nil) -> Model {
  Model(Celsius(0.0))
}

pub fn update(model: Model, message: Message) -> Model {
  case message {
    UserChangedCelsiusInput(input) -> update_temperature(model, input, Celsius)
    UserChangedFahrenheitInput(input) ->
      update_temperature(model, input, Fahrenheit)
    UserSelectedPreset(value) -> Model(Celsius(value))
  }
}

fn update_temperature(
  model: Model,
  input: String,
  unit: fn(Float) -> Temperature,
) -> Model {
  float.parse(input)
  |> result.or(int.parse(input) |> result.map(int.to_float))
  |> result.map(fn(value) { Model(unit(value)) })
  |> result.unwrap(model)
}

pub fn temperature_values(model: Model) -> #(String, String) {
  #(
    temperature.in_celsius(model.temperature) |> format_temperature,
    temperature.in_fahrenheit(model.temperature) |> format_temperature,
  )
}

/// Round for display without changing the stored temperature.
pub fn format_temperature(value: Float) -> String {
  value |> float.to_precision(1) |> float.to_string
}

pub fn view(model: Model) -> Element(Message) {
  let #(celsius, fahrenheit) = temperature_values(model)
  html.div([], [
    html.main(
      [
        attribute.class(
          "min-h-dvh bg-stone-50 text-zinc-900 transition-colors dark:bg-zinc-950 dark:text-zinc-100 px-6 py-8 sm:py-12",
        ),
      ],
      [
        html.div([attribute.class("mx-auto max-w-xl")], [
          html.header([], [
            html.p(
              [
                attribute.class(
                  "text-sm font-medium tracking-wide text-zinc-500 dark:text-zinc-400",
                ),
              ],
              [html.text("°C / °F")],
            ),
          ]),
          html.section([attribute.class("mt-20 sm:mt-28")], [
            html.p(
              [
                attribute.class(
                  "text-xs font-semibold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400",
                ),
              ],
              [html.text("A matter of degrees")],
            ),
            html.h1(
              [
                attribute.class(
                  "mt-4 text-4xl font-semibold tracking-tight sm:text-5xl",
                ),
              ],
              [html.text("Temperature")],
            ),
            html.p(
              [
                attribute.class(
                  "mt-4 text-base leading-relaxed text-zinc-500 dark:text-zinc-400",
                ),
              ],
              [
                html.text(
                  "Edit either value, then press Enter or leave the field to convert.",
                ),
              ],
            ),
            html.div([attribute.class("mt-10 grid gap-4 sm:grid-cols-2")], [
              temperature_input(
                "celsius",
                "Celsius",
                "°C",
                celsius,
                UserChangedCelsiusInput,
              ),
              temperature_input(
                "fahrenheit",
                "Fahrenheit",
                "°F",
                fahrenheit,
                UserChangedFahrenheitInput,
              ),
            ]),
            html.div(
              [
                attribute.class(
                  "mt-8 border-t border-zinc-200 pt-6 dark:border-zinc-800",
                ),
              ],
              [
                html.p(
                  [
                    attribute.class(
                      "text-xs uppercase tracking-widest text-zinc-500",
                    ),
                  ],
                  [html.text("Quick reference")],
                ),
                html.div([attribute.class("mt-3 flex flex-wrap gap-2")], [
                  preset("Freezing · 0 °C", 0.0),
                  preset("Room · 20 °C", 20.0),
                  preset("Boiling · 100 °C", 100.0),
                ]),
              ],
            ),
          ]),
        ]),
      ],
    ),
  ])
}

fn temperature_input(
  id: String,
  label: String,
  unit: String,
  value: String,
  edited: fn(String) -> Message,
) -> Element(Message) {
  html.div(
    [
      attribute.class(
        "rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900",
      ),
    ],
    [
      html.label(
        [
          attribute.for(id),
          attribute.class("text-sm text-zinc-500 dark:text-zinc-400"),
        ],
        [html.text(label)],
      ),
      html.div([attribute.class("mt-4 flex items-baseline gap-2")], [
        html.input([
          attribute.id(id),
          attribute.type_("number"),
          attribute.value(value),
          event.on_change(edited),
          attribute.class(
            "w-full min-w-0 rounded-sm bg-transparent text-4xl font-medium tracking-tight outline-none focus-visible:ring-2 focus-visible:ring-orange-500 sm:text-5xl",
          ),
        ]),
        html.span(
          [attribute.class("text-xl text-orange-600 dark:text-orange-400")],
          [html.text(unit)],
        ),
      ]),
    ],
  )
}

fn preset(label: String, value: Float) -> Element(Message) {
  html.button(
    [
      attribute.type_("button"),
      event.on_click(UserSelectedPreset(value)),
      attribute.class(
        "rounded-lg bg-zinc-100 px-3 py-2 text-xs text-zinc-600 hover:bg-zinc-200 focus-visible:outline-2 focus-visible:outline-orange-500 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:bg-zinc-800",
      ),
    ],
    [html.text(label)],
  )
}
