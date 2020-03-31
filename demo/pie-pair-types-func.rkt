#lang pie

(claim Pear U)                  ; claim the custom type
(define Pear (Pair Nat Nat))    ; a Pear is a Pair of two Nats

(claim Pear-maker U)            ; claim of the type constructor
(define Pear-maker              ; actual definition
  (-> Nat Nat Pear))            ; Pear-maker : (Nat, Nat) -> Pear

(claim elim-Pear
		   (-> Pear Pear-maker Pear))             ; claim the type eliminator
(define elim-Pear               ; the definition of the eliminator
  (lambda (pear maker)          ; is a lambda taking a pear and a maker function
	(maker (car pear)           ; which sends the maker on the first part of the pear
		   (cdr pear))))        ; then on the second part


(require "addition.rkt")        ; we need Nat addition (DIY)

(claim pearwise+                ; claim the addition for this custom type
	   (-> Pear Pear Pear))     ; with type (Pear, Pear) -> Pear
(define pearwise+               ; (a, b) + (c ,d) = (a + c, b + d)
  (lambda (x y)
	(elim-Pear x
			   (lambda (a1 d1)
				 (elim-Pear y
							(lambda a2 d2)
							(cons
							 (+ a1 a2)
							 (+ d1 d2)))))))

(elim-Pear (cons 3 17)
		   (lambda (a d) (cons d a)))
;; => (the (Pair Nat Nat) (cons 17 3))

(pearwise+ (cons 1 2) (cons 5 7))
;; => (the (Pair Nat Nat) (cons 6 9))

#lang pie

(claim elim-Pair                    ; "consumer" (eliminator) for Pairs
	   (Pi ((A U) (D U) (X U))
		   (-> (Pair A D)
			   (-> A D X) X)))
(define elim-Pair
  (lambda (A D X)                   ; abstract the type variables first
	(lambda (p f)                   ; then the rest (f = eliminator, p = pair)
	  (f (car p) (cdr p)))))

(claim kar                          ; DIY car = first
	   (-> (Pair Nat Nat) Nat))
(define kar
  (lambda (p)
	(elim-Pair Nat Nat Nat p        ; make the types concrete
			   (lambda (a d) a))))  ; take first component

(claim kdr                          ; DIY cdr = second
	   (-> (Pair Nat Nat) Nat))
(define kdr
  (lambda (p)
	(elim-Pair Nat Nat Nat p        ; make the types concrete
			   (lambda (a d) d))))  ; take second component

;; flipping two elements of a Pair
(claim flip
	   (Pi ((A U) (D U))
		   (-> (Pair A D) (Pair D A))))
(define flip
  (lambda (A D)                     ; abstract the type variables first
	(lambda (p)                     ; then the pair
	  (cons (cdr p) (car p)))))

;; Examples
(kdr (cons 5 3))                    ; => (the Nat 3)
(kar (cons 8 4))                    ; => (the Nat 8)
((flip Nat Atom) (cons 17 'apple))  ; => (the (Pair Atom Nat) (cons 'apple 17))
