import gleam/float
import gleam/int
import gleam/result
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
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
          html.header([attribute.class("flex items-center justify-between")], [
            html.p(
              [
                attribute.class(
                  "text-sm font-medium tracking-wide text-zinc-500 dark:text-zinc-400",
                ),
              ],
              [html.text("°C / °F")],
            ),
            html.a(
              [
                attribute.href("https://github.com/bmehder/lustre-temperature"),
                attribute.target("_blank"),
                attribute.rel("noopener noreferrer"),
                attribute.aria_label("View source on GitHub"),
                attribute.title("View source on GitHub"),
                attribute.class(
                  "rounded-md p-2 text-zinc-500 hover:text-zinc-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-500 dark:text-zinc-400 dark:hover:text-zinc-100",
                ),
              ],
              [
                svg.svg(
                  [
                    attribute.attribute("viewBox", "0 0 16 16"),
                    attribute.attribute("fill", "currentColor"),
                    attribute.aria_hidden(True),
                    attribute.class("size-5"),
                  ],
                  [
                    svg.path([
                      attribute.attribute(
                        "d",
                        "M6.766 11.328c-2.063-.25-3.516-1.734-3.516-3.656 0-.781.281-1.625.75-2.188-.203-.515-.172-1.609.063-2.062.625-.078 1.468.25 1.968.703.594-.187 1.219-.281 1.985-.281.765 0 1.39.094 1.953.265.484-.437 1.344-.765 1.969-.687.218.422.25 1.515.046 2.047.5.593.766 1.39.766 2.203 0 1.922-1.453 3.375-3.547 3.64.531.344.89 1.094.89 1.954v1.625c0 .468.391.734.86.547C13.781 14.359 16 11.53 16 8.03 16 3.61 12.406 0 7.984 0 3.563 0 0 3.61 0 8.031a7.88 7.88 0 0 0 5.172 7.422c.422.156.828-.125.828-.547v-1.25c-.219.094-.5.156-.75.156-1.031 0-1.64-.562-2.078-1.609-.172-.422-.36-.672-.719-.719-.187-.015-.25-.093-.25-.187 0-.188.313-.328.625-.328.453 0 .844.281 1.25.86.313.452.64.655 1.031.655s.641-.14 1-.5c.266-.265.47-.5.657-.656",
                      ),
                    ]),
                  ],
                ),
              ],
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
