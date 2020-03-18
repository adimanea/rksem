;; the following is a motivating example for the
;; use of product types, before introducing them formally.
;; see the notes for details

#lang pie
(claim flip
	   (Pi ((A U)
			(D U))
		   (-> (Pair A D)
			   (Pair D A))))
(define flip
  (lambda (A D)
	(lambda (p)
	  (cons (cdr p) (car p)))))
