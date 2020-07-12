#lang pie
;; First, define the inductive step
(claim step+ (-> Nat Nat))          ; processes one Nat and returns another
(define step+
  (lambda (+n-1)
    (add1 +n-1)))

;; Now the addition
(claim + (-> Nat Nat Nat))          ; addition for the Nat type
(define +
  (lambda (n j)
    (iter-Nat n j step+)))
