;; Definining the functions to append to a list,
;; using steps and induction, as well as dependent types.
#lang pie

;; the inductive step first
(claim step-append
	   (Pi ((E U))
		   (-> E (List E) (List E)
			   (List E))))
(define step-append
  (lambda (E)
	(lambda (e es append-es)
	  (:: e append-es))))

(claim append
	   (Pi ((E U))
		   (-> (List E) (List E)
			   (List E))))
(define append
  (lambda (E)
	(lambda (start end)
	  (rec-List start
				end
				(step-append E)))))

;; Test
(append Nat (:: 5 nil) (:: 3 nil))  ; => (the (List Nat) (:: 5 (:: 3 nil)))
