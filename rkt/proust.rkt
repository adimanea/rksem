;; P. Ragde -- Proust, a nano proof assistant (2016)
;; Special thanks to the author!

#lang racket

(struct Lam (var body) #:transparent)          ; lambda abstraction
(struct App (func arg) #:transparent)          ; function application
(struct Ann (expr type) #:transparent)         ; explicit type annotations
(struct Arrow (domain codomain) #:transparent) ; functional types

;; GRAMMAR
;; EXPRESSIONS
;; expr ::= (lambda x => expr)
;;        | (expr expr)
;;        | (expr : type)
;;        | x (variable)            <------ NO CONSTANTS ALLOWED!
;; TYPES
;; type ::= (type -> type)
;;        | X

;; Parse types
(define (parse-type t)
  (match t                                  ; pattern match the type
    [`(,t1 -> ,t2)                          ; is it functional?
     (Arrow (parse-type t1)                 ; make it an Arrow
            (parse-type t2))]
    (`(,t1 -> ,t2 -> ,r ...)                ; is it a multifunc?
     (Arrow (parse-type t1)                 ; make it a "multiarrow"
            (parse-type `(,t1 -> ,@r))))
    [(? symbol? X) X]                       ; is it simple? return it
    [else (error "can't parse this type")]))

;; Test
(parse-type '(Int -> Nat))                  ; => (Arrow 'Int 'Nat)
(parse-type 'String)                        ; => 'String
(parse-type '(Int -> Nat -> String))        ; => (Arrow 'Int (Arrow 'Int 'String))

(define (parse-expr s)
  (match s                              ; pattern match the argument
    [`(lambda ,(? symbol? x) => ,e)     ; is it a lambda?
     (Lam x (parse-expr e))]            ; make it a Lam
    [`(,e0 ,e1)                         ; is it an application?
     (App (parse-expr e0)               ; make it an App
          (parse-expr e1))]
    [`(,e : ,t)                         ; is it a type annotation (e : t)?
     (Ann (parse-expr e)                ; make it an Ann
          (parse-type t))]
    [`(,e1 ,e2 ,e3 ,r ...)              ; is it a general list?
     (parse-expr
      `((,e1 ,e2) ,e3 ,@r))]            ; parse it in pairs
    [(? symbol? x) x]                   ; else, it's a symbol, return it
    [else (error 'parse "bad syntax ~a" s)]))       ; fail with reason

;; Test
(parse-expr '(f x))                     ; => (App 'f 'x)
(parse-expr '(lambda x => x))           ; => (Lam 'x 'x)
(parse-expr '(lambda x => (x y)))       ; => (Lam 'x (App 'x 'y))
;; (parse-expr 3)                          ; => parse: bad syntax 3     <-- WILL STOP EVALUATION
(parse-expr '(x : Nat))                 ; => (Ann 'x 'Nat)
(parse-expr '(x y z t))                 ; => (App (App (App 'x 'y) 'z) 't)
(parse-expr '(x (lambda y => (z t) (a : Int))))  ; => (App (App 'x (Lam 'y (App 'z 't))) (Ann 'a 'Int))



;; Pretty printing ("unparsing")
;; pretty-print-expr : expr -> String
(define (pretty-print-expr e)
  (match e
    [(Lam x b)                                  ; lambdas
     (format "(lambda ~a => ~a)" x (pretty-print-expr b))]
    [(App e1 e2)                                ; function application
     (format "(~a ~a)" (pretty-print-expr e1) (pretty-print-expr e2))]
    [(? symbol? x) (format "~a" x)]             ; variables
    [(Ann e t) (format "(~a : ~a)"              ; type annotations
                       (pretty-print-expr e)
                       (pretty-print-expr t))]))

;; pretty-print-type : Type -> String
(define (pretty-print-type t)
  (match t
    [(Arrow t1 t2)                              ; functional types
     (format "(~a -> ~a)"
             (pretty-print-type t1)
             (pretty-print-type t2))]
    [else t]))                                  ; simple types

;; Context = (Listof (List Symbol Type))
(define (pretty-print-context ctx)
  (cond
    [(empty? ctx) ""]
    [else (string-append (format "~a : ~a, "
                                 (first (first ctx))
                                 (pretty-print-type (second (first ctx))))
                         (pretty-print-context (rest ctx)))]))

;; Test
(pretty-print-context (list (list 'x 'Int) (list 'z '(A -> B)))) ; => "x : Int, z : A -> B"
(pretty-print-context (list (list 'x 'Int) (list 'f (pretty-print-expr (parse-expr '(lambda z => t))))))
;;                                                         |_________________|
;;                                                           mutual inverses
;; => "x : Int, f : (lambda z => t)"

;; CHECKING LAMBDAS
;; type-check : Context Expr Type -> Boolean
;; produces true if expr has type t in context ctx (else, error)
(define (type-check ctx expr type)
  (match expr
    [(Lam x t)                      ; is it a lambda expression?
     (match type                    ; then the type must be an Arrow
       [(Arrow tt tw) (type-check (cons `(,x ,tt) ctx) t tw)]
       [else (cannot-check ctx expr type)])]
    [else (if (equal? (type-infer ctx expr) type) true      ; fail for any other type
              (cannot-check ctx expr type))]))

;; the error function
(define (cannot-check ctx expr type)
  (error 'type-check "cannot typecheck ~a as ~a in context ~a"
         (pretty-print-expr expr)
         (pretty-print-type type)
         (pretty-print-context ctx)))

;; type-infer : Context Expr -> Type
;; tries to produce type of expr in context ctx (else, error)
(define (type-infer ctx expr)
  (match expr
    [(Lam _ _) (cannot-infer ctx expr)]         ; lambdas are handled in type-check
    [(Ann e t) (type-check ctx e t) t]          ; check type annotation
    [(App f a)                                  ; function application
     (define tf (type-infer ctx f))
     (match tf                                  ; must be Arrow type
       [(Arrow tt tw) #:when (type-check ctx a tt) tw]  ; when the rest typechecks
       [else (cannot-infer ctx expr)])]
    [(? symbol? x)                              ; for symbols
     (cond
       [(assoc x ctx) => second]                ; if it's a (ctx) list, the second is the type
       [else (cannot-infer ctx expr)])]))       ; else, fail

;; the error function
(define (cannot-infer ctx expr)
  (error 'type-infer "cannot infer type of ~a in context ~a"
         (pretty-print-expr)
         (pretty-print-context ctx)))

;; BASIC TESTING
(require test-engine/racket-tests)

(define (check-proof p)                         ; for empty contexts
  (type-infer empty (parse-expr p)) true)

;; lambda x . x : A -> A
(check-expect (check-proof '((lambda x => x) : (A -> A))) true)

;; lambda xy.x : A -> (B -> A)
(check-expect (check-proof '((lambda x => (lambda y => x)) : (A -> (B -> A))))
              true)

;; lambda xy.yx : (A -> ((A -> B) -> B))
(check-expect
 (check-proof '((lambda x => (lambda y => (y x))) : (A -> ((A -> B) -> B))))
 true)

(test)          ; => All 3 tests passed!
