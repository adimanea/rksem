#lang pie

(require plus-iter)         ; we need the definition of +

(claim mult                    ; multiplication of naturals
	   (-> Nat Nat
		   Nat))
(claim step-mult               ; inductive step
	   (-> Nat Nat Nat
		   Nat))

(define step-mult
  (lambda (j n-1 mult-n-1)
	(+ j mult-n-1)))

(define mult
  (lambda (n j)
	(rec-Nat n
			 0
			 (step-mult j))))
