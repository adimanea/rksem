#lang pie

(add1
 (+ (add1 zero)
	(add1
	 (add1 zero))))
;; is a value, but it is NOT normal
;; because the arguments are not in normal form

;; To make it normal, we only have to use normalized expressions.
(claim one Nat)
(claim two Nat)
(define one (add1 zero))
(define two (add1 (add1 zero)))
(+ one two)             ; normal value
