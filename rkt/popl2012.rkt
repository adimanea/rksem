;; This is the source code for the language used as
;; an example in the POPL 2012 talk by R. Findler
#lang racket
(require redex)

;; the basic language
(define-language lambda-c
  (e (e e ...)
     x
     (lambda (x ...) e)
     call/cc
     +
     number)
  (x variable-not-otherwise-mentioned))

;; the extended language, with contexts
(define-extended-language
  lambda-c/red lambda-c
  (e ... (A e))             ;; FIX: found an ellipsis outise of a sequence
  (v (lambda (x ...) e)
     call/cc
     +
     number)
  (E (v ... E e ...)
     hole))

;; reduction relations
(define red
  (reduction-relation
   lambda-c/red #:domain e
   (--> (in-hole E (A e))
        e
        "abort")
   (--> (in-hole E (call/cc v))
        (in-hole E (v (lambda (x) (A (in-hole E x)))))
        (fresh x)
        "call/cc")
   (--> (in-hole E ((lambda (x ..._1) e) v ..._1))
        (in-hole E (subst e (x v) ...))
        "beta-v")
   (--> (in-hole E (+ number ...))
        (in-hole E (sum number ...))
        ("+"))))

;; meta-functions
(define-metafunction lambda-c/red
  subst : e (x v) ... -> e
  [(subst e (x_1 v_1) (x_2 v_2) ...)
   (subst-1 x_1 v_1 (subst e (x_2 v_2) ...))]
  [(subst e) e])

(define-metafunction lambda-c/red
  sum : number ... -> number
  [(sum number ...)
   ,(foldr + 0 (term (number ...)))])

;; tests
(apply-reduction-relation
 red (term (+ 1 (A (+ 2 3)))))
