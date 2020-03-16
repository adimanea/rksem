;; Use the Pie module
;; (after installing with `raco pkg install pie'
#lang pie

;; a simple example, the swap function
(define swap
  (lambda (p)
	(elim-Pair
	 Nat Atom
	 (Pair Atom Nat)
	 p
	 (lambda (a d)
	   (cons d a)))))
