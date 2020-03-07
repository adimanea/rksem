;; Amb: A Redex Tutorial
;; https://docs.racket-lang.org/redex/tutorial.html

#lang racket
(require redex)

(define-language L
  ;; productions
  (e (e e)                      ; application
     (lambda (x t) e)           ; lambda-abstraction
     x                          ; variables
     (amb e ...)                ; amb expressions
     number                     ; numbers
     (+ e ...)                  ; sums
     (if0 e e e)                ; tests of if0
     (fix e))                   ; fix points
  (t (-> t t)                   ; functions of type t -> t -> t (i.e. (t, t) -> t)
     num)                       ; where t = num
  (x variable-not-otherwise-mentioned))

;; test
(redex-match                        ; check for matches
 L                                  ; in language L
 e                                  ; expressions of kind e
 (term (lambda (x) x)))             ; is this one of them?
;; => #f                            ; no, it's not (e only appears in application (e e))

(redex-match
 L                                  ; in language L
 e                                  ; is the following of kind e?
 (term ((lambda (x num) (amb x 1))
        (+ 1 2))))
;; yes, it is. we have an example provided by the REPL
;; (list (match (list (bind 'e '((lambda (x num) (amb x 1)) (+ 1 2))))))

;; we can split function application and match separately
;; the function and the argument
(redex-match
 L
 (e_1 e_2)
 (term ((lambda (x num) (amb x 1))
        (+ 1 2))))
;; (list (match (list
;;   (bind 'e_1 '(lambda (x num) (amb x 1)))
;;   (bind 'e_2 '(+ 1 2)))))
 
;; test for multiple matches
(redex-match
 L
 (e_1 ... e_2 e_3 ...)
 (term ((+ 1 2)
        (+ 3 4)
        (+ 5 6))))
;; all matches:
;; (list (match (list
;; (bind 'e_1 '())
;; (bind 'e_2 '(+ 1 2))
;; (bind 'e_3 '((+ 3 4) (+ 5 6)))))
;; (match (list
;; (bind 'e_1 '((+ 1 2)))
;; (bind 'e_2 '(+ 3 4))
;; (bind 'e_3 '((+ 5 6)))))
;; (match (list
;; (bind 'e_1 '((+ 1 2) (+ 3 4)))
;; (bind 'e_2 '(+ 5 6))
;; (bind 'e_3 '()))))

;; Exercise 1:
;; Use redex-match to extract the body of the λ expression from this object-language program: 
;; ((λ (x num) (+ x 1))  17)
(redex-match
 L
 (lambda (x t) e)
 (term (lambda (x num) (+ x 1))))
;; => (list (match (list (bind 'e '(+ x 1)) (bind 't 'num) (bind 'x 'x))))

;; Exercise 2:
;; Use redex-match to extract the range portion of the type (→ num (→ num num)).
(redex-match
 L
 (-> t (-> t t))
 (term (-> num (-> num num))))
;; => (list (match (list (bind 't 'num))))

