import app
import lustre
import lustre/effect
import timetravel

pub fn main() {
  let debug_app =
    timetravel.application(
      fn(args) { #(app.init(args), effect.none()) },
      fn(model, message) { #(app.update(model, message), effect.none()) },
      app.view,
    )
  let assert Ok(_) = lustre.start(debug_app, "#app", Nil)
  Nil
}
