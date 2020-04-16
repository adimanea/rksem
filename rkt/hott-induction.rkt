;; The inductor ind_(A x B) for product types from the HoTT book.
;; ind_(A x B) : Pi_(C : A x B -> U) (Pi_(x : A) Pi_(y : B) C(x, y)) -> Pi_(x : A x B) C(x)
;; ind_(A x B)(c, g, (a, b)) := g(a)(b)

;; PROBLEM: Again, how can I choose exactly what the Pi is for?

#lang pie

(claim A U)
(claim indAxB
       (Pi ((x A)) (-> x Nat))) ;; TODO
