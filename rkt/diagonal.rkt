;; we define a general purpose diagonal function,
;; i.e. one which makes a pair of the same argument.
;; it will be defined using product types, hence
;; it will work for arguments of any type.

#lang pie

(claim twin                     ; twin is
	   (Pi ((Y U))              ; parametrized by any type Y : U
		   (-> Y                ; and produces Y -> (Pair Y Y)
			   (Pair Y Y))))
(define twin
  (lambda (Y)                   ; abstract the type
	(lambda (x)                 ; abstract the argument
	  (cons x x))))             ; use the Pair type constructor (`cons')

;; it can now be used in particular examples,
;; namely for particular types:
(claim twin-Atom
	   (-> Atom
		   (Pair Atom Atom)))
(define twin-Atom
  (twin Atom))
