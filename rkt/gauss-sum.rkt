#lang pie

(require plus-iter)             ; uses the definition of plus

(claim step-gauss               ; inductive step
	   (-> Nat Nat
		   Nat))
(define step-gauss
  (lambda (n-1 gauss-n-1)
	(+ (add1 (n-1) gauss-n-1))))

(claim gauss                    ; Gauss formula for sum of n integers
	   (-> Nat Nat))
(define gauss
  (lambda (n)
	(rec-Nat n
			 0
			 step-gauss)))
