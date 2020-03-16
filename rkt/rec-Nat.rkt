#lang pie

(rec-Nat (add1 zero)
		 0
		 (lambda (n-1 almost)
		   (add1
			(add1 almost))))
;; is the same as
((lambda (n-1 almost)
   (add1
	(add1 almost)))
 zero
 (rec-Nat zero
		  0
		  (lambda (n-1 almost)
			(add1
			 (add1 almost)))))
;; which is further
(add1
 (add1
  (rec-Nat zero
		   0
		   (lambda (n-1 almost)
			 (add1
			  (add1 almost))))))
;; then further
(add1
 (add1 0))      ;; => 2
