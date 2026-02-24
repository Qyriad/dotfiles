;; extends
; vim: noet ts=2 sw=0

(interpolation) @none

(
	;(interpolation ["${" "}"] @punctuation.bracket)
	"${" @punctuation.bracket
	(_) @embedded
	"}" @punctuation.bracket
	(#set! "priority" 105)
)
