#lang pie

;; shortcuts
(claim Bool U)
(define Bool (Either Trivial Trivial))
(claim true Bool)
(define true (left sole))
(claim false Bool)
(define false (right sole))

;; Bool recursor = if (branching)
(claim if
	   (Pi ((A U))
		   (-> Bool A A A)))
(define if
  (lambda (A tgt t f)
	(ind-Either tgt
				(lambda (_) A)                  ; motive
				(lambda (_) t)                  ; the true case
				(lambda (_) f))))               ; the false case

;; REMARK: t != true and f != false
;; t is the instruction when tgt == true
;; f is the instruction when tgt == false

;; test
(if Nat true zero 1)            ; => (the Nat 0)
(if Nat false zero 1)           ; => (the Nat 1)

;; unfolded test
(if Nat (left sole) zero 1)     ; => (the Nat 0)
(if Nat (right sole) zero 1)    ; => (the Nat 1)
