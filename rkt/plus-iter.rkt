#lang pie

(claim +                    ; addition of naturals
	   (-> Nat Nat
		   Nat))
(claim step+                ; inductive step for definition
	   (-> Nat Nat))
(define step+               ; inductive step addition (n-1) -> n
  (lambda (+n-1)
	(add1 +n-1)))
(define +
  (lambda (n j)             ; sum of n and j
	(iter-Nat n             ; target
			  j             ; base
			  step+)))      ; step
