;; The recursor rec_(A x B) from the HoTT book.
;; rec_(A x B) : (Pi_(C : U) (A -> B -> C)) -> (A x B) -> C
;; rec_(A x B) (C, g, (a, b)) := g(a)(b)

;; PROBLEM: The Pi should be only for C! Is this possible?

#lang pie

(claim recAxB
       (Pi ((A U) (B U) (C U))
           (-> (-> A B C) (Pair A B) C)))

(define recAxB
  (lambda (A B C)
    (lambda (g p)
      ((g (car p)) (cdr p)))))

;; example
((recAxB Nat Nat Nat) (lambda (x y) (add1 y)) (cons 2 3))       ;; => (the Nat 4)

;; first projection
((recAxB Nat Nat Nat) (lambda (x y) x) (cons 2 3))              ;; => (the Nat 4)

;; defined generally, for Nat type
(claim p1 (-> (Pair Nat Nat) Nat))
(define p1
  ((recAxB Nat Nat Nat)
   (lambda (x y) x)))

;; test
(p1 (cons 2 3))                                                 ;; => (the Nat 2)


;; for unit type (Atom hack)
(claim recA
       (Pi ((C U)) (-> C Atom C)))
(define recA
  (lambda (C)
    (lambda (c atom)
      c)))

;; test
((recA Nat) zero 'something)                                    ;; => (the Nat 0)

;; for unit type
(claim recU
       (Pi ((C U)) (-> C Trivial C)))
(define recU
  (lambda (C)
    (lambda (c d)       ;; d can only be sole
      c)))

;; test
((recU Trivial) sole sole)                                      ;; => (the Trivial sole)
