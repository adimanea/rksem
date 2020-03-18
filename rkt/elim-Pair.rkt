#lang pie

;; elim-Pair will operate on PRODUCT TYPES (see theory in the notes)
(claim elim-Pair
	   (Pi ((A U)
			(D U)
			(X U))
		   (-> (Pair A D)
			   (-> A D
				   X)
			   X)))
(define elim-Pair
  (lambda (A D X)
	(lambda (p f)
	  (f (car p) (cdr p)))))

(claim kar                  ; first eliminator for (Pair Nat Nat)
	   (-> (Pair Nat Nat)   ; (it will resemble car)
		   Nat))
(define kar
  (lambda (p)
	(elim-Pair
	 Nat Nat                ; the types of car and cdr which we will elim
	 Nat                    ; the output of the lambda below
	 p                      ; the actual argument
	 (lambda (a d)          ; will be used like this
	   a))))

(claim kdr                  ; second eliminator for (Pair Nat Nat)
	   (-> (Pair Nat Nat    ; (it will resemble cdr)
				 Nat)))
(define kdr
  (lambda (p)
	(elim-Pair
	 Nat Nat
	 Nat
	 p
	 (lambda (a d)
	   d))))

;; swapping elements in a (Pair Nat Atom)
(claim swap
	   (-> (Pair Nat Atom)
		   (Pair Atom Nat)))
(define swap
  (lambda (p)
	(elim-Pair
	 Nat Atom
	 (Pair Atom Nat)
	 p
	 (lambda (a d)
	   (cons d a)))))
