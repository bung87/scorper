# https://tools.ietf.org/html/rfc3986#section-2.2
{.push hint[Name]: off.}
const URL_gen_delims* = {':', '/', '?', '#', '[', ']', '@'}

const URL_sub_delims* = {'!', '$', '&', '\'', '(', ')',
               '*', '+', ',', ';', '='}

const URL_reserved* = URL_gen_delims + URL_sub_delims

const URL_unreserved* = {'a'..'z', 'A'..'Z', '0'..'9', '-', '.', '_', '~'}

# path component
const URL_pchar* = URL_unreserved + URL_sub_delims + {':', '@', '%'}     # + pct-encoded

# query component
const URL_query* = URL_pchar + {'/', '?'}
{.pop.}