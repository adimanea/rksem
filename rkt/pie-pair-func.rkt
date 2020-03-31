#lang pie

(claim elim-Pair                    ; "consumer" (eliminator) for Pairs
       (Pi ((A U) (D U) (X U))
           (-> (Pair A D)
               (-> A D X) X)))
(define elim-Pair
  (lambda (A D X)                   ; abstract the type variables first
    (lambda (p f)                   ; then the rest (f = eliminator, p = pair)
      (f (car p) (cdr p)))))

(claim kar                          ; DIY car = first
       (-> (Pair Nat Nat) Nat))
(define kar
  (lambda (p)
    (elim-Pair Nat Nat Nat p        ; make the types concrete
               (lambda (a d) a))))  ; take first component

(claim kdr                          ; DIY cdr = second
       (-> (Pair Nat Nat) Nat))
(define kdr
  (lambda (p)
    (elim-Pair Nat Nat Nat p        ; make the types concrete
               (lambda (a d) d))))  ; take second component

;; flipping two elements of a Pair
(claim flip
       (Pi ((A U) (D U))
           (-> (Pair A D) (Pair D A))))
(define flip
  (lambda (A D)                     ; abstract the type variables first
    (lambda (p)                     ; then the pair
      (cons (cdr p) (car p)))))

;; Examples
(kdr (cons 5 3))                    ; => (the Nat 3)
(kar (cons 8 4))                    ; => (the Nat 8)
((flip Nat Atom) (cons 17 'apple))  ; => (the (Pair Atom Nat) (cons 'apple 17))
