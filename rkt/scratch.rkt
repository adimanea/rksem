;; Scratch file: for various experiments.
#lang scheme
(require racket/list)       ; for first (otherwise, use car)
(require redex)             ; for term

;; exercise 11.1, page 207
(term (+ ,(first (term (,(+ 12 34)))) 5))       ; => '(+ 46 5)
