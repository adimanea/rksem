;; P. Ragde --  Proust, a Nano Proof Assistant (2016)

#lang racket

(struct Lam (var body))                 ; lambda expression
(struct App (func arg))                 ; application
(struct Arrow (domain codomain))        ; function
(struct TA (type var))                  ; type annotation

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
    [`(,type ,var)
     (TA (parse-expr type)
         (parse-expr var))]
    [(? symbol? x) x]))                     ; otherwise, it's a symbol => return it

(parse-expr '(lambda x => x))                           ; => #<Lam>
(parse-expr '(lambda x => (lambda y => (x y))))         ; => #<Lam>
(parse-expr '(+ x))                                     ; => #<App>
(parse-expr 'x)                                         ; => 'X

;; type = (type -> type) | X

;; ;; parse-type : sexp -> Type
(define (parse-type t)
  (match t
    [`(,t1 -> ,t2)
     (Arrow (parse-type t1)
            (parse-type t2))]
    [`(,type ,var)
     (TA (parse-type type)
         (parse-type var))]
    [(? symbol? X) X]
    [else (error "unrecognized type")]))

(parse-type '(A -> B))                      ; => #<Arrow>
(parse-type 'X)                             ; => 'X
(parse-type '(x a))                         ; => #<TA>

;; ;; type-check : Context Expr Type -> boolean
;; ;; produces #t if expr has type t in context ctx (else error)
(define (type-check ctx expr type)
  (match expr
    [(Lam x t)
     (match type
       [(Arrow tt tw) (type-check (cons `(,x ,tt) ctx) t tw)]
       [else (cannot-check ctx expr type)])]
    [else (if (equal? (type-infer ctx expr) type) true
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

(type-check empty
            (parse-expr '(lambda x => x))
            (parse-type '(A -> A)))                 ; => #t

;; ONLY WORKS FOR LAMBDAS

;; (define (check-proof p)
;;   (type-infer empty (parse-expr p)) true)

;; test:
;; (check-proof
;;  `((lambda x => (lambda y => (y x))) : (A -> ((A -> B) -> B))))
