#lang pie

(iter-Nat 5
		  3
		  (lambda (k)
			(add1 k)))          ;; => 8
;; target = 5
;; base = 3
;; step = (lambda (k) (add1 k))
;; so basically applies add1 5 times to 3
