#lang pie

(claim recA+B
	   (Pi ((A U) (B U) (C U))
		   (-> (-> A C) (-> B C) (Either A B) C)))

(define recA+B
  (lambda (A B C)
	(lambda (g0 g1 tgt)
	  (ind-Either tgt
				  (lambda (_) C)                ; motive
				  (lambda (x) (g0 x))           ; the left case
				  (lambda (y) (g1 y))))))       ; the right case


;; test
((recA+B Nat Nat Nat)
 (lambda (x) (add1 x))
 (lambda (y) zero)
 (left 3))                                      ; => (the Nat 4)

((recA+B Nat Nat Nat)
 (lambda (x) (add1 x))
 (lambda (y) zero)
 (right 3))                                     ; => (the Nat 0)
