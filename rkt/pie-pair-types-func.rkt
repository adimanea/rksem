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
