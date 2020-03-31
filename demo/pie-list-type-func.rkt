#lang pie

;; "inductive step" first
(claim step-length
	   (Pi ((E U))
		   (-> E (List E) Nat Nat)))
(define step-length
  (lambda (E)                               ; abstract the type first
	(lambda (e es length-es)                ; then the rest
	  (add1 length-es))))                   ; just increase by 1 at each step (see also Gauss)

(claim length                               ; length of a List
	   (Pi ((E U))                          ; of elements of type E
		   (-> (List E) Nat)))              ; goes from List to Nat
(define length
  (lambda (E)                               ; abstract the type parameter
	(lambda (es)                            ; then the actual list
	  (rec-List es
				0
                (step-length E)))))           ; call the inductive step with this type

;; special version for E = Atom
(claim length-Atom
	   (-> (List Atom) Nat))
(define length-Atom
  (length Atom))

;; Test
(length Nat (:: 1 (:: 2 (:: 3 nil))))       ; => (the Nat 3)
(length-Atom (:: 'cat nil))                 ; => (the Nat 1)
(length-Atom (:: 'cat (:: 'dog nil)))       ; => (the Nat 2)
