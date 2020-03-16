#lang pie

(claim Pear-maker U)            ;; universe
(define Pear-maker              ;; two Nats make a Pear
  (-> Nat Nat Pear))

(claim elim-Pear
	   (-> Pear Pear-maker Pear))
(define elim-Pear               ;; eliminator consumes the maker
  (lambda (pear maker)
	(maker (car pear) (cdr pear))))

(claim pearwise+                ;; Addition for Pear types
	   (-> Pear Pear Pear))
(define pearwise+
  (lambda (x y)
	(elim-Pear x                ;; split the two parts into
			   (lambda (a1 d1)  ;; their parts (remember, Pair = (Nat, Nat))
				 (elim-Pear y
							(lambda (a2 d2)
							  (cons
							   (+ a1 a2)        ;; then add the parts
							   (+ d1 d2))))))))
