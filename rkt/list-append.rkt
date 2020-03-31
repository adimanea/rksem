;; Definining the functions to append to a list,
;; using steps and induction, as well as dependent types.
#lang pie

;; the inductive step for appending to a list
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
				(step-append E))))) ; we need the inductive step

