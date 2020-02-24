;; sewpr-bool-variation.rkt
;; The variation example at Section 11.5, page 213.
#lang scheme
(require redex)

(define-language bool-standard-lang
  [B true
     false
     (lor B B)]
  [E (lor E B)
     hole])
;; basic modification: it allows holes only on the
;; leftmost-outermost position, for efficiency
;; (to be filled first)

(define bool-standard-red
  (reduction-relation
   bool-standard-lang
   (--> (in-hole E (lor true B))
        (in-hole E true)
        lor-true)
   (--> (in-hole E (lor false B))
        (in-hole E B)
        lor-false)))

;; Illustrate the differences using traces
(traces bool-standard-red
        (term (lor (lor true false) (lor true true))))
