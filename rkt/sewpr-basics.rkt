;; sewpr-basics.rkt
;; First example from SEwPR book, just basic tests to
;; get used to the tools
#lang scheme
(require redex)

;; Define a toy-language, `bool-any-lang'
(define-language bool-any-lang
  [B true                   ; grammar productions
     false                  ; B = boolean
     (lor B B)]             ; lor = logical OR
  [C (lor C B)              ; C = context
     (lor B C)              ; contexts can contain only disjunctions
     hole])

(define B1 (term true))
(define B2 (term false))
(define B3 (term (lor true false)))
(define B4 (term (lor ,B1 ,B2)))        ; uses unquote, so basically B4 = B3
(define B5 (term (lor false ,B4)))      ; B5 = (lor false (lor true false))

(define C1 (term hole))                 ; Rule C1: "hole" will be filled to make a term
(define C2 (term (lor (lor false false) hole)))
(define C3 (term (lor hole true)))

;; test1
(redex-match bool-any-lang
             B
             (term (lor false true)))
;; --> (list (match (list (bind 'B '(lor false true)))))
;; The matching succeeds and this is an example that works:
;; B = (lor false true)

;; test2
(redex-match bool-any-lang
             (in-hole C (lor true B))
             (term (lor true (lor true false))))
;; --> (list
;;          (match (list (bind 'B 'false) (bind 'C '(lor true hole))))
;;          (match (list (bind 'B '(lor true false)) (bind 'C hole))))
;; Also works, with 2 examples:
;; (1) B = false, C = (lor true hole)
;; (2) B = (lor true false), C = hole

;; Specifying reduction relations
(define bool-any-red
  (reduction-relation
   bool-any-lang
   (--> (in-hole C (lor true B))    ; In a context where we have lor between true and Bs,
        (in-hole C true)            ; it will just become true in that context
        lor-true)                   ; name of the reduction
   (--> (in-hole C (lor false B))   ; In a context where we have lor between false and Bs,
        (in-hole C B)               ; it will return the Bs in that context
        (lor-false))))              ; name of the reduction

;; Test
(redex-match bool-any-lang
             (in-hole C (lor true B))
             (term (lor (lor true (lor false true)) false)))

;; --> (list (match (list (bind 'B '(lor false true)) (bind 'C '(lor hole false)))))
