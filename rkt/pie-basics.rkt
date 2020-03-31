#lang pie

(the (Pair Atom Atom)
     (cons 'spinach 'cauliflower))
;; declares that the cons expression has the specified type

(claim one Nat)             ; one will be of type Nat
(define one (add1 zero))    ; zero is primitive
(the Nat (add1 one))        ; declares that 2 : Nat

(claim two Nat)
(define two
  (add1
   (add1 zero)))
;; in REPL:
;; > two
;; (the Nat two)

(claim myDogs (Pair Atom Atom))
(define myDogs (cons 'Ricky 'Rocky))
;; in REPL
;; > myDogs
;; (the (Pair Atom Atom) (cons 'Ricky 'Rocky))
