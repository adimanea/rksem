#lang pie

(which-Nat zero
		   'naught
		   (lambda (n)
			 'more))            ;; => 'naught
(which-Nat 4
		   'naught
		   (lambda (n)
			 'more))            ;; => 4
;; 4 is another way of writing (add1 3)
;; so it returns ((lambda (n) 'more) 3),
;; which is 'more.

(which-Nat 5
		   0
		   (lambda (n)
			 (+ 6 n)))          ;; => 10
;; 5 is (add1 4), so it returns
;; ((lambda (n) (+ 6 n)) 4) = 10.
