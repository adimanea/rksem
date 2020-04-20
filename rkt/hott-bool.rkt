#lang pie

(claim Bool U)
(define Bool (Either Trivial Trivial))
(claim true Bool)
(define true (left sole))
(claim false Bool)
(define false (right sole))

(claim if
       (Pi ((A U))
           (-> Bool A A A)))
(define if
  (lambda (A tgt t f)
    (ind-Either tgt
                (lambda (_) A)
                (lambda (_) t)
                (lambda (_) f))))

;; test
(if Nat true zero 1)            ; => (the Nat 0)
(if Nat false zero 1)           ; => (the Nat 1)

;; unfolded test
(if Nat (left sole) zero 1)     ; => (the Nat 0)
(if Nat (right sole) zero 1)    ; => (the Nat 1)
