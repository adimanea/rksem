#lang pie

(claim Pear U)                  ;; the Pear type
(define Pear
  (Pair Nat Nat))               ;; is just a Pair of Nats

(claim Pear-maker U)            ;; universe
(define Pear-maker              ;; two Nats make a Pear
  (-> Nat Nat Pear))

(claim elim-Pear
	   (-> Pear Pear-maker Pear))
(define elim-Pear               ;; eliminator consumes the maker
  (lambda (pear maker)
	(maker (car pear) (cdr pear))))

;; sum must be defined
(claim step+
       (-> Nat Nat))
(define step+
  (lambda (+n-1)
    (add1 +n-1)))

(claim + (-> Nat Nat Nat))
(define +
  (lambda (n j)
    (iter-Nat n
              j
              step+)))

(claim pearwise+                ;; Addition for Pear types
	   (-> Pear Pear Pear))
(define pearwise+
  (lambda (x y)
	(elim-Pear x                ;; split the two parts into
			   (lambda (a1 d1)  ;; their parts (remember, Pair = (Nat, Nat))
				 (elim-Pear y
							(lambda (a2 d2)
							  (cons
							   (+ a1 a2)        ;; then add the parts
							   (+ d1 d2))))))))
