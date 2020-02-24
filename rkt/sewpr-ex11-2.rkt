;; EXERCISE 11.2, PAGE 210
;; Formulate a grammar of simple addition expressions `A'.
;; The syntax should contain 0, 1 and 2 plus the addition of
;; arbitrary expressions.
;; Equip the language with contexts, i.e. addition expressions
;; with a hole.

#lang scheme
(require redex)

(define-language addA
  [E 0 1 2
     (+ E E)]
  [C (+ C E)
     (+ E C)
     hole])

(define E0 (term 0))
(define E1 (term 1))
(define E2 (term 2))
(define E4 (term (+ ,E0 ,E1)))
(define E5 (term (+ ,E0 ,E2)))
(define E6 (term (+ ,E1 ,E2)))

(define C1 (term hole))
(define C2 (term (+ (+ 0 1) hole)))
(define C3 (term (+ (+ 0 2) hole)))
(define C4 (term (+ (+ 1 2) hole)))
(define C5 (term (+ hole 0)))
(define C6 (term (+ hole 1)))
(define C7 (term (+ hole 2)))

(redex-match addA
             E
             (term (+ 1 2)))
;; => (list (match (list (bind 'E '(+ 1 2)))))

;; EXERCISE 11.3, PAGE 211
;; Formulate a reduction system for modulo 3 arithmetic
;; on the syntax above. Start with the following rules;
;; add others as needed:
;; 1. (+ 0 A) should reduce to A;
;; 2. (+ A 0) should reduce to A too.
(define addA-red
  (reduction-relation
   addA
   (--> (in-hole C (+ 0 E))
        (in-hole C E)
        add-zero-left)
   (--> (in-hole C (+ 0 E))
        (in-hole C E)
        add-zero-right)
   (--> (in-hole C (+ 1 1))
        (in-hole C 2)
        add-one-one)
   (--> (in-hole C (+ 1 2))
        (in-hole C 0)
        add-one-two)
   (--> (in-hole C (+ 1 E))
        (in-hole C (+ E 1))
        comm-one)
   (--> (in-hole C (+ 2 E))
        (in-hole C (+ E 2))
        comm-two)))

(redex-match addA
             (in-hole C (+ 1 E))
             (term (+ (+ 1 (+ 0 1)) 1)))
;; => (list (match (list (bind C (+ hole 1)) (list (bind 'E '(+ 0 1))))))
;; it asks whether the term is of the type above
;; using (perhaps) the reduction relations


;; Experiment with traces
(traces addA-red
        (term (+ (+ 1 2) (+ 0 2))))
;; view as PostScript (C-c C-c in emacs to toggle between viewing and editing)
