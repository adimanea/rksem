;; Defininig the length of a list,
;; using rec-List and dependent types.

#lang pie

;; the length of a list
(claim length
	   (Pi ((E U))
		   (-> (List E)
			   Nat)))
(define length
  (lambda (E)
	(lambda (es)
	  (rec-List es
				0
				step-length E))))   ; we need the inductive step

;; inductive step for increasing length
(claim step-length
	   (Pi ((E U))
		   (-> E (List E) Nat
			   Nat)))
(define step-length
  (lambda (E)
	(lambda (e es length-es)
	  (add1 length-es))))

;; special version for Atoms
(claim length-Atom
	   (-> (List Atom)
		   Nat))
(define length-Atom
  (length Atom))
