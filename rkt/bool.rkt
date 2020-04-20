#lang pie

(claim Bool
       (Either Trivial Trivial))
;; (define Bool
;;   ((left sole) (right sole)))
(claim recB
       (Pi ((C U)) (-> C C (Either Trivial Trivial) C)))
(define recB
  (lambda (C)
    (lambda (c0 c1 (left sole) (right sole))
      c0)))
