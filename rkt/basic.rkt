;; Basics on Racket (Appendix)
#lang racket

;; quote
'(+ 1 2)            ; => '(+ 1 2)

;; quasiquote & unquote
(define x 3)
`(+ 2 ,x)           ; => '(+ 2 3)
(+ 2 x)             ; => 5

;; splice unquote
(define y '(1 2 3))
`(+ 4 ,@y)          ; => '(+ 4 1 2 3)

;; ERROR
;; (+ 4 y)             ; => contract violation: + expected number

;; anonymous function via lambda
(define (mod2 n)
  ((lambda (t)
    (remainder t 2)) n))
(mod2 3)                ; => 1

(define (mod3 x)
  (cond
    ((equal? (remainder x 3) 1) write "it's 1")
    ((equal? (remainder x 3) 2) write "it's 2")
    (#t write "it's 0")))
(mod3 5)                ; => "it's 2"
(mod3 1)                ; => "it's 1"
(mod3 6)                ; => "it's 0"

(define (add-or-quote x)
  (cond
    ((equal? (remainder x 2) 0) ((lambda (t) (+ 1 2)) x))
    (#t ((lambda (t) 'hello) x))))
(add-or-quote 5)        ; => 'hello
(add-or-quote 6)        ; => 3

