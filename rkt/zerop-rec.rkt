#lang pie

(claim step-zerop           ; the inductive step for
	   (-> Nat Atom         ; checking nullity
		   Atom))
(define step-zerop
  (lambda (n-1 zerop-n-1)
	'nil))                  ; nothing

(claim zerop                ; the actual check
	   (-> Nat
		   Atom))
(define zerop
  (lambda (n)
	(rec-Nat n
			 't             ; true
			 step-zerop)))

;; REMARK: `zerop' is actually `zero?' in Scheme.
