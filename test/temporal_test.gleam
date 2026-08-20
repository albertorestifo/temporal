import gleeunit
import gleeunit/should
import temporal

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn out_of_range_uses_field_variant_test() {
  temporal.OutOfRange(field: temporal.Year, value: "275760")
  |> should.equal(temporal.OutOfRange(field: temporal.Year, value: "275760"))
}

pub fn invalid_option_uses_option_kind_variant_test() {
  temporal.InvalidOption(option: temporal.RoundingModeOption)
  |> should.equal(temporal.InvalidOption(option: temporal.RoundingModeOption))
}

pub fn platform_unavailable_uses_operation_variant_test() {
  temporal.PlatformUnavailable(operation: temporal.SystemClock)
  |> should.equal(temporal.PlatformUnavailable(operation: temporal.SystemClock))
}
