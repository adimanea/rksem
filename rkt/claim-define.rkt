#lang pie

;; doesn't work in Pie
(define one
  (add1 zero))

;; this works
(claim one Nat)         ; declare the type first
(define one
  (add1 zero))

(claim four Nat)
(define four
  (add1
   (add1
	(add1
	 (add1 zero)))))
