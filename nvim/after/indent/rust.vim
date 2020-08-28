" Double indent function continuation instead of aligning.
setlocal cinoptions-=(0
let &l:cinoptions .= ',(' . &l:shiftwidth
