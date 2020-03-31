#lang pie

;; A couple of the most used "inductive" functions

;; (which-Nat target base step)
;; - if target is zero => return base
;; - else, return (step (- target 1))
(which-Nat zero
		   'naught
		   (lambda (n) 'more))      ; => (the Atom 'naught)

(which-Nat 4
		   'naught
		   (lambda (n) 'more))      ; => (the Atom 'more)

(which-Nat 5
		   0
		   (lambda (n) (add1 7)))   ; => (the Nat 8)


;; (iter-Nat target base step)
;; - if target is zero => return base;
;; - else, target is some (add1 n) and return (step (iter-Nat n base step))

;; We will use this to define addition
;; First, define the inductive step
(claim step+ (-> Nat Nat))          ; processes one Nat and returns another
(define step+
  (lambda (+n-1)
	(add1 +n-1)))

;; Now the addition
(claim + (-> Nat Nat Nat))          ; addition for the Nat type
(define +
  (lambda n j
		  (iter-Nat n j step+)))


;; (rec-Nat target base step)
;; - if target is zero, return base;
;; - else, target is some (add1 n) and return (step (n (rec-Nat n base step)))
;; Example
(rec-Nat
 (add1 zero)                ; target = 1 => n = 0
 0                          ; base
 (lambda (n-1 almost)       ; step (two-arg function)
   (add1 (add1 almost))))
;; => (the Nat 2)

;; Example: Gauss sum
;; the inductive step
(claim step-gauss
	   (-> Nat Nat Nat))
(define step-gauss
  (lambda (n-1 gauss-n-1)
	(+ (add1 n-1) gauss-n-1)))

;; now the Gauss function
(claim gauss (-> Nat Nat))
(define gauss
  (lambda (n)
	(rec-Nat n
			 0
			 step-gauss)))
;; Test
(gauss 15)                  ; => (the Nat 120)
