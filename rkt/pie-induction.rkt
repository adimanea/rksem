#lang pie

;; (which-Nat  target base step)
;; - if target is zero => return base
;; - else, return (step (- target 1))
(which-Nat zero
           'naught
           (lambda (n) 'more))      ; => (the Atom 'naught)

(which-Nat 4
           'naught
           (lambda (n) 'more))      ; => (the Atom 'more)

(which-Nat 5
           0
           (lambda (n) (add1 7)))   ; => (the Nat 8)
