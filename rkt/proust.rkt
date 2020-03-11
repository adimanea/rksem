;; P. Ragde --  Proust, a Nano Proof Assistant (2016)

#lang racket

(struct Lam (var body))                 ; lambda expression
(struct App (func arg))                 ; application
(struct Arrow (domain codomain))        ; function

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
    [(? symbol? x) x]))                     ; otherwise, it's a symbol => return it

;; type = (type -> type) | X

;; parse-type : sexp -> Type
(define (parse-type t)
  (match t
    [`(,t1 -> ,t2)
     (Arrow (parse-type t1)
            (parse-type t2))]
    [(? symbol? X) X]
    [else (error "unrecognized type")]))

;; type-check : Context Expr Type -> boolean
;; produces #t if expr has type t in context ctx (else error)
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
    ;; [(ann e t) (type-check ctx e t) t]          ;; SYNTAX ERROR
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

;; test: a proof term annotated with expected type
(define (check-proof p)
  (type-infer empty (parse-expr p)))

;; test:
(check-proof
 '((lambda x => (lambda y => (y x))) : (A -> ((A -> B) -> B))))
;; ERROR: NO MATCHING CLAUSE
