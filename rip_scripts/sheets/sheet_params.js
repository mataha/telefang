// Currently only works for the SMS and Field Guide sheet.
// Formatting parameters only lightly configurable at the moment.
// Would need extension to support more complex formatting (e.g. questions).
var SHEET_PARAMS = {
  "script/denjuu/sms.messages.csv": {
    width: 6 * 8,
    min_lines: 6,
    line_spacing: 0,
    prelude: '',
    envoi: '<*4>'
  },
  "script/denjuu/descriptions.messages.csv": {
    width: 14 * 8,
    lines_per_page: 3,
    line_spacing: 1,
    prelude: '<S0>',
    envoi: '<*4>'
  }
}
