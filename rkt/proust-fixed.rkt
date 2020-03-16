;; P. Ragde --  Proust, a Nano Proof Assistant (2016)

#lang racket

(struct Lam (var body) #:transparent)                 ; lambda expression
(struct App (func arg) #:transparent)                 ; application
(struct Arrow (domain codomain) #:transparent)        ; function
(struct TA (type var) #:transparent)                  ; type annotation

;; expr = (lambda x => expr)
;;      | (expr expr)
;;      | (expr : type)
;;      | x

;; parse-expr : sexp -> Expr
(define (parse-expr s)
  (match s
    [`(lambda ,(? symbol? x) => ,e)         ; is it a lambda-expression?
     (Lam x (parse-expr e))]                ; then make it Lam
    [`(,func ,arg)                          ; is it an application?
     (App (parse-expr func)                 ; then make it App
          (parse-expr arg))]
    [`(,e : ,t) (TA (parse-expr e) (parse-type t))]
    [(? symbol? x) x]))                     ; otherwise, it's a symbol => return it

;; my tests
(parse-expr '(lambda x => x))                           ; => #<Lam>  OK
(parse-expr '(lambda x => (lambda y => (x y))))         ; => #<Lam>  OK
(parse-expr '(+ x))                                     ; => #<App>  OK
(parse-expr 'x)                                         ; => 'X      OK

;; type = (type -> type) | X

;; ;; parse-type : sexp -> Type
(define (parse-type t)
  (match t
    [`(,t1 -> ,t2)
     (Arrow (parse-type t1)
            (parse-type t2))]
    [(? symbol? X) X]
    [else (error "unrecognized type")]))

;; my tests
(parse-type '(A -> B))                      ; => #<Arrow>  OK
(parse-type 'X)                             ; => 'X        OK

;; type-check : Context Expr Type -> boolean
;; produces #t if expr has type t in context ctx (else error)
(define (type-check ctx expr type)
  ;; Added a printf to see things...
  (printf "checking ctx: ~a expr: ~a type: ~a~n" ctx expr type)
  (match expr
    [(Lam x t)
     (match type
       [(Arrow tt tw) (type-check (cons `(,x ,tt) ctx) t tw)]
       [else (cannot-check ctx expr type)])]
    [else
     ;; Added a printf... probably could have used the
     ;; debugger instead... 
     (printf "ctx: ~a expr: ~a type: ~a~n" ctx expr type)
     (if (equal? (type-infer ctx expr) type) true
              (cannot-check ctx expr type))]))

(define (cannot-check ctx expr type)
  (error "cannot check the type of the expression in the provided context"))

;; type-infer : Context Expr -> Type
;; produces type of expr in context ctx (error if it can't)
(define (type-infer ctx expr)
  (match expr
    [(Lam _ _) (cannot-infer ctx expr)]
    [(TA e t) (type-check ctx e t) t]
    [(App f a)
     (define tf (type-infer ctx f))
     (match tf
       [(Arrow tt tw) #:when (type-check ctx a tt) tw]
       [else (cannot-infer ctx expr)])]
    [(? symbol? x)
     (cond
       [(assoc x ctx) => second]
       [else (cannot-infer ctx expr)])]))
     
(define (cannot-infer ctx expr)
  (error "cannot infer the type of the expression in the provided context"))

;; my test
(type-check empty
            (parse-expr '(lambda x => x))
            (parse-type '(A -> A)))                 ; => #t  OK

;; ONLY WORKS FOR LAMBDAS

;; not working
(define (check-proof p)
  (type-infer empty (parse-expr p)) true)

;; test:
(check-proof
 `((lambda x => (lambda y => (y x))) : (A -> ((A -> B) -> B))))    ; => #t OK

;; Added this proof to see what is going on. This works.
;; That is because it is a lambda, which the type check/infer
;; tooling knows how to handle.
(check-proof
 `((lambda x => x) : (A -> A)))

;; This fails, because the type checker has no idea
;; how to handle a single type annotation outside of the context
;; of a lambda. The type-inferencer has patterns for a TA, but
;; the checker does not. That this fails "makes sense" in the context
;; of the code in the article... whether or not that is what you want
;; to happen is another thing entirely...
;; (parse-expr '(x : A))
;; (check-proof `((x : A) : A))
;; (check-proof `(x : A))
;; (check-proof `((+ x) : (A -> A)))

(define current-expr #f)              ; the current expression
(define goal-table (make-hash))       ; keep goals in a hash table
(define hole-ctr 0)                   ; holes (proof to be filled in)
(define (use-hole-ctr)
  (begin0                             ; evaluate in order
      hole-ctr                        ; print hole-ctr (in REPL)
    (set! hole-ctr (add1 hole-ctr)))) ; increase it
(define (print-task)
  (printf "~a\n"
          (pretty-print current-expr)))

(define (set-task! s)                 ; check (term:type) tasks
  (set! goal-table (make-hash))
  (set! hole-ctr 0)
  (define e (parse-expr s))
  (match e
    [(TA _ _) (set! current-expr e) (type-infer empty e)]
    [else (error "task must be of form (term : type)")])
  (printf "Task is now\n")
  (print-task))

(define (refine n s)
  (match-define (list t ctx)
    (hash-ref goal-table n
              (lambda () (error 'refine "no goal numbered ~a" n))))
  (define e (parse-expr s))
  (type-check ctx e t)
  (hash-remove! goal-table n)
  (set! current-expr (replace-goal-with n e current-expr))
  (printf "Task is now\n" (format "~a goal~a" ngoals (if (= ngoals 1) "" "s")))
  (print-task))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODOs:
(define (replace-goal-with n e expr))
;; "does a straightforward structural recursion on the AST
;; (the goal being at a single leaf)"
(define ngoals) ;; count the number of goals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require syntax-parse-example/def/def)
;; The def macro is similar to define but:
;;     requires a docstring
;;     requires test cases;
;;     optionally accepts contract annotations on its arguments; and
;;     optionally accepts pre- and post- conditions.
;; define some terms in the language
(def 'bool '((forall (x : Type) -> (x -> (x -> x))) : Type))
(def 'true '((lambda x => (lambda y => (lambda z => y))) : bool))
(def 'false '((lambda x => (lambda y => (lambda z => z))) : bool))
(def 'band '(((lambda x => (lambda y => (((x bool) y) false))))
             : (bool -> (bool -> bool))))

(def 'and
  '((lambda p => (lambda q => (forall (c : type) -> ((p -> (q -> c)) -> c))))
    : (Type -> (Type -> Type))))
(def 'conj
  '((lambda p => (lambda q => (lambda x => (lambda y => (lambda c => (lambda f => ((f x) y)))))))
    : (forall (p : Type) -> (forall (q : Type) -> (p -> (q -> ((and p) q)))))))
(def 'proj1
  '((lambda p => (lambda q => (lambda a => ((a p) (lambda x => (lambda y => x))))))
    : (forall (p : Type) -> (forall (q : Type) -> (((and p) q) -> p)))))
(def 'proj2
  '((lambda p => (lambda q => (lambda a => ((a q) (lambda x => (lambda y => y))))))
    : (forall (p : Type) -> (forall (q : Type) -> (((and p) q) -> q)))))
(def 'and-commutes
  '((lambda p => (lambda q => (lambda a => ((((conj q) p) (((proj2 p) q) a))
                                            (((proj1 p) q) a)))))
    : (forall (p : Type) -> (forall (q : Type) -> (((and p) q) -> ((and q) p))))))

;; arithmetic
(def 'nat
  '((forall (x : Type) -> (x -> ((x -> x) -> x))) : Type))
(def 'z '((lambda x => (lambda zf => (lambda sf => zf))) : nat))
(def 's
  '((lambda n => (lambda x => (lambda zf => (lambda sf => (sf (((n x) zf) sf)))))) : (nat -> nat)))
(def 'one '((s z) : nat))
(def 'two '((s (sz)) : nat))
(def 'plus
  '((lambda x => (lambda y => (((x nat) y) s))) : (nat -> (nat -> nat))))

;; some basic proofs
(def 'one-eq-one '((eq-refl one) : (one = one)))
(def 'one-plus-one-is-two
  '((eq-refl two) : (((plus one) one) = two)))
(def 'eq-symm
  '((lambda x => (lambda y => (lambda p => (eq-elim x (lambda w => (w = x))
                                                    (eq-refl x) y p))))
    : (forall (x : Type) -> (forall (y : Type) -> ((x = y) -> (y = x))))))
(def 'eq-trans
  '((lambda x => (lambda y => (lambda z => (lambda p => (lambda q => (eq-elim (lambda w => (x = w)) p z q))))))
    : (forall (x : Type) -> (forall (y : Type) -> (forall (z : Type) ->
                                                          ((x = y) -> (y = z) -> (x = z)))))))

(def 'nat-rec
  '((lambda C => (lambda zc => (lambda sc => (lambda n => (nat-ind (lambda _ => C) zc (lambda _ => sc) n)))))
    : (forall (C : Type) -> (C -> (C -> C) -> Nat -> C))))

(def 'plus
  '((lambda n => (nat-rec (Nat -> Nat) (lambda m => m) (lambda pm => (lambda x => (S (pm x)))) n))
    : (Nat -> Nat -> Nat)))

(def 'plus-zero-left
  '((lambda n => (eq-refl n)) : (forall (n : Nat) -> ((plus Z n) = n))))

(def 'plus-zero-right
  '((lambda n => (nat-ind (lambda m => ((plus m Z) = m)) (eq-refl Z)
                          (lambda k => (lambda p =>
                                               (eq-elim (plus k Z) (lambda w => ((S (plus k Z)) = (S w)))
                                                        (eq-refl (S (plus k Z))) k p)))
                          n))
    : (forall (n : Nat) -> ((plus n Z) = n))))
                                                                
