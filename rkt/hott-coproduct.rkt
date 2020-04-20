#lang pie

(claim recA+B
       (Pi ((A U) (B U) (C U))
           (-> (-> A C) (-> B C) (Either A B) C)))

(define recA+B
  (lambda (A B C)
    (lambda (g0 g1 tgt)
      (ind-Either tgt
                  (lambda (_) C)
                  (lambda (x) (g0 x))
                  (lambda (y) (g1 y))))))