(redex-match
 L
 (amb '(x y))
 (term (1 2 3 4)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1.2 Typing

;; Extend the language with typing contexts (environments) via a non-terminal
;; Gamma and the empty environment being "dot".

(define-extended-language L+Gamma       ; the name of the extension
  L                                     ; what we're extending
  [Gamma dot (x : t Gamma)])            ; with what we're extending

;; Typing rules
(define-judgment-form
  L+Gamma
  #:mode (types I I O)                          ; How to evaluate (the syntax): Input Input Output
  #:contract (types Gamma e t)                  ; Specification: types Context Expression Type

  ;; Function application
  [(types Gamma e_1 (-> t_2 t_3))               ; Gamma |- e_1 : (t_2 -> t_3)
   (types Gamma e_2 t_2)                        ; Gamma |- e_2 : t_2
   -----------------------------                ; ---------------------------
   (types Gamma (e_1 e_2) t_3)]                 ; Gamma |- (e_1 e_2) : t_3

  ;; Function abstraction, with extra variable
  [(types (x : t_1 Gamma) e t_2)                        ; x : t_1, Gamma |- e : t_2
   -----------------------------                        ; -------------------------
   (types Gamma (lambda (x t_1) e) (-> t_1 t_2))]       ; Gamma |- (lambda (x : t_1) e) : (t_1 -> t_2)

  ;; Typing of fixed points
  [(types Gamma e (-> (-> t_1 t_2) (-> t_1 t_2)))
   -----------------------------------------------
   (types Gamma (fix e) (-> t_1 t_2))]

  ;; Typing of free variables                   ; x : t, Gamma |- x : t
  [----------------------------
   (types (x : t Gamma) x t)]

  ;; Enlarging contexts                         
  [(types Gamma x_1 t_1)                        ; Gamma |- x_1 : t_1
   (side-condition (different x_1 x_2))         ; let x_1 != x_2
   -------------------------------------        ; -------------------
   (types (x_2 : t_2 Gamma) x_1 t_1)]           ; x_2 : t_2, Gamma |- x_1 : t_1

  ;; Typing of sums of nums
  [(types Gamma e num) ...
  --------------------------
  (types Gamma (+ e ...) num)]

  ;; Numbers are nums
  [-------------------------
   (types Gamma number num)]

  ;; Typing of conditionals
  [(types Gamma e_1 num)
   (types Gamma e_2 t)
   (types Gamma e_3 t)
   -----------------------
   (types Gamma (if0 e_1 e_2 e_3) t)]

  ;; Typing of amb expressions (that are sure to work on the first argument!)
  [(types Gamma e num) ...
  --------------------------------
  (types Gamma (amb e ...) num)])

;; `different' is a metafunction
(define-metafunction L+Gamma
  [(different x_1 x_1) #f]
  [(different x_1 x_2) #t])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1.3 Test typing
;; Compute all the types for the expression
;; ((lambda (x num) (amb x 1)) (+ 1 2))
(judgment-holds
 (types dot
        ((lambda (x num) (amb x 1))
         (+ 1 2))
        t)                              ; match any output (O)
 t)                                     ; => '(num)

;; Extract only a specific part of the typing
(judgment-holds
 (types dot
        (lambda (f (-> num (-> num num)))
          (f (amb 1 2)))
        (-> t_1 t_2))
 t_2)                                   ; return what t_2 can be
;; => '((-> num num)) which is the same as (list (term (-> num num)))

;; Failed test example
;; (test-equal
;;  (judgment-holds
;;   (types dot (+ 1 2) t)
;;   t)
;;  (list (term (-> num num))))
;; FAILED amb-tutorial.rkt:180.0
;; actual: '(num)
;; expected: '((-> num num))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1.4 Reduction Relations

;; Extend the language to prepare for reductions
(define-extended-language Ev L+Gamma
  (p (e ...))               ; introduce a non-terminal p for a list of expressions
  (P (e ... E e ... ))       ; P is the context for ps, which contains expressions in context (E e)
  (E (v E)                  ; the possible contexts for expressions
     (E e)
     (+ v ... E e ...)
     (if0 E e e)
     (fix E)
     hole)
  (v (lambda (x t) e)       ; the possible expressions without contexts (values v)
     (fix v)
     number))

;; define a meta-function that will be used in reductions
(define-metafunction Ev
  Sigma : number ... -> number
  [(Sigma number ...)
   ,(apply + (term (number ...)))])     ; lift the default (+) function to Redex

;; The standard substitutions are found when evaluating in the REPL
;; (collection-file-path "tut-subst.rkt" "redex")
;; Include that
(require redex/tut-subst)

;; lift Racket subst to Redex subst
(define-metafunction Ev
  subst : x v e -> e
  [(subst x v e)
   ,(subst/proc x? (list (term x)) (list (term v)) (term e))])
;; use Redex term to extract x, v, e and pass them to subst/proc
;; see tut-subst for subst/proc

(define x? (redex-match Ev x))

;; now the reduction relations
;; defined with pattern matching holes
(define red
  (reduction-relation
   Ev
   #:domain p
   (--> (in-hole P (if0 0 e_1 e_2))
        (in-hole P e_1)
        "if0t")                             ;; if if0 returns true

   (--> (in-hole P (if0 v e_1 e_2))
        (in-hole P e_2)
        (side-condition (not (equal? 0 (term v))))
        "if0f")                             ;; if if0 returns false

   (--> (in-hole P ((fix (lambda (x t) e)) v))
        (in-hole P (((lambda (x t) e) (fix (lambda (x t) e))) v))
        "fix")                              ;; fixed points

   (--> (in-hole P ((lambda (x t) e) v))
        (in-hole P (subst x v e))
        "beta-v")                           ;; beta-reduction

   (--> (in-hole P (+ number ...))
        (in-hole P (Sigma number ...))
        "+")                                ;; addition is Sigma

   (--> (e_1 ... (in-hole E (amb e_2 ...)) e_3 ...)  
        (e_1 ... (in-hole E e_2) ... e_3 ...)  
        "amb")))                            ;; ambiguous evaluation



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1.5 Testing reduction relations
;; using test-->>, the transitive closure of the reduction relation

;; Reduces the first term and makes sure we get the second
(test-->>
 red
 (term ((if0 1 2 3)))
 (term (3)))


;; Reduce with one step only
(test-->
 red
 (term ((+ (amb 1 2) 3)))
 (term ((+ 1 3) (+ 2 3))))
(test-results)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1.7 Typesetting reduction relations
;; in the REPL: (render-reduction-relation red)

;; Or save it to a .ps file
(require pict)
(scale (vl-append
        20
        (language->pict Ev)
        (reduction-relation->pict red))
       3/2)

(traces red
        (term ((+ (amb 1 2)
                  (amb 10 20)))))
